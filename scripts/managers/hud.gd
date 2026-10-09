# hud.gd
# Mengelola tampilan HP, Coin, nama karakter, dan pesan tengah layar.
# Gunakan: var hud = HUD.new(); add_child(hud); hud.setup(...)

class_name HUD
extends CanvasLayer

var _status_label: Label
var _message_label: Label
var _message_timer: SceneTreeTimer

func setup() -> void:
	# Status bar kiri atas
	_status_label = Label.new()
	_status_label.position = Vector2(18, 15)
	_status_label.size = Vector2(500, 35)
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_status_label.add_theme_font_size_override("font_size", 20)
	add_child(_status_label)

	# Pesan tengah layar (sementara)
	_message_label = Label.new()
	_message_label.position = Vector2(260, 70)
	_message_label.size = Vector2(620, 90)
	_message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_message_label.add_theme_font_size_override("font_size", 28)
	add_child(_message_label)

func update(char_name: String, hp: int, coins: int) -> void:
	if _status_label:
		var hearts := "❤".repeat(hp) + "♡".repeat(max(0, 3 - hp))
		_status_label.text = "%s   %s   🪙 %d" % [char_name, hearts, coins]

func show_message(text: String, seconds: float) -> void:
	if _message_label == null: return
	_message_label.text = text
	# batalkan timer sebelumnya kalau masih berjalan
	if _message_timer != null and is_instance_valid(_message_timer):
		pass  # tidak bisa cancel, tapi overwrite text saja cukup
	_message_timer = get_tree().create_timer(seconds)
	_message_timer.timeout.connect(func():
		if _message_label:
			_message_label.text = ""
	)

func clear_message() -> void:
	if _message_label:
		_message_label.text = ""
