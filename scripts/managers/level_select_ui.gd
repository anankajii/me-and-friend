class_name LevelSelectUI
extends CanvasLayer

signal level_selected(level_index: int)
signal back_requested

@onready var level_buttons: Array[TextureButton] = [
	$UI/Level1Button,
	$UI/Level2Button,
	$UI/Level3Button,
]
@onready var play_button: TextureButton = $UI/PlayButton

var _selected_level := 0

func _ready() -> void:
	$UI/BackButton.pressed.connect(func(): back_requested.emit())
	play_button.pressed.connect(func(): level_selected.emit(_selected_level))
	for index in level_buttons.size():
		var button := level_buttons[index]
		button.pressed.connect(_select_level.bind(index))
		_configure_level(button, index)
		_play_entrance(button, index)
	_select_level(mini(GameData.unlocked_level, level_buttons.size() - 1))

func _configure_level(button: TextureButton, index: int) -> void:
	var unlocked := index <= GameData.unlocked_level
	button.disabled = not unlocked
	var status := button.get_node("Status") as Label
	var lock_icon := button.get_node("LockIcon") as TextureRect
	var stars := button.get_node("Stars") as Label
	var best_time := button.get_node("BestTime") as Label
	var earned_stars := GameData.get_level_stars(index)
	var time_seconds := GameData.get_best_time(index)
	lock_icon.visible = not unlocked
	status.text = ("SELESAI - MAIN LAGI" if earned_stars > 0 else "SIAP DIMAINKAN") if unlocked else "SELESAIKAN LEVEL %d" % index
	status.add_theme_color_override("font_color", Color("d8f6b8") if unlocked else Color("d5dbe8"))
	stars.text = _star_text(earned_stars)
	stars.modulate = Color("ffd24d") if earned_stars > 0 else Color("758092")
	best_time.text = "TERBAIK: " + _format_time(time_seconds)
	best_time.modulate = Color("e6f3ff") if time_seconds >= 0 else Color("9aa6b8")
	button.modulate = Color.WHITE if unlocked else Color(0.62, 0.65, 0.72, 1.0)

func _star_text(count: int) -> String:
	return "★ ".repeat(clampi(count, 0, 3)).strip_edges() + (" ☆".repeat(3 - clampi(count, 0, 3)))

func _format_time(total_seconds: int) -> String:
	if total_seconds < 0:
		return "--:--"
	return "%02d:%02d" % [floori(float(total_seconds) / 60.0), total_seconds % 60]

func _play_entrance(button: TextureButton, index: int) -> void:
	var target_position := button.position
	button.position += Vector2(-45, 0)
	button.modulate.a = 0.0
	var intro := create_tween().set_parallel(true)
	intro.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	intro.tween_property(button, "position", target_position, 0.38).set_delay(0.12 + index * 0.13)
	intro.tween_property(button, "modulate:a", 1.0, 0.28).set_delay(0.12 + index * 0.13)

func _select_level(index: int) -> void:
	if index > GameData.unlocked_level:
		return
	_selected_level = index
	for card_index in level_buttons.size():
		var card := level_buttons[card_index]
		card.pivot_offset = card.size * 0.5
		var target_scale := Vector2(1.06, 1.06) if card_index == index else Vector2.ONE
		var select_tween := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		select_tween.tween_property(card, "scale", target_scale, 0.16)
		(card.get_node("Selected") as Label).visible = card_index == index
	play_button.disabled = false
