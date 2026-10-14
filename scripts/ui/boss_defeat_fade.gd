class_name BossDefeatFade
extends CanvasLayer

signal covered

@onready var overlay: ColorRect = $Overlay

func cover_screen() -> void:
	overlay.color.a = 0.0
	show()
	var tween := create_tween()
	tween.tween_property(overlay, "color:a", 1.0, 0.32).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await tween.finished
	covered.emit()

func reveal_result() -> void:
	var tween := create_tween()
	tween.tween_property(overlay, "color:a", 0.0, 0.28).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await tween.finished
	queue_free()
