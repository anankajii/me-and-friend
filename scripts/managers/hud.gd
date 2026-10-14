class_name HUD
extends CanvasLayer

signal restart_requested
signal main_menu_requested

const HEART_FULL := preload("res://assets/ui/hud/heart_full.png")
const HEART_EMPTY := preload("res://assets/ui/hud/heart_empty.png")
const COIN_ICON := preload("res://assets/ui/hud/coin.png")

var _status_label: Label
var _heart_icons: Array[TextureRect] = []
var _coin_label: Label
var _message_label: Label
var _message_timer: SceneTreeTimer
var _pause_overlay: Control
var _menu_buttons: Control
var _settings_panel: Control

func setup() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_build_status()
	_build_pause_button()
	_build_pause_menu()

func _build_status() -> void:
	_status_label = Label.new()
	_status_label.position = Vector2(205, 21)
	_status_label.size = Vector2(165, 35)
	_status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	_status_label.add_theme_font_size_override("font_size", 20)
	_status_label.add_theme_color_override("font_color", Color("fff3a8"))
	_status_label.add_theme_color_override("font_outline_color", Color("17233d"))
	_status_label.add_theme_constant_override("outline_size", 5)
	add_child(_status_label)

	for index in range(3):
		var heart := _hud_icon(HEART_FULL, Vector2(374 + index * 34, 18), Vector2(30, 30))
		_heart_icons.append(heart)
		add_child(heart)

	var coin := _hud_icon(COIN_ICON, Vector2(490, 17), Vector2(32, 32))
	add_child(coin)
	_coin_label = Label.new()
	_coin_label.position = Vector2(526, 21)
	_coin_label.size = Vector2(110, 35)
	_coin_label.add_theme_font_size_override("font_size", 20)
	_coin_label.add_theme_color_override("font_color", Color("fff3a8"))
	_coin_label.add_theme_color_override("font_outline_color", Color("17233d"))
	_coin_label.add_theme_constant_override("outline_size", 5)
	add_child(_coin_label)

	_message_label = Label.new()
	_message_label.position = Vector2(260, 70)
	_message_label.size = Vector2(620, 90)
	_message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_message_label.add_theme_font_size_override("font_size", 28)
	_message_label.add_theme_color_override("font_color", Color("ffffff"))
	_message_label.add_theme_color_override("font_outline_color", Color("18223b"))
	_message_label.add_theme_constant_override("outline_size", 7)
	add_child(_message_label)

func _hud_icon(texture: Texture2D, icon_position: Vector2, icon_size: Vector2) -> TextureRect:
	var icon := TextureRect.new()
	icon.position = icon_position
	icon.size = icon_size
	icon.texture = texture
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return icon

func _build_pause_button() -> void:
	var pause_button := _texture_button("continue", "Ⅱ  PAUSE")
	pause_button.name = "PauseButton"
	pause_button.set_anchors_preset(Control.PRESET_TOP_LEFT)
	pause_button.offset_left = 18.0
	pause_button.offset_top = 16.0
	pause_button.offset_right = 190.0
	pause_button.offset_bottom = 51.0
	_add_button_animation(pause_button)
	pause_button.pressed.connect(_open_pause)
	add_child(pause_button)

func _build_pause_menu() -> void:
	_pause_overlay = Control.new()
	_pause_overlay.name = "PauseOverlay"
	_pause_overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_pause_overlay.visible = false
	add_child(_pause_overlay)

	var dim := ColorRect.new()
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	dim.color = Color(0.01, 0.02, 0.08, 0.78)
	dim.mouse_filter = Control.MOUSE_FILTER_STOP
	_pause_overlay.add_child(dim)

	var panel := TextureRect.new()
	panel.name = "Panel"
	panel.set_anchors_preset(Control.PRESET_CENTER)
	panel.offset_left = -230.0
	panel.offset_top = -276.0
	panel.offset_right = 230.0
	panel.offset_bottom = 276.0
	panel.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.texture = load("res://assets/ui/pause_v2/pause_panel.png") as Texture2D
	panel.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	panel.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	panel.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_pause_overlay.add_child(panel)

	var title := Label.new()
	title.position = Vector2(38, 25)
	title.size = Vector2(384, 58)
	title.text = "GAME DI-PAUSE"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 29)
	title.add_theme_color_override("font_color", Color("fff0b0"))
	title.add_theme_color_override("font_outline_color", Color("4c210e"))
	title.add_theme_constant_override("outline_size", 6)
	panel.add_child(title)

	_menu_buttons = Control.new()
	_menu_buttons.name = "MenuButtons"
	_menu_buttons.position = Vector2.ZERO
	panel.add_child(_menu_buttons)
	_menu_buttons.add_child(_menu_button("LANJUTKAN", 96, Color("1f8c68"), _close_pause))
	_menu_buttons.add_child(_menu_button("ULANGI LEVEL", 184, Color("2367a8"), _restart_level))
	_menu_buttons.add_child(_menu_button("PENGATURAN", 272, Color("7148a8"), _show_settings))
	_menu_buttons.add_child(_menu_button("MENU UTAMA", 360, Color("a83c4c"), _return_to_menu))

	_settings_panel = Control.new()
	_settings_panel.name = "SettingsPanel"
	_settings_panel.visible = false
	panel.add_child(_settings_panel)

	var settings_title := Label.new()
	settings_title.position = Vector2(55, 100)
	settings_title.size = Vector2(330, 45)
	settings_title.text = "PENGATURAN AUDIO"
	settings_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	settings_title.add_theme_font_size_override("font_size", 23)
	settings_title.add_theme_color_override("font_color", Color("d9c3ff"))
	_settings_panel.add_child(settings_title)

	_add_audio_slider(_settings_panel, "MUSIC", "Music", 165)
	_add_audio_slider(_settings_panel, "SOUND EFFECT", "SFX", 255)
	_settings_panel.add_child(_menu_button("KEMBALI", 370, Color("315f8e"), _hide_settings))

func _menu_button(text_value: String, top: float, _color: Color, callback: Callable) -> BaseButton:
	var button := _texture_button("continue" if text_value == "LANJUTKAN" else "standard", _button_caption(text_value))
	button.position = Vector2(45, top)
	button.size = Vector2(370, 80)
	_add_button_animation(button)
	button.pressed.connect(callback)
	return button

func _texture_button(asset_name: String, caption: String) -> TextureButton:
	var button := TextureButton.new()
	button.ignore_texture_size = true
	button.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	button.texture_normal = load("res://assets/ui/pause_v2/" + asset_name + ".png") as Texture2D
	button.texture_hover = button.texture_normal
	button.texture_pressed = button.texture_normal
	button.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var caption_label := Label.new()
	caption_label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	caption_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	caption_label.text = caption
	caption_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	caption_label.add_theme_font_size_override("font_size", 18)
	caption_label.add_theme_color_override("font_color", Color("fff5d7"))
	caption_label.add_theme_color_override("font_outline_color", Color("38200f"))
	caption_label.add_theme_constant_override("outline_size", 4)
	button.add_child(caption_label)
	return button

func _button_caption(text_value: String) -> String:
	return {
		"LANJUTKAN": "▶   LANJUTKAN",
		"ULANGI LEVEL": "↻   ULANGI LEVEL",
		"PENGATURAN": "⚙   PENGATURAN",
		"MENU UTAMA": "⌂   MENU UTAMA",
		"KEMBALI": "←   KEMBALI",
	}.get(text_value, text_value) as String

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

func _add_audio_slider(parent: Control, label_text: String, bus_name: String, top: float) -> void:
	_ensure_audio_bus(bus_name)
	var label := Label.new()
	label.position = Vector2(65, top)
	label.size = Vector2(310, 28)
	label.text = label_text
	label.add_theme_font_size_override("font_size", 17)
	label.add_theme_color_override("font_color", Color("9edcff") if bus_name == "Music" else Color("ffb2db"))
	parent.add_child(label)

	var slider := HSlider.new()
	slider.position = Vector2(65, top + 30)
	slider.size = Vector2(310, 30)
	slider.min_value = 0
	slider.max_value = 100
	slider.value = _get_bus_percent(bus_name)
	slider.value_changed.connect(_set_bus_volume.bind(bus_name))
	parent.add_child(slider)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		if _pause_overlay and _pause_overlay.visible:
			_close_pause()
		else:
			_open_pause()
		get_viewport().set_input_as_handled()

func _open_pause() -> void:
	if _pause_overlay == null or _pause_overlay.visible:
		return
	_settings_panel.visible = false
	_menu_buttons.visible = true
	_pause_overlay.visible = true
	_pause_overlay.modulate.a = 0.0
	get_tree().paused = true
	create_tween().tween_property(_pause_overlay, "modulate:a", 1.0, 0.18)

func _close_pause() -> void:
	get_tree().paused = false
	if _pause_overlay:
		_pause_overlay.visible = false

func _restart_level() -> void:
	get_tree().paused = false
	restart_requested.emit()

func _return_to_menu() -> void:
	get_tree().paused = false
	main_menu_requested.emit()

func _show_settings() -> void:
	_menu_buttons.visible = false
	_settings_panel.visible = true

func _hide_settings() -> void:
	_settings_panel.visible = false
	_menu_buttons.visible = true

func _ensure_audio_bus(bus_name: String) -> void:
	if AudioServer.get_bus_index(bus_name) >= 0:
		return
	AudioServer.add_bus()
	AudioServer.set_bus_name(AudioServer.bus_count - 1, bus_name)

func _get_bus_percent(bus_name: String) -> float:
	var index := AudioServer.get_bus_index(bus_name)
	if index < 0 or AudioServer.is_bus_mute(index):
		return 0.0
	return clamp(db_to_linear(AudioServer.get_bus_volume_db(index)) * 100.0, 0.0, 100.0)

func _set_bus_volume(value: float, bus_name: String) -> void:
	var index := AudioServer.get_bus_index(bus_name)
	if index < 0:
		return
	AudioServer.set_bus_mute(index, value <= 0.0)
	AudioServer.set_bus_volume_db(index, linear_to_db(max(value / 100.0, 0.001)))

func update(char_name: String, hp: int, coins: int) -> void:
	if _status_label:
		_status_label.text = char_name.to_upper()
	for index in _heart_icons.size():
		_heart_icons[index].texture = HEART_FULL if index < hp else HEART_EMPTY
	if _coin_label:
		_coin_label.text = "x %d" % coins

func show_message(text: String, seconds: float) -> void:
	if _message_label == null:
		return
	_message_label.text = text
	_message_timer = get_tree().create_timer(seconds)
	_message_timer.timeout.connect(func():
		if _message_label:
			_message_label.text = ""
	)

func clear_message() -> void:
	if _message_label:
		_message_label.text = ""
