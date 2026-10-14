class_name CharacterSelectUI
extends CanvasLayer

signal character_selected(character_id: String)
signal back_requested

const CARD_NORMAL := preload("res://assets/ui/character_cards/normal.png")
const CARD_SELECTED := preload("res://assets/ui/character_cards/selected.png")

@onready var start_button: TextureButton = $UI/StartButton
@onready var preview_root: Node2D = $UI/PreviewCharacters
@onready var preview_name: Label = $UI/PreviewName
@onready var preview_trait: Label = get_node_or_null("UI/PreviewTrait") as Label

var selected_id := "Khanan"
var _cards: Dictionary = {}

func _ready() -> void:
	for id in ["Khanan", "Jeki", "Bayu", "Reni", "Ervania", "Laras"]:
		var card := get_node("UI/Cards/" + id + "Card") as Control
		_cards[id] = card
		card.get_node("SelectButton").pressed.connect(_select_character.bind(id))
	start_button.pressed.connect(func(): character_selected.emit(selected_id))
	$UI/BackButton.pressed.connect(func(): back_requested.emit())
	_select_character(selected_id)

func _select_character(id: String) -> void:
	selected_id = id
	for card_id in _cards:
		var card := _cards[card_id] as Control
		var selected: bool = str(card_id) == id
		(card.get_node("CardBackground") as TextureRect).texture = CARD_SELECTED if selected else CARD_NORMAL
		card.get_node("Check").visible = selected
		card.get_node("Name").add_theme_color_override("font_color", Color("3a2100") if selected else Color.WHITE)
		var trait_label := card.get_node_or_null("Trait") as Label
		if trait_label:
			trait_label.add_theme_color_override("font_color", Color("744400") if selected else Color("d9e8ff"))
		card.z_index = 2 if selected else 0
		if selected:
			card.pivot_offset = card.size * 0.5
			card.scale = Vector2(0.94, 0.94)
			var tween := create_tween().set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
			tween.tween_property(card, "scale", Vector2.ONE, 0.22)
	_update_preview(id)

func _update_preview(id: String) -> void:
	for preview in preview_root.get_children():
		var active := preview.name == id
		preview.visible = active
		if active:
			_play_idle(preview)
	preview_name.text = id.to_upper()
	if preview_trait:
		preview_trait.text = {
			"Khanan": "SIAP MEMIMPIN PETUALANGAN",
			"Jeki": "TENANG DAN FOKUS",
			"Bayu": "CEPAT DAN PENUH ENERGI",
			"Reni": "CERDAS MEMECAHKAN BUG",
			"Ervania": "BERANI MENGHADAPI TANTANGAN",
			"Laras": "LINCAH DAN PENUH IDE",
		}.get(id, "SIAP BERTUALANG") as String

func _play_idle(root: Node) -> void:
	var sprite := root.find_child("AnimatedSprite2D", true, false) as AnimatedSprite2D
	if sprite and sprite.sprite_frames.has_animation("idle"):
		sprite.play("idle")
