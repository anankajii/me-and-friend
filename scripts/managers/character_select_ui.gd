class_name CharacterSelectUI
extends CanvasLayer

signal character_selected(character_id: String)
signal back_requested

@onready var selected_name: Label = $UI/Details/Name
@onready var start_button: Button = $UI/StartButton

var selected_id := "Khanan"
var _cards: Dictionary = {}
var _previews: Dictionary = {}

func _ready() -> void:
	for id in ["Khanan", "Jeki", "Bayu", "Reni", "Ervania", "Laras"]:
		var card := get_node("UI/Cards/" + id + "Card") as Panel
		var preview := get_node("UI/Details/Previews/" + id) as Node2D
		_cards[id] = card
		_previews[id] = preview
		card.get_node("SelectButton").pressed.connect(_select_character.bind(id))
		_play_idle(card)
		_play_idle(preview)
	start_button.pressed.connect(func(): character_selected.emit(selected_id))
	$UI/BackButton.pressed.connect(func(): back_requested.emit())
	_select_character(selected_id)

func _select_character(id: String) -> void:
	selected_id = id
	selected_name.text = id.to_upper()
	for card_id in _cards:
		(_cards[card_id] as Panel).modulate = Color("ffd15c") if card_id == id else Color.WHITE
		(_previews[card_id] as Node2D).visible = card_id == id

func _play_idle(root: Node) -> void:
	var sprite := root.find_child("AnimatedSprite2D", true, false) as AnimatedSprite2D
	if sprite and sprite.sprite_frames.has_animation("idle"):
		sprite.play("idle")
