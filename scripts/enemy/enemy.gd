# enemy.gd
# Logika deteksi interaksi enemy ↔ player.
# Collision detection pakai distance (simple, tidak butuh Area2D).

class_name Enemy
extends CharacterBody2D

const ProjectileScene := preload("res://scenes/enemies/EnemyProjectile.tscn")

signal projectile_hit

@onready var sprite: AnimatedSprite2D = find_child("AnimatedSprite2D", true, false) as AnimatedSprite2D
@onready var hit_area: Area2D = $HitArea

@export var patrol_enabled := false
@export var patrol_distance := 110.0
@export var patrol_speed := 65.0
@export var shoot_enabled := false
@export var shoot_range := 640.0
@export var shoot_cooldown := 1.75
@export_range(1, 3, 2) var projectile_count := 1
@export var triple_shot_spacing := 38.0

var _start_x := 0.0
var _direction := 1.0
var _shot_timer := 0.0

func _ready() -> void:
	_start_x = position.x
	if sprite != null and sprite.sprite_frames != null:
		sprite.play("walk" if patrol_enabled else "idle")

func _process(delta: float) -> void:
	if patrol_enabled:
		position.x += _direction * patrol_speed * delta
		if abs(position.x - _start_x) >= patrol_distance:
			position.x = _start_x + patrol_distance * _direction
			_direction *= -1.0
			if sprite:
				sprite.flip_h = _direction < 0.0
	if shoot_enabled:
		_update_shooting(delta)

func _update_shooting(delta: float) -> void:
	_shot_timer = maxf(_shot_timer - delta, 0.0)
	var player := get_tree().get_first_node_in_group("player") as CharacterBody2D
	if player == null or not is_instance_valid(player):
		return
	var horizontal_distance := absf(player.global_position.x - global_position.x)
	if horizontal_distance > shoot_range or _shot_timer > 0.0:
		return
	_fire_horizontal_projectiles()
	_shot_timer = shoot_cooldown

func _fire_horizontal_projectiles() -> void:
	# Proyektil melaju lurus ke depan sesuai arah enemy, tanpa membidik pemain.
	var offsets: Array[float] = [0.0]
	if projectile_count == 3:
		offsets = [-triple_shot_spacing, 0.0, triple_shot_spacing]
	var direction := Vector2.RIGHT if _direction >= 0.0 else Vector2.LEFT
	for y_offset in offsets:
		var projectile = ProjectileScene.instantiate()
		projectile.global_position = global_position + Vector2(direction.x * 30.0, y_offset - 24.0)
		get_parent().add_child(projectile)
		projectile.launch(direction)
		projectile.hit_player.connect(func(): projectile_hit.emit())

# ─────────────────────────────────────────
#  Konstanta — edit untuk tuning feel
# ─────────────────────────────────────────
const STOMP_RADIUS  := 42.0   # radius stomp (piksel)
const STOMP_MIN_VEL := 60.0   # minimum velocity.y player agar dihitung stomp
const PLAYER_HALF_SIZE := Vector2(45.0, 75.0)
const ENEMY_HALF_SIZE := Vector2(26.0, 20.0)

# ─────────────────────────────────────────
#  Cek apakah player menginjak enemy dari atas
# ─────────────────────────────────────────
func can_be_stomped(player: CharacterBody2D) -> bool:
	# Player sekarang bertabrakan fisik dengan enemy. Saat mendarat dari atas,
	# velocity.y sudah menjadi 0, jadi gunakan normal tabrakan sebagai acuan.
	for index in player.get_slide_collision_count():
		var collision := player.get_slide_collision(index)
		if collision.get_collider() == self and collision.get_normal().y < -0.7:
			return true
	# Fallback untuk frame sebelum collision fisik terbaca.
	return (
		player.global_position.distance_to(global_position) < STOMP_RADIUS
		and player.velocity.y > STOMP_MIN_VEL
		and player.global_position.y < global_position.y
	)

# ─────────────────────────────────────────
#  Cek apakah enemy menyentuh player (player kena damage)
# ─────────────────────────────────────────
func touches(player: CharacterBody2D) -> bool:
	if hit_area != null and hit_area.overlaps_body(player):
		return true
	var delta := (player.global_position - global_position).abs()
	return delta.x <= PLAYER_HALF_SIZE.x + ENEMY_HALF_SIZE.x \
		and delta.y <= PLAYER_HALF_SIZE.y + ENEMY_HALF_SIZE.y
