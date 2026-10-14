class_name LevelResult
extends CanvasLayer

signal action_requested(won: bool)

@onready var title: Label = $UI/Title
@onready var coin_value: Label = $UI/CoinValue
@onready var time_value: Label = $UI/TimeValue
@onready var button_caption: Label = $UI/NextButton/Label
@onready var stars: Array[TextureRect] = [$UI/Star1, $UI/Star2, $UI/Star3]

var _pending_setup: Array = []

func _ready() -> void:
	if not _pending_setup.is_empty():
		setup(_pending_setup[0], _pending_setup[1], _pending_setup[2], _pending_setup[3], _pending_setup[4])
		_pending_setup.clear()

func setup(won: bool, earned_coins: int, total_coins: int, elapsed_seconds: int, action_label := "") -> void:
	if not is_node_ready():
		_pending_setup = [won, earned_coins, total_coins, elapsed_seconds, action_label]
		return
	var star_count := _star_count(won, earned_coins, total_coins)
	title.text = "LEVEL SELESAI!" if won else "LEVEL GAGAL"
	coin_value.text = "%d / %d" % [earned_coins, total_coins]
	time_value.text = _format_time(elapsed_seconds)
	button_caption.text = action_label if not action_label.is_empty() else ("LEVEL BERIKUTNYA" if won else "ULANGI LEVEL")
	_animate_stars(star_count)

func _star_count(won: bool, earned: int, total: int) -> int:
	if not won or total <= 0:
		return 0
	var ratio := float(earned) / float(total)
	if ratio >= 1.0:
		return 3
	if ratio >= 0.65:
		return 2
	return 1

func _animate_stars(filled_count: int) -> void:
	for index in stars.size():
		var star := stars[index]
		star.scale = Vector2.ZERO
		star.modulate = Color.WHITE if index < filled_count else Color(0.23, 0.28, 0.38, 0.9)
		var tween := create_tween()
		tween.tween_interval(0.2 + index * 0.24)
		tween.tween_property(star, "scale", Vector2.ONE, 0.38).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		if index < filled_count:
			tween.tween_property(star, "rotation", 0.09, 0.08)
			tween.tween_property(star, "rotation", 0.0, 0.1)

func _format_time(total_seconds: int) -> String:
	var minutes := floori(float(total_seconds) / 60.0)
	return "%02d:%02d" % [minutes, total_seconds % 60]

func _on_next_button_pressed() -> void:
	action_requested.emit(title.text == "LEVEL SELESAI!")
