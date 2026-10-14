extends Node

const BACKGROUND_MUSIC_PATH := "res://assets/audio/music/the_mountain-retro-game-music.mp3"
const GAME_START_PATH := "res://assets/audio/sfx/game-start.mp3"
const COIN_PATH := "res://assets/audio/sfx/coin.mp3"
const GAME_WIN_PATH := "res://assets/audio/sfx/game-win.mp3"
const GAME_OVER_PATH := "res://assets/audio/sfx/game-over.mp3"

var _music_player: AudioStreamPlayer
var _sfx_player: AudioStreamPlayer
var _streams: Dictionary[String, AudioStream] = {}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ensure_bus("Music")
	_ensure_bus("SFX")
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = &"Music"
	_music_player.stream = _load_mp3(BACKGROUND_MUSIC_PATH)
	add_child(_music_player)
	_sfx_player = AudioStreamPlayer.new()
	_sfx_player.bus = &"SFX"
	add_child(_sfx_player)
	play_background_music()

func play_background_music() -> void:
	if _music_player.playing:
		return
	_music_player.play()

func stop_music() -> void:
	if _music_player:
		_music_player.stop()

func play_sfx(sound_name: StringName) -> void:
	match sound_name:
		&"game_start":
			_sfx_player.stream = _load_mp3(GAME_START_PATH)
		&"coin":
			_sfx_player.stream = _load_mp3(COIN_PATH)
		&"game_win":
			_sfx_player.stream = _load_mp3(GAME_WIN_PATH)
		&"game_over":
			_sfx_player.stream = _load_mp3(GAME_OVER_PATH)
		_:
			return
	_sfx_player.play()

func stop_sfx() -> void:
	if _sfx_player:
		_sfx_player.stop()

func _load_mp3(path: String) -> AudioStream:
	if _streams.has(path):
		return _streams[path]
	var stream := AudioStreamMP3.load_from_file(path)
	_streams[path] = stream
	return stream

func set_bus_volume(value: float, bus_name: StringName) -> void:
	var index := AudioServer.get_bus_index(bus_name)
	if index < 0:
		return
	AudioServer.set_bus_mute(index, value <= 0.0)
	AudioServer.set_bus_volume_db(index, linear_to_db(max(value / 100.0, 0.001)))

func get_bus_volume(bus_name: StringName) -> float:
	var index := AudioServer.get_bus_index(bus_name)
	if index < 0 or AudioServer.is_bus_mute(index):
		return 0.0
	return clamp(db_to_linear(AudioServer.get_bus_volume_db(index)) * 100.0, 0.0, 100.0)

func _ensure_bus(bus_name: StringName) -> void:
	if AudioServer.get_bus_index(bus_name) >= 0:
		return
	AudioServer.add_bus()
	AudioServer.set_bus_name(AudioServer.bus_count - 1, bus_name)
