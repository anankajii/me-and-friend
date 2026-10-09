# coin.gd
# Koin yang bisa dipungut player.
# Pickup dihandle dari main.gd pakai distance check.

class_name Coin
extends Area2D

@onready var sprite: AnimatedSprite2D = find_child("AnimatedSprite2D", true, false) as AnimatedSprite2D

func _ready() -> void:
	if sprite != null and sprite.sprite_frames != null:
		sprite.play()
