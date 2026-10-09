class_name Boss
extends Node2D

@onready var sprite: AnimatedSprite2D = find_child("AnimatedSprite2D", true, false) as AnimatedSprite2D

func _ready() -> void:
	if sprite == null or sprite.sprite_frames == null:
		return
	if sprite.sprite_frames.has_animation("spawn"):
		sprite.sprite_frames.set_animation_loop("spawn", false)
	if sprite.sprite_frames.has_animation("death"):
		sprite.sprite_frames.set_animation_loop("death", false)
	play_idle()

func play_spawn() -> void:
	if not _can_play("spawn"):
		return
	sprite.play("spawn")
	await sprite.animation_finished
	play_idle()

func play_death() -> void:
	if not _can_play("death"):
		return
	sprite.play("death")
	await sprite.animation_finished
	visible = false

func play_idle() -> void:
	if _can_play("idle"):
		sprite.play("idle")

func _can_play(animation_name: StringName) -> bool:
	return sprite != null \
		and sprite.sprite_frames != null \
		and sprite.sprite_frames.has_animation(animation_name)
