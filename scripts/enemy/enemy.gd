# enemy.gd
# Logika deteksi interaksi enemy ↔ player.
# Collision detection pakai distance (simple, tidak butuh Area2D).

class_name Enemy
extends Node2D

@onready var sprite: AnimatedSprite2D = find_child("AnimatedSprite2D", true, false) as AnimatedSprite2D

@export var patrol_enabled := false
@export var patrol_distance := 110.0
@export var patrol_speed := 65.0

var _start_x := 0.0
var _direction := 1.0

func _ready() -> void:
	_start_x = position.x
	if sprite != null and sprite.sprite_frames != null:
		sprite.play("walk" if patrol_enabled else "idle")

func _process(delta: float) -> void:
	if not patrol_enabled:
		return
	position.x += _direction * patrol_speed * delta
	if abs(position.x - _start_x) >= patrol_distance:
		position.x = _start_x + patrol_distance * _direction
		_direction *= -1.0
		if sprite:
			sprite.flip_h = _direction < 0.0

# ─────────────────────────────────────────
#  Konstanta — edit untuk tuning feel
# ─────────────────────────────────────────
const STOMP_RADIUS  := 42.0   # radius stomp (piksel)
const TOUCH_RADIUS  := 38.0   # radius damage ke player
const STOMP_MIN_VEL := 60.0   # minimum velocity.y player agar dihitung stomp

# ─────────────────────────────────────────
#  Cek apakah player menginjak enemy dari atas
# ─────────────────────────────────────────
func can_be_stomped(player: CharacterBody2D) -> bool:
	return (
		player.position.distance_to(position) < STOMP_RADIUS
		and player.velocity.y > STOMP_MIN_VEL
		and player.position.y < position.y
	)

# ─────────────────────────────────────────
#  Cek apakah enemy menyentuh player (player kena damage)
# ─────────────────────────────────────────
func touches(player: CharacterBody2D) -> bool:
	return player.position.distance_to(position) < TOUCH_RADIUS
