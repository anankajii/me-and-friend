class_name BossDialoguePanel
extends Control

signal advance_requested

@onready var card_name: Label = $CardName
@onready var speaker: Label = $Speaker
@onready var dialogue_text: Label = $DialogueText
@onready var continue_hint: Label = $ContinueHint

var _boss_name := ""
var _pending_text := ""
var _pending_is_last := false

func _ready() -> void:
	_apply_boss_name()
	_apply_dialogue()

func configure(boss_name: String) -> void:
	_boss_name = boss_name
	if is_node_ready():
		_apply_boss_name()

func show_dialogue(text: String, is_last := false) -> void:
	_pending_text = text
	_pending_is_last = is_last
	if is_node_ready():
		_apply_dialogue()

func _apply_boss_name() -> void:
	card_name.text = _boss_name.to_upper()
	speaker.text = _boss_name.to_upper()

func _apply_dialogue() -> void:
	dialogue_text.text = _pending_text
	continue_hint.text = "KLIK UNTUK MEMBUKA EDITOR" if _pending_is_last else "KLIK UNTUK LANJUT"

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		advance_requested.emit()
