class_name Player
extends CharacterBody2D

# ─────────────────────────────────────────
#  Konstanta gerakan — edit di sini untuk tweak feel
# ─────────────────────────────────────────
const SPEED         := 300.0
const JUMP_VELOCITY := -680.0
const GRAVITY       := 1300.0

@onready var sprite: AnimatedSprite2D = find_child("AnimatedSprite2D", true, false) as AnimatedSprite2D

# ─────────────────────────────────────────
#  Dipanggil dari main.gd setelah instantiate,
#  untuk mengaplikasikan data karakter yang dipilih.
# ─────────────────────────────────────────
func apply_character(_char_data: Dictionary) -> void:
	# SpriteFrames adalah milik scene karakter masing-masing, bukan dibuat ulang oleh kode.
	if sprite != null and sprite.sprite_frames != null and sprite.sprite_frames.has_animation("idle"):
		sprite.visible = true
		sprite.play("idle")

# ─────────────────────────────────────────
#  Physics — dipanggil dari _physics_process main.gd
# ─────────────────────────────────────────
func move_player(delta: float) -> void:
	if not is_on_floor():
		velocity.y += GRAVITY * delta

	var direction := Input.get_axis("ui_left", "ui_right")
	if Input.is_key_pressed(KEY_A): direction = -1.0
	if Input.is_key_pressed(KEY_D): direction =  1.0

	velocity.x = move_toward(velocity.x, direction * SPEED, 1800.0 * delta)

	var jump_pressed := Input.is_action_just_pressed("ui_accept") \
		or Input.is_action_just_pressed("ui_up") \
		or Input.is_key_pressed(KEY_SPACE)
	if jump_pressed and is_on_floor():
		velocity.y = JUMP_VELOCITY

	move_and_slide()
	_update_animation(direction)

# ─────────────────────────────────────────
#  Animasi
# ─────────────────────────────────────────
var _animation_locked := false

func _update_animation(direction: float) -> void:
	if sprite == null or not sprite.visible or _animation_locked: return
	if not is_on_floor() and sprite.sprite_frames.has_animation("jump"):
		sprite.play("jump")
	elif direction != 0.0:
		sprite.flip_h = direction < 0.0
		sprite.play("walk")
	else:
		sprite.play("idle")

func show_damage() -> void:
	_play_locked("damaged", 0.45)

func show_idle() -> void:
	_animation_locked = false
	if sprite == null or not sprite.sprite_frames.has_animation("idle"):
		return
	sprite.play("idle")

func show_coding() -> void:
	_play_locked("coding", 0.6)

func _play_locked(animation_name: String, seconds: float) -> void:
	if sprite == null or not sprite.sprite_frames.has_animation(animation_name): return
	_animation_locked = true
	sprite.play(animation_name)
	get_tree().create_timer(seconds).timeout.connect(func(): _animation_locked = false)
