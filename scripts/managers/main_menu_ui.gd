class_name MainMenuUI
extends CanvasLayer

signal play_requested

@onready var title: TextureRect = $UI/Title
@onready var subtitle: Label = $UI/Subtitle
@onready var main_button: TextureButton = $UI/Buttons/MainButton
@onready var setting_button: TextureButton = $UI/Buttons/SettingButton
@onready var quit_button: TextureButton = $UI/Buttons/QuitButton
@onready var controls: Label = $UI/Controls
@onready var overlay: ColorRect = $UI/Overlay
@onready var settings_panel: Control = $UI/SettingsPanel
@onready var character_previews: Node2D = $UI/Characters
@onready var music_slider: HSlider = $UI/SettingsPanel/MusicSlider
@onready var sfx_slider: HSlider = $UI/SettingsPanel/SfxSlider

var _title_position: Vector2
var _button_positions: Array[Vector2] = []

func _ready() -> void:
	AudioManager.play_background_music()
	_title_position = title.position
	var buttons := [main_button, setting_button, quit_button]
	for button in buttons:
		_button_positions.append(button.position)
		button.mouse_entered.connect(_animate_button_hover.bind(button, true))
		button.mouse_exited.connect(_animate_button_hover.bind(button, false))
	main_button.pressed.connect(_on_play_pressed)
	setting_button.pressed.connect(_show_settings)
	quit_button.pressed.connect(func(): get_tree().quit())
	$UI/SettingsPanel/BackButton.pressed.connect(_hide_settings)
	_setup_audio_controls()
	_setup_character_preview()
	play_intro()

func play_intro() -> void:
	title.position = _title_position + Vector2(0, -35)
	title.modulate.a = 0.0
	subtitle.modulate.a = 0.0
	var buttons := [main_button, setting_button, quit_button]
	for i in buttons.size():
		buttons[i].position = _button_positions[i] + Vector2(0, 35)
		buttons[i].modulate.a = 0.0
	controls.modulate.a = 0.0
	overlay.modulate.a = 0.0

	create_tween().tween_property(overlay, "modulate:a", 1.0, 0.8)
	var title_tween := create_tween().set_parallel(true)
	title_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	title_tween.tween_property(title, "position", _title_position, 0.8).set_delay(0.15)
	title_tween.tween_property(title, "modulate:a", 1.0, 0.5).set_delay(0.15)
	create_tween().tween_property(subtitle, "modulate:a", 1.0, 0.6).set_delay(0.55)

	for i in buttons.size():
		var button_tween := create_tween().set_parallel(true)
		button_tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		button_tween.tween_property(buttons[i], "position", _button_positions[i], 0.65).set_delay(0.7 + i * 0.12)
		button_tween.tween_property(buttons[i], "modulate:a", 1.0, 0.45).set_delay(0.7 + i * 0.12)
	create_tween().tween_property(controls, "modulate:a", 0.75, 0.7).set_delay(1.1)

func _animate_button_hover(button: Control, hovered: bool) -> void:
	var target_scale := Vector2(1.06, 1.06) if hovered else Vector2.ONE
	create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT) \
		.tween_property(button, "scale", target_scale, 0.16)

func _on_play_pressed() -> void:
	AudioManager.play_sfx(&"game_start")
	play_requested.emit()

func _show_settings() -> void:
	settings_panel.visible = true
	settings_panel.modulate.a = 0.0
	create_tween().tween_property(settings_panel, "modulate:a", 1.0, 0.2)

func _hide_settings() -> void:
	settings_panel.visible = false

func _setup_character_preview() -> void:
	var previews := character_previews.get_children()
	for preview_node in previews:
		var preview := preview_node as Node2D
		var preview_sprite := preview.find_child("AnimatedSprite2D", true, false) as AnimatedSprite2D
		if preview_sprite and preview_sprite.sprite_frames.has_animation("idle"):
			# Preview Main Menu harus benar-benar diam pada pose idle pertama.
			preview_sprite.stop()
			preview_sprite.animation = &"idle"
			preview_sprite.frame = 0

func _setup_audio_controls() -> void:
	music_slider.value = AudioManager.get_bus_volume(&"Music")
	sfx_slider.value = AudioManager.get_bus_volume(&"SFX")
	music_slider.value_changed.connect(_set_bus_volume.bind("Music"))
	sfx_slider.value_changed.connect(_set_bus_volume.bind("SFX"))

func _set_bus_volume(value: float, bus_name: String) -> void:
	AudioManager.set_bus_volume(value, StringName(bus_name))
