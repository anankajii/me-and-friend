# boss_challenge.gd
# Overlay UI ketika player mencapai zona boss.
# Emit signal 'submitted' dengan jawaban player.

class_name BossChallenge
extends CanvasLayer

signal submitted(answer: String)

# ─── referensi internal ───
var _input: TextEdit
var _result_label: Label
var _validate_btn: Button

# ─────────────────────────────────────────
#  Setup — panggil sekali setelah add_child
#  level_data: Dictionary dari GameData.LEVELS[i]
# ─────────────────────────────────────────
func setup(level_data: Dictionary) -> void:
	# Panel latar
	var panel := ColorRect.new()
	panel.color = Color(0.125, 0.125, 0.188, 0.96)
	panel.position = Vector2(296, 155)
	panel.size    = Vector2(560, 320)
	add_child(panel)

	# Judul boss
	var title := _make_label(level_data.boss + " muncul!", 26)
	title.position = Vector2(316, 168)
	title.size     = Vector2(520, 38)
	add_child(title)

	# Divider
	var line := ColorRect.new()
	line.color    = Color("ffffff33")
	line.position = Vector2(316, 210)
	line.size     = Vector2(520, 2)
	add_child(line)

	# Pertanyaan
	var prompt := _make_label(level_data.question, 17)
	prompt.position = Vector2(326, 217)
	prompt.size     = Vector2(500, 38)
	add_child(prompt)

	# Hint kecil
	var hint := _make_label("Contekan:  " + str(level_data.answer), 16)
	hint.modulate  = Color(1, 1, 1, 0.35)
	hint.position  = Vector2(346, 257)
	hint.size      = Vector2(460, 24)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	add_child(hint)

	# Input area
	_input = TextEdit.new()
	_input.position           = Vector2(346, 286)
	_input.size               = Vector2(460, 62)
	_input.placeholder_text   = "Tulis jawaban di sini..."
	_input.add_theme_font_size_override("font_size", 18)
	add_child(_input)

	# Tombol validasi
	_validate_btn = Button.new()
	_validate_btn.text     = "✔  VALIDASI"
	_validate_btn.position = Vector2(471, 360)
	_validate_btn.size     = Vector2(210, 40)
	_validate_btn.add_theme_font_size_override("font_size", 19)
	_validate_btn.pressed.connect(_on_validate_pressed)
	add_child(_validate_btn)

	# Label hasil
	_result_label = _make_label("", 20)
	_result_label.position = Vector2(326, 414)
	_result_label.size     = Vector2(500, 30)
	_result_label.modulate = Color("ffff88")
	add_child(_result_label)

	_input.grab_focus()

# ─────────────────────────────────────────
#  Tampilkan hasil validasi
# ─────────────────────────────────────────
func show_result(text: String, success := false) -> void:
	if _result_label == null: return
	_result_label.text = text
	_result_label.modulate = Color("88ff88") if success else Color("ff8888")
	# nonaktifkan tombol sementara supaya tidak double-submit
	if success and _validate_btn:
		_validate_btn.disabled = true

# ─────────────────────────────────────────
#  Internal
# ─────────────────────────────────────────
func _on_validate_pressed() -> void:
	if _input:
		submitted.emit(_input.text)

func _make_label(text: String, font_size: int) -> Label:
	var lbl := Label.new()
	lbl.text = text
	lbl.add_theme_font_size_override("font_size", font_size)
	lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return lbl
