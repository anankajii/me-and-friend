class_name QuestionBlock
extends StaticBody2D

## Blok hadiah. Letakkan manual dalam scene level, lalu pukul dari bawah saat lompat.
const CoinScene := preload("res://scenes/enemies/Coin.tscn")
const EnemyScene := preload("res://scenes/enemies/Enemy.tscn")

signal reward_spawned(reward: Node)

@export_enum("Coin", "Enemy") var reward_type := "Coin"
@export_range(1, 3, 1) var coin_count := 1
@export var enemy_patrol := true
# Musuh keluar dari atas block, lalu jatuh mengikuti gravitasi seperti hadiah Mario.
# Nilai ini tetap diekspor agar posisi hadiah dapat diatur manual dari Inspector.
@export var enemy_spawn_offset := Vector2(0, -82)

@onready var sprite: Sprite2D = $Sprite2D

var _used := false
var _hit_cooldown := 0.0
var _sprite_rest_y := 0.0
var _player_last_vel_y := 0.0

func _ready() -> void:
	_sprite_rest_y = sprite.position.y

func _physics_process(delta: float) -> void:
	_hit_cooldown = maxf(0.0, _hit_cooldown - delta)
	var player := get_tree().get_first_node_in_group("player") as CharacterBody2D
	if player == null or not is_instance_valid(player):
		return
	# Cadangan bila blok dipakai tanpa controller Main.
	if not _used and _hit_cooldown <= 0.0:
		var horizontal_gap := absf(player.global_position.x - global_position.x)
		var vertical_gap := player.global_position.y - global_position.y
		# _player_last_vel_y: velocity SEBELUM move_and_slide zeroed it on ceiling hit
		if horizontal_gap <= 52.0 and vertical_gap >= 10.0 and vertical_gap <= 150.0 and _player_last_vel_y < -30.0:
			activate_from_below()
	_player_last_vel_y = player.velocity.y

## Dipanggil controller level setelah CharacterBody2D benar-benar menabrak
## bagian bawah block. Public agar QuestionBlock tetap dapat dipakai manual.
func activate_from_below() -> void:
	if _used or _hit_cooldown > 0.0:
		return
	_used = true
	_hit_cooldown = 0.28
	var bump := create_tween()
	bump.tween_property(sprite, "position:y", _sprite_rest_y - 9.0, 0.07)
	bump.tween_property(sprite, "position:y", _sprite_rest_y, 0.11)
	_spawn_reward()
	sprite.modulate = Color(0.72, 0.72, 0.72, 1.0)

func _spawn_reward() -> void:
	if reward_type == "Coin":
		for index in coin_count:
			var coin := CoinScene.instantiate() as Area2D
			add_sibling(coin)
			coin.global_position = global_position + Vector2((index - (coin_count - 1) * 0.5) * 28.0, -58.0)
			reward_spawned.emit(coin)
		return
	var enemy := EnemyScene.instantiate() as Enemy
	add_sibling(enemy)
	enemy.global_position = global_position + enemy_spawn_offset
	enemy.patrol_enabled = enemy_patrol
	enemy.shoot_enabled = false
	reward_spawned.emit(enemy)
