class_name CodeChallengeEditor
extends Control

signal submitted(answer: String)

const PythonHighlighter := preload("res://scripts/ui/python_code_highlighter.gd")

@onready var question: Label = $Question
@onready var code_input: CodeEdit = $CodeInput
@onready var feedback: Label = $Feedback
@onready var send_button: Button = $SendButton

var _question_text := ""
var _starter_code := ""

func _ready() -> void:
	_apply_challenge_data()
	_apply_syntax_highlighting()

func configure(challenge_data: Dictionary) -> void:
	_question_text = str(challenge_data.get("instruction", ""))
	_starter_code = str(challenge_data.get("starter_code", ""))
	if is_node_ready():
		_apply_challenge_data()

func open_editor() -> void:
	visible = true
	code_input.grab_focus()

func show_result(message: String, success := false) -> void:
	feedback.text = message
	feedback.modulate = Color("86f59c") if success else Color("ff9696")
	if success:
		send_button.disabled = true

func _on_send_pressed() -> void:
	submitted.emit(code_input.text)

func _apply_syntax_highlighting() -> void:
	code_input.syntax_highlighter = PythonHighlighter.new()

func _apply_challenge_data() -> void:
	question.text = _question_text
	code_input.text = _starter_code
	feedback.text = ""
	send_button.disabled = false
