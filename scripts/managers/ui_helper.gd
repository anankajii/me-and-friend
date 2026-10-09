# ui_helper.gd
# Utilitas pembuatan node UI agar script lain lebih bersih.
# Tidak perlu di-attach ke node, cukup di-load sebagai static class.

class_name UIHelper
extends RefCounted

static func label(text: String, font_size := 24) -> Label:
	var node := Label.new()
	node.text = text
	node.add_theme_font_size_override("font_size", font_size)
	node.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return node

static func button(text: String, pos: Vector2, size: Vector2, font_size := 22, action: Callable = Callable()) -> Button:
	var node := Button.new()
	node.text = text
	node.position = pos
	node.size = size
	node.add_theme_font_size_override("font_size", font_size)
	if action.is_valid():
		node.pressed.connect(action)
	return node

static func full_bg(color: Color) -> ColorRect:
	var rect := ColorRect.new()
	rect.color = color
	rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return rect
