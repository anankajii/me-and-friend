class_name PauseMenu
extends Control

signal restart_requested
signal main_menu_requested

@onready var pause_button: TextureButton = $PauseButton
@onready var overlay: Control = $PauseOverlay
@onready var menu_buttons: Control = $PauseOverlay/Panel/MenuButtons
@onready var settings_panel: Control = $PauseOverlay/Panel/SettingsPanel
@onready var music_slider: HSlider = $PauseOverlay/Panel/SettingsPanel/MusicSlider
@onready var sfx_slider: HSlider = $PauseOverlay/Panel/SettingsPanel/SfxSlider

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	pause_button.pressed.connect(open_pause)
	$PauseOverlay/Panel/MenuButtons/ResumeButton.pressed.connect(close_pause)
	$PauseOverlay/Panel/MenuButtons/RestartButton.pressed.connect(_restart_level)
	$PauseOverlay/Panel/MenuButtons/SettingsButton.pressed.connect(_show_settings)
	$PauseOverlay/Panel/MenuButtons/MainMenuButton.pressed.connect(_return_to_menu)
	$PauseOverlay/Panel/SettingsPanel/BackButton.pressed.connect(_hide_settings)
	_setup_audio_controls()
	for button in [pause_button, $PauseOverlay/Panel/MenuButtons/ResumeButton, $PauseOverlay/Panel/MenuButtons/RestartButton, $PauseOverlay/Panel/MenuButtons/SettingsButton, $PauseOverlay/Panel/MenuButtons/MainMenuButton, $PauseOverlay/Panel/SettingsPanel/BackButton]:
		_add_button_animation(button)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if overlay.visible:
			close_pause()
		else:
			open_pause()
		get_viewport().set_input_as_handled()

func open_pause() -> void:
	if overlay.visible:
		return
	settings_panel.visible = false
	menu_buttons.visible = true
	overlay.visible = true
	overlay.modulate.a = 0.0
	get_tree().paused = true
	create_tween().tween_property(overlay, "modulate:a", 1.0, 0.18)

func close_pause() -> void:
	get_tree().paused = false
	overlay.visible = false

func _restart_level() -> void:
	get_tree().paused = false
	restart_requested.emit()

func _return_to_menu() -> void:
	get_tree().paused = false
	main_menu_requested.emit()

func _show_settings() -> void:
	menu_buttons.visible = false
	settings_panel.visible = true

func _hide_settings() -> void:
	settings_panel.visible = false
	menu_buttons.visible = true

func _setup_audio_controls() -> void:
	_ensure_audio_bus(&"Music")
	_ensure_audio_bus(&"SFX")
	music_slider.value = _get_bus_percent(&"Music")
	sfx_slider.value = _get_bus_percent(&"SFX")
	music_slider.value_changed.connect(_set_bus_volume.bind(&"Music"))
	sfx_slider.value_changed.connect(_set_bus_volume.bind(&"SFX"))

func _add_button_animation(button: BaseButton) -> void:
	button.pivot_offset = button.size * 0.5
	button.mouse_entered.connect(func():
		create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT).tween_property(button, "scale", Vector2(1.045, 1.045), 0.14)
	)
	button.mouse_exited.connect(func():
		create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT).tween_property(button, "scale", Vector2.ONE, 0.12)
	)
	button.button_down.connect(func(): button.scale = Vector2(0.97, 0.97))
	button.button_up.connect(func(): button.scale = Vector2(1.045, 1.045))

func _ensure_audio_bus(bus_name: StringName) -> void:
	if AudioServer.get_bus_index(bus_name) >= 0:
		return
	AudioServer.add_bus()
	AudioServer.set_bus_name(AudioServer.bus_count - 1, bus_name)

func _get_bus_percent(bus_name: StringName) -> float:
	var index := AudioServer.get_bus_index(bus_name)
	if index < 0 or AudioServer.is_bus_mute(index):
		return 0.0
	return clamp(db_to_linear(AudioServer.get_bus_volume_db(index)) * 100.0, 0.0, 100.0)

func _set_bus_volume(value: float, bus_name: StringName) -> void:
	var index := AudioServer.get_bus_index(bus_name)
	if index < 0:
		return
	AudioServer.set_bus_mute(index, value <= 0.0)
	AudioServer.set_bus_volume_db(index, linear_to_db(max(value / 100.0, 0.001)))
