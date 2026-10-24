@tool
extends AnimatedSprite2D

## Pembagi sprite sheet boss 4 x 3.
## Baris 1 = spawn, baris 2 = idle, baris 3 = death.
## Ganti tekstur atau skala dari Inspector, lalu tekan "Bangun SpriteFrames".

@export var sheet_texture: Texture2D:
	set(value):
		sheet_texture = value
		if is_inside_tree():
			_build_sprite_frames()

@export var display_scale := Vector2(0.28, 0.28):
	set(value):
		display_scale = value
		scale = value

@export_tool_button("Bangun SpriteFrames", "Reload") var rebuild_sprite_frames = _build_sprite_frames

const FRAME_COLUMNS := 4
const FRAME_ROWS := 3
const ANIMATION_ROWS := {
	&"spawn": 0,
	&"idle": 1,
	&"death": 2,
}

func _ready() -> void:
	_build_sprite_frames()

func _build_sprite_frames() -> void:
	if sheet_texture == null:
		return

	var frames := SpriteFrames.new()
	if frames.has_animation(&"default"):
		frames.remove_animation(&"default")

	var cell_width := float(sheet_texture.get_width()) / FRAME_COLUMNS
	var cell_height := float(sheet_texture.get_height()) / FRAME_ROWS
	for animation_name in ANIMATION_ROWS:
		frames.add_animation(animation_name)
		frames.set_animation_speed(animation_name, 4.0)
		frames.set_animation_loop(animation_name, animation_name == &"idle")
		var row: int = ANIMATION_ROWS[animation_name]
		for column in FRAME_COLUMNS:
			var frame := AtlasTexture.new()
			frame.atlas = sheet_texture
			frame.region = Rect2(column * cell_width, row * cell_height, cell_width, cell_height)
			frames.add_frame(animation_name, frame)

	sprite_frames = frames
	scale = display_scale
	play(&"idle")
	notify_property_list_changed()
