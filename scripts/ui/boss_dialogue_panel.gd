class_name BossDialoguePanel
extends Control

signal advance_requested

@onready var card_name: Label = $CardName
@onready var speaker: Label = $Speaker
@onready var dialogue_text: Label = $DialogueText
@onready var continue_hint: Label = $ContinueHint
@onready var portrait: TextureRect = $Portrait

var _boss_name := ""
var _boss_portrait_path := ""
var _player_portrait_path := ""
var _pending_text := ""
var _pending_is_last := false
var _pending_speaker := ""

func _ready() -> void:
	speaker.visible = false
	card_name.visible = true
	_apply_boss_name()
	_apply_dialogue()

func configure(boss_name: String, portrait_path := "", player_portrait_path := "") -> void:
	_boss_name = boss_name
	_boss_portrait_path = portrait_path
	_player_portrait_path = player_portrait_path
	if is_node_ready():
		_apply_boss_name()
	if not portrait_path.is_empty():
		var portrait_texture := load(portrait_path) as Texture2D
		if portrait_texture != null:
			portrait.texture = portrait_texture

func show_dialogue(text: String, is_last := false, speaker_override := "") -> void:
	_pending_text = text
	_pending_is_last = is_last
	_pending_speaker = speaker_override
	if is_node_ready():
		_apply_dialogue()

func _apply_boss_name() -> void:
	card_name.text = _boss_name.to_upper()
	speaker.text = _boss_name.to_upper()

func _apply_dialogue() -> void:
	var is_player := _pending_speaker == "Pemain"
	var spk := _pending_speaker if not _pending_speaker.is_empty() else _boss_name
	card_name.text = spk.to_upper()
	if is_player and not _player_portrait_path.is_empty():
		var tex := load(_player_portrait_path) as Texture2D
		if tex != null:
			portrait.texture = tex
	elif not is_player and not _boss_portrait_path.is_empty():
		var tex := load(_boss_portrait_path) as Texture2D
		if tex != null:
			portrait.texture = tex
	dialogue_text.text = _pending_text
	continue_hint.text = "KLIK UNTUK MEMBUKA EDITOR" if _pending_is_last else "KLIK UNTUK LANJUT"

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		advance_requested.emit()
