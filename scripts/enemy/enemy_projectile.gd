class_name EnemyProjectile
extends Node2D

signal hit_player

@export var speed := 310.0
@export var lifetime := 3.0
@export var hit_radius := 24.0

var _direction := Vector2.RIGHT
var _remaining_life := 0.0

func _ready() -> void:
	_remaining_life = lifetime

func launch(direction: Vector2) -> void:
	_direction = direction.normalized() if direction.length_squared() > 0.0 else Vector2.RIGHT
	rotation = _direction.angle()

func _process(delta: float) -> void:
	global_position += _direction * speed * delta
	_remaining_life -= delta
	if _remaining_life <= 0.0:
		queue_free()
		return
	var player := get_tree().get_first_node_in_group("player") as CharacterBody2D
	if player != null and is_instance_valid(player) and global_position.distance_to(player.global_position) <= hit_radius:
		hit_player.emit()
		queue_free()
