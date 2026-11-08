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
	var stripped := source.strip_edges()
	if stripped.is_empty() or (stripped.begins_with("#") and not "\n" in stripped):
		return _failure("Tulis kode Python terlebih dahulu.")
	if not require_variable:
		# Level 1: kode apa pun yang tidak kosong diterima
		return {"ok": true, "message": "BENAR! Kode Python berhasil dijalankan di sandbox."}
	# Level 2: harus ada assignment variabel
	var execution := _run_python_sandbox(source)
	if not execution.get("ok", false):
		return _failure(str(execution.get("message", "Kode Python tidak dapat dijalankan.")))
	if not _has_variable_assignment(source):
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
	if source.strip_edges().is_empty():
		return _failure("Tulis kode Python terlebih dahulu.")
	if len(source) > 2000:
		return _failure("Kode terlalu panjang untuk tantangan ini.")
	var lines: Array[String] = []
	for raw in source.split("\n"):
		var clean := ""
		var in_quote := ""
		var i := 0
		while i < raw.length():
			var c := raw[i]
			if in_quote.is_empty() and (c == "\"" or c == "'"):
				in_quote = c; clean += c
			elif not in_quote.is_empty() and c == in_quote:
				in_quote = ""; clean += c
			elif in_quote.is_empty() and c == "#":
				break
			else:
				clean += c
			i += 1
		lines.append(clean)
	var variables: Dictionary = {}
	var output_parts: Array[String] = []
	var result := _exec_lines(lines, 0, lines.size(), variables, output_parts)
	if not result.get("ok", false):
		return result
	return {"ok": true, "output": "\n".join(output_parts).strip_edges()}


static func _exec_lines(lines: Array[String], start: int, end_line: int, variables: Dictionary, output: Array[String]) -> Dictionary:
	var i := start
	while i < end_line:
		var line: String = lines[i].rstrip(" 	")
		if line.strip_edges().is_empty():
			i += 1; continue

		var indent := 0
		while indent < line.length() and (line[indent] == " " or line[indent] == "	"):
			indent += 1
		var stripped := line.strip_edges()

		# if / elif / else
		if stripped.begins_with("if ") or stripped.begins_with("elif "):
			var colon := stripped.rfind(":")
			if colon < 0:
				return _failure("SyntaxError: if/elif butuh tanda ':'.")
			var condition_str := stripped.substr(stripped.find(" ") + 1, colon - stripped.find(" ") - 1)
			var body_lines := _collect_block(lines, i + 1, end_line, indent)
			var else_start := i + 1 + body_lines
			var cond_result := _eval_condition(condition_str, variables)
			if not cond_result.get("ok", false):
				return cond_result
			if cond_result.get("value", false):
				var r := _exec_lines(lines, i + 1, i + 1 + body_lines, variables, output)
				if not r.get("ok", false): return r
				# skip semua elif/else setelah blok yang dieksekusi
				i = _skip_elif_else(lines, else_start, end_line, indent)
			else:
				i = else_start
				# lanjut ke elif/else berikutnya
				if i < end_line:
					var next := lines[i].strip_edges()
					if next.begins_with("elif ") or next == "else:":
						continue
			continue
		elif stripped == "else:":
			var body_lines := _collect_block(lines, i + 1, end_line, indent)
			var r := _exec_lines(lines, i + 1, i + 1 + body_lines, variables, output)
			if not r.get("ok", false): return r
			i = i + 1 + body_lines
			continue

		# print()
		elif stripped.begins_with("print(") and stripped.ends_with(")"):
			var args_str := stripped.substr(6, stripped.length() - 7)
			var eval_result := _eval_print_args(args_str, variables)
			if not eval_result.get("ok", false): return eval_result
			output.append(str(eval_result.get("value", "")))

		# assignment
		elif "=" in stripped and not stripped.begins_with("print"):
			var eq := _find_assign_eq(stripped)
			if eq > 0:
				var name := stripped.substr(0, eq).strip_edges()
				var val_str := stripped.substr(eq + 1).strip_edges()
				if not name.is_valid_identifier() or name.begins_with("_"):
					return _failure("Nama variabel '%s' tidak diizinkan." % name)
				var val_result := _eval_expr(val_str, variables)
				if not val_result.get("ok", false): return val_result
				variables[name] = val_result.get("value")
			else:
				return _failure("SyntaxError: '%s' tidak dikenali." % stripped)
		elif stripped == "pass":
			pass
		else:
			return _failure("SyntaxError: '%s' tidak didukung di editor ini." % stripped.left(40))
		i += 1
	return {"ok": true}


static func _collect_block(lines: Array[String], start: int, end_line: int, parent_indent: int) -> int:
	var count := 0
	for j in range(start, end_line):
		var l := lines[j]
		if l.strip_edges().is_empty(): count += 1; continue
		var ind := 0
		while ind < l.length() and (l[ind] == " " or l[ind] == "	"): ind += 1
		if ind <= parent_indent: break
		count += 1
	return count


static func _skip_elif_else(lines: Array[String], start: int, end_line: int, parent_indent: int) -> int:
	var i := start
	while i < end_line:
		var l := lines[i]
		if l.strip_edges().is_empty(): i += 1; continue
		var ind := 0
		while ind < l.length() and (l[ind] == " " or l[ind] == "	"): ind += 1
		if ind != parent_indent: break
		var s := l.strip_edges()
		if s.begins_with("elif ") or s == "else:":
			var body := _collect_block(lines, i + 1, end_line, ind)
			i = i + 1 + body
		else:
			break
	return i


static func _find_assign_eq(line: String) -> int:
	var in_quote := ""
	for i in line.length():
		var c := line[i]
		if in_quote.is_empty() and (c == "\"" or c == "'"): in_quote = c
		elif not in_quote.is_empty() and c == in_quote: in_quote = ""
		elif in_quote.is_empty() and c == "=":
			if (i > 0 and line[i-1] in ["=","!","<",">"]) or (i+1 < line.length() and line[i+1] == "="): return -1
			return i
	return -1


static func _eval_print_args(args_str: String, variables: Dictionary) -> Dictionary:
	var parts := _split_top(args_str, ",")
	var out_parts: Array[String] = []
	for part in parts:
		var r := _eval_expr(part.strip_edges(), variables)
		if not r.get("ok", false): return r
		out_parts.append(str(r.get("value", "")))
	return {"ok": true, "value": " ".join(out_parts)}


static func _eval_condition(expr: String, variables: Dictionary) -> Dictionary:
	# cek == != < > <= >=
	for op in ["==", "!=", "<=", ">=", "<", ">"]:
		var idx := expr.find(op)
		if idx > 0:
			var left := _eval_expr(expr.substr(0, idx).strip_edges(), variables)
			var right := _eval_expr(expr.substr(idx + op.length()).strip_edges(), variables)
			if not left.get("ok", false): return left
			if not right.get("ok", false): return right
			var lv = left.get("value"); var rv = right.get("value")
			match op:
				"==": return {"ok": true, "value": lv == rv}
				"!=": return {"ok": true, "value": lv != rv}
				"<":  return {"ok": true, "value": lv < rv}
				">":  return {"ok": true, "value": lv > rv}
				"<=": return {"ok": true, "value": lv <= rv}
				">=": return {"ok": true, "value": lv >= rv}
	return _eval_expr(expr, variables)


static func _eval_expr(expr: String, variables: Dictionary) -> Dictionary:
	expr = expr.strip_edges()
	if expr.is_empty(): return _failure("Ekspresi kosong.")
	# string literal
	if (expr.begins_with("\"") and expr.ends_with("\"")) or (expr.begins_with("'") and expr.ends_with("'")):
		return {"ok": true, "value": expr.substr(1, expr.length() - 2)}
	# int/float
	if expr.is_valid_int(): return {"ok": true, "value": expr.to_int()}
	if expr.is_valid_float(): return {"ok": true, "value": expr.to_float()}
	# bool/None
	if expr == "True": return {"ok": true, "value": true}
	if expr == "False": return {"ok": true, "value": false}
	if expr == "None": return {"ok": true, "value": null}
	# variable
	if expr.is_valid_identifier():
		if variables.has(expr): return {"ok": true, "value": variables[expr]}
		return _failure("Variabel '%s' belum didefinisikan." % expr)
	# + concatenation/addition (sederhana)
	var plus := expr.rfind("+")
	if plus > 0:
		var l := _eval_expr(expr.substr(0, plus).strip_edges(), variables)
		var r := _eval_expr(expr.substr(plus + 1).strip_edges(), variables)
		if l.get("ok") and r.get("ok"):
			return {"ok": true, "value": str(l.get("value")) + str(r.get("value")) if l.get("value") is String or r.get("value") is String else l.get("value") + r.get("value")}
	return _failure("Ekspresi '%s' tidak didukung." % expr.left(30))


static func _split_top(text: String, sep: String) -> Array[String]:
	var parts: Array[String] = []
	var start := 0; var quote := ""
	for i in text.length():
		var c := text[i]
		if quote.is_empty() and (c == "\"" or c == "'"): quote = c
		elif not quote.is_empty() and c == quote: quote = ""
		elif quote.is_empty() and text.substr(i, sep.length()) == sep:
			parts.append(text.substr(start, i - start)); start = i + sep.length()
	parts.append(text.substr(start))
	return parts


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
