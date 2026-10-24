class_name BossChallenge
extends CanvasLayer

signal submitted(answer: String)
signal code_phase_started

const DIALOGUE_PANEL_SCENE := preload("res://scenes/ui/BossDialoguePanel.tscn")
const CODE_EDITOR_SCENE := preload("res://scenes/ui/CodeChallengeEditor.tscn")

var _dialogue_panel
var _code_editor
var _dialogue_step := 0
const DEFAULT_DIALOGUES: Array[String] = [
	"Berhenti! Tidak ada yang boleh melewati area ini tanpa izin.",
	"Jika ingin melanjutkan perjalanan, kamu harus memperbaiki kode yang rusak.",
	"Baca soalnya di editor, lalu kirim jawaban yang benar. Tiga kesalahan berarti kamu kalah.",
	"Siap? Buktikan kemampuan coding-mu!"
]
var _dialogues: Array[String] = []

func setup(level_data: Dictionary) -> void:
	layer = 12
	_dialogues.clear()
	var story_dialogues = level_data.get("boss_dialogues", DEFAULT_DIALOGUES)
	for line in story_dialogues:
		_dialogues.append(str(line))
	if _dialogues.is_empty():
		_dialogues = DEFAULT_DIALOGUES.duplicate()
	_dialogue_panel = DIALOGUE_PANEL_SCENE.instantiate()
	_dialogue_panel.position = Vector2(155, 432)
	add_child(_dialogue_panel)
	_dialogue_panel.configure(str(level_data.boss), str(level_data.get("boss_portrait", "")))
	_dialogue_panel.advance_requested.connect(_advance_dialogue)

	_code_editor = CODE_EDITOR_SCENE.instantiate()
	_code_editor.position = Vector2(610, 90)
	add_child(_code_editor)
	# Scene editor dibuat terlihat agar nyaman diedit di Godot, tetapi harus
	# tersembunyi dalam permainan sampai semua dialog boss selesai.
	_code_editor.hide()
	_code_editor.configure(level_data.get("challenge", {}))
	_code_editor.submitted.connect(func(answer: String): submitted.emit(answer))
	_show_dialogue()

func _advance_dialogue() -> void:
	if _dialogue_step < _dialogues.size() - 1:
		_dialogue_step += 1
		_show_dialogue()
		return

	# Panel dialog ditutup dulu, baru editor kode ditampilkan.
	_dialogue_panel.hide()
	_code_editor.open_editor()
	code_phase_started.emit()

func _show_dialogue() -> void:
	_dialogue_panel.show_dialogue(
		_dialogues[_dialogue_step],
		_dialogue_step == _dialogues.size() - 1
	)

func show_result(text: String, success := false) -> void:
	if _code_editor:
		_code_editor.show_result(text, success)

## Dipanggil sebelum scene hasil dibuat agar CanvasLayer dialog tidak tersisa.
func close_challenge() -> void:
	visible = false
	if is_instance_valid(_dialogue_panel):
		_dialogue_panel.hide()
	if is_instance_valid(_code_editor):
		_code_editor.hide()
