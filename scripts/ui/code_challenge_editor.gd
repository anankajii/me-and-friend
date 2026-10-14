class_name CodeChallengeEditor
extends Control

signal submitted(answer: String)

const PythonHighlighter := preload("res://scripts/ui/python_code_highlighter.gd")

@onready var question: Label = $Question
@onready var code_input: CodeEdit = $CodeInput
@onready var feedback: Label = $Feedback
@onready var send_button: Button = $SendButton

var _question_text := ""

func _ready() -> void:
	question.text = _question_text
	_apply_syntax_highlighting()

func configure(question_text: String) -> void:
	_question_text = question_text
	if is_node_ready():
		question.text = question_text

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
