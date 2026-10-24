class_name PythonChallengeJudge
extends RefCounted

## Menjalankan Python asli melalui runner dengan whitelist AST yang ketat.
## Runner hanya menerima variabel, kondisi dasar, operasi sederhana, dan print().
const PYTHON_RUNNER := "res://scripts/tools/safe_python_runner.py"
const DEFAULT_PYTHON_COMMAND := "python"

static func validate(source: String, level_data: Dictionary) -> Dictionary:
	var challenge = level_data.get("challenge", {})
	var validation = challenge.get("validation", {}) if challenge is Dictionary else {}
	var validation_type := str(validation.get("type", "print_output"))

	match validation_type:
		"repair_campus_data":
			return _validate_campus_data_repair(source)
		"free_text":
			return _validate_free_text(source)
		"valid_python":
			return _validate_valid_python(source, bool(validation.get("require_variable", false)))
		"print_output":
			return _validate_print_output(source, str(validation.get("expected_output", "")))
		"contains_tokens":
			return _validate_tokens(source, validation.get("tokens", []))
		"any_of":
			return _validate_any_of(source, validation.get("answers", []))
		_:
			return _failure("Aturan tantangan belum dikenali.")


## Tantangan bebas: input tidak dieksekusi dan tidak dinilai sebagai Python.
## Cukup ada isi agar pemain tidak mengirim editor kosong secara tidak sengaja.
static func _validate_free_text(source: String) -> Dictionary:
	if source.strip_edges().is_empty() or source.strip_edges().begins_with("#") and source.strip_edges().count("\n") == 0:
		return _failure("Tulis jawaban atau kode terlebih dahulu.")
	return {"ok": true, "message": "BENAR! Jawaban diterima."}


static func _validate_valid_python(source: String, require_variable: bool) -> Dictionary:
	var execution := _run_python_sandbox(source)
	if not execution.get("ok", false):
		return _failure(str(execution.get("message", "Kode Python tidak dapat dijalankan.")))
	if require_variable and not _has_variable_assignment(source):
		return _failure("Buat minimal satu variabel, misalnya: nama = \"Khanan\".")
	return {"ok": true, "message": "BENAR! Kode Python berhasil dijalankan di sandbox."}


## Tantangan akhir Level 3: pemain memperbaiki beberapa kesalahan pada kode server.
static func _validate_campus_data_repair(source: String) -> Dictionary:
	var execution := _run_python_sandbox(source)
	if not execution.get("ok", false):
		return _failure(str(execution.get("message", "Kode masih memiliki error.")))

	var compact := source.replace(" ", "").replace("\t", "")
	if not compact.contains("data_kampus="):
		return _failure("Variabel data_kampus masih harus dipertahankan.")
	if not compact.contains("kode_akses="):
		return _failure("Variabel kode_akses masih harus dipertahankan.")
	if not compact.contains("jumlah_fragmen=3"):
		return _failure("Periksa kembali nilai jumlah_fragmen.")
	if not compact.contains("ifjumlah_fragmen==3:"):
		return _failure("Baris if harus membandingkan jumlah_fragmen dengan 3 menggunakan ==.")
	if not compact.contains("status_data=\"pulih\"") and not compact.contains("status_data='pulih'"):
		return _failure("status_data harus diisi dengan teks 'pulih', bukan dibandingkan.")
	if str(execution.get("output", "")) != "Data Kampus: pulih":
		return _failure("Output akhir harus tepat: Data Kampus: pulih")
	return {"ok": true, "message": "Indeks Data Kampus berhasil dipulihkan."}


static func _validate_print_output(source: String, expected_output: String) -> Dictionary:
	var execution := _run_python_sandbox(source)
	if not execution.get("ok", false):
		return _failure(str(execution.get("message", "Kode Python tidak dapat dijalankan.")))
	var actual_output := str(execution.get("output", ""))
	if actual_output == expected_output:
		return {"ok": true, "message": "BENAR! Output program sesuai."}
	return _failure("Output masih '%s'. Targetnya adalah '%s'." % [actual_output, expected_output])


static func _run_python_sandbox(source: String) -> Dictionary:
	var submission_path := "user://challenge_submission.py"
	var result_path := "user://challenge_result.json"
	var submission := FileAccess.open(submission_path, FileAccess.WRITE)
	if submission == null:
		return _failure("Berkas jawaban tidak dapat dibuat.")
	submission.store_string(source)
	submission.close()

	var arguments := PackedStringArray([
		"-I", "-S",
		ProjectSettings.globalize_path(PYTHON_RUNNER),
		ProjectSettings.globalize_path(submission_path),
		ProjectSettings.globalize_path(result_path)
	])
	var python_command := str(ProjectSettings.get_setting("python_sandbox/executable", DEFAULT_PYTHON_COMMAND))
	var exit_code := OS.execute(python_command, arguments)
	DirAccess.remove_absolute(ProjectSettings.globalize_path(submission_path))
	if exit_code != 0:
		DirAccess.remove_absolute(ProjectSettings.globalize_path(result_path))
		return _failure("Python tidak dapat dijalankan. Pastikan Python terpasang dan ada di PATH.")

	var result_file := FileAccess.open(result_path, FileAccess.READ)
	if result_file == null:
		return _failure("Python tidak menghasilkan respons.")
	var parsed = JSON.parse_string(result_file.get_as_text())
	result_file.close()
	DirAccess.remove_absolute(ProjectSettings.globalize_path(result_path))
	if parsed is Dictionary:
		return parsed
	return _failure("Respons Python tidak dapat dibaca.")


static func _has_variable_assignment(source: String) -> bool:
	var assignment_pattern := RegEx.new()
	assignment_pattern.compile("(?m)^\\s*(?!print\\b)[A-Za-z][A-Za-z0-9_]*\\s*=")
	return assignment_pattern.search(source) != null


static func _validate_tokens(source: String, required_tokens: Array) -> Dictionary:
	var compact := source.replace(" ", "").replace("\t", "").replace("\n", "")
	for token in required_tokens:
		if not compact.contains(str(token).replace(" ", "")):
			return _failure("Masih ada bagian kode yang belum lengkap.")
	return {"ok": true, "message": "BENAR! Struktur kode sesuai."}


static func _validate_any_of(source: String, answers: Array) -> Dictionary:
	var normalized := _normalize(source)
	for answer in answers:
		if normalized == _normalize(str(answer)):
			return {"ok": true, "message": "BENAR! Jawaban diterima."}
	return _failure("Jawaban belum sesuai. Coba periksa kembali kode kamu.")


static func _evaluate_print(arguments: String, variables: Dictionary) -> Dictionary:
	var values: Array[String] = []
	for argument in _split_top_level(arguments, ","):
		var result := _evaluate_expression(argument, variables)
		if not result.get("ok", false):
			return result
		values.append(str(result.get("value", "")))
	return {"ok": true, "value": " ".join(values)}


static func _evaluate_expression(raw_expression: String, variables: Dictionary) -> Dictionary:
	var expression := raw_expression.strip_edges()
	if expression.is_empty():
		return _failure("Isi print() tidak boleh kosong.")

	var additions := _split_top_level(expression, "+")
	if additions.size() > 1:
		var combined := ""
		for part in additions:
			var part_result := _evaluate_expression(part, variables)
			if not part_result.get("ok", false):
				return part_result
			combined += str(part_result.get("value", ""))
		return {"ok": true, "value": combined}

	if expression.length() >= 2 and expression[0] == expression[expression.length() - 1] and expression[0] in ["\"", "'"]:
		return {"ok": true, "value": _unescape_string(expression.substr(1, expression.length() - 2))}
	if expression.is_valid_identifier() and variables.has(expression):
		return {"ok": true, "value": variables[expression]}
	if expression.is_valid_int() or expression.is_valid_float():
		return {"ok": true, "value": expression}
	return _failure("Gunakan teks di dalam tanda kutip, angka, atau variabel yang sudah dibuat.")


static func _split_top_level(text: String, separator: String) -> Array[String]:
	var parts: Array[String] = []
	var start := 0
	var quote := ""
	var escaped := false
	for i in text.length():
		var character := text[i]
		if escaped:
			escaped = false
			continue
		if character == "\\":
			escaped = true
			continue
		if quote.is_empty() and character in ["\"", "'"]:
			quote = character
			continue
		if not quote.is_empty() and character == quote:
			quote = ""
			continue
		if quote.is_empty() and character == separator:
			parts.append(text.substr(start, i - start))
			start = i + 1
	parts.append(text.substr(start))
	return parts


static func _assignment_index(line: String) -> int:
	var quote := ""
	for i in line.length():
		var character := line[i]
		if quote.is_empty() and character in ["\"", "'"]:
			quote = character
		elif not quote.is_empty() and character == quote:
			quote = ""
		elif quote.is_empty() and character == "=":
			if (i > 0 and line[i - 1] in ["=", "!", ">", "<"]) or (i + 1 < line.length() and line[i + 1] == "="):
				return -1
			return i
	return -1


static func _strip_comments(source: String) -> String:
	var clean_lines: Array[String] = []
	for raw_line in source.split("\n"):
		var quote := ""
		var comment_at := raw_line.length()
		for i in raw_line.length():
			var character := raw_line[i]
			if quote.is_empty() and character in ["\"", "'"]:
				quote = character
			elif not quote.is_empty() and character == quote:
				quote = ""
			elif quote.is_empty() and character == "#":
				comment_at = i
				break
		clean_lines.append(raw_line.left(comment_at))
	return "\n".join(clean_lines)


static func _is_unsupported_statement(line: String) -> bool:
	for prefix in ["import ", "from ", "open(", "exec(", "eval(", "os.", "sys.", "while ", "for ", "if ", "def ", "class "]:
		if line.begins_with(prefix):
			return true
	return line.contains("__")


static func _unescape_string(value: String) -> String:
	return value.replace("\\n", "\n").replace("\\\"", "\"").replace("\\'", "'").replace("\\\\", "\\")


static func _normalize(value: String) -> String:
	return value.replace(" ", "").replace("\t", "").replace("\n", "").strip_edges()


static func _failure(message: String) -> Dictionary:
	return {"ok": false, "message": message}
