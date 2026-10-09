# main.gd
# Controller utama game. Mengelola alur: menu → pilih karakter → level → boss → victory.
# Setiap bagian sudah dipisah ke fungsi/region masing-masing agar mudah diedit.

extends Node2D

# ─── Preload scenes ───────────────────────────────────────────
const DefaultCharacterScene = preload("res://scenes/player/Jeki.tscn")
const LevelScene        = preload("res://scenes/levels/Level01.tscn")
const MainMenuScene     = preload("res://scenes/main_menu/MainMenuUI.tscn")
const CharacterSelectScene = preload("res://scenes/main_menu/CharacterSelectUI.tscn")

# ─── Preload scripts ──────────────────────────────────────────
const GameData          = preload("res://scripts/managers/game_data.gd")
const UIHelper          = preload("res://scripts/managers/ui_helper.gd")
const HUDScript         = preload("res://scripts/managers/hud.gd")
const BossChallenge     = preload("res://scripts/boss/boss_challenge.gd")

# ─── State game ───────────────────────────────────────────────
var selected_char_id := "Khanan"   # id karakter yang dipilih
var level_index      := 0
var hp               := 3
var coins            := 0
var respawn_position := Vector2.ZERO

# ─── Referensi node aktif ─────────────────────────────────────
var player: CharacterBody2D
var player_camera: Camera2D
var boss_visual: Node2D
var world: Node2D
var hud: HUD
var enemies:    Array = []
var coin_nodes: Array[Area2D] = []

var _boss_open := false

# ═════════════════════════════════════════════════════════════
#  INISIALISASI
# ═════════════════════════════════════════════════════════════
func _ready() -> void:
	show_menu()

# ═════════════════════════════════════════════════════════════
#  REGION: MAIN MENU
# ═════════════════════════════════════════════════════════════
func show_menu() -> void:
	_clear_world()
	var menu: MainMenuUI = MainMenuScene.instantiate()
	add_child(menu)
	menu.play_requested.connect(show_character_select)

# ═════════════════════════════════════════════════════════════
#  REGION: CHARACTER SELECT
# ═════════════════════════════════════════════════════════════
func show_character_select() -> void:
	_clear_world()
	var select_ui: CharacterSelectUI = CharacterSelectScene.instantiate()
	add_child(select_ui)
	select_ui.back_requested.connect(show_menu)
	select_ui.character_selected.connect(func(character_id: String):
		selected_char_id = character_id
		start_level(0)
	)

# ═════════════════════════════════════════════════════════════
#  REGION: LEVEL SETUP
# ═════════════════════════════════════════════════════════════
func start_level(index: int) -> void:
	_clear_world()
	level_index  = index
	hp           = 3
	coins        = 0
	_boss_open   = false

	world = LevelScene.instantiate()
	add_child(world)
	_read_level_nodes()
	_build_player()
	_build_hud()

	var lv: Dictionary = GameData.LEVELS[level_index]
	hud.show_message(lv.name + "\nKalahkan " + lv.boss, 3.0)

# Ambil objek yang sudah ditempatkan manual di Level01.tscn.
func _read_level_nodes() -> void:
	boss_visual = world.get_node_or_null("Boss") as Node2D
	enemies.assign(world.get_node("Enemies").get_children())
	coin_nodes.assign(world.get_node("Coins").get_children())
	respawn_position = (world.get_node("PlayerSpawn") as Marker2D).position

# ─── Player ───────────────────────────────────────────────────
func _build_player() -> void:
	var char_data: Dictionary = GameData.get_character(selected_char_id)
	var packed_scene: PackedScene = load(char_data.get("scene", ""))
	player = packed_scene.instantiate() if packed_scene != null else DefaultCharacterScene.instantiate()
	player.position = respawn_position
	world.add_child(player)
	player.apply_character(char_data)

	# Kamera mengikuti player
	player_camera = Camera2D.new()
	player_camera.position_smoothing_enabled = true
	player_camera.position_smoothing_speed   = 7.0
	var camera_start := world.get_node("CameraStart") as Marker2D
	var camera_end := world.get_node("CameraEnd") as Marker2D
	player_camera.limit_left   = int(camera_start.position.x)
	player_camera.limit_right  = int(camera_end.position.x)
	player_camera.limit_top    = int(camera_start.position.y)
	player_camera.limit_bottom = int(camera_end.position.y)
	player.add_child(player_camera)

# ─── HUD ──────────────────────────────────────────────────────
func _build_hud() -> void:
	hud = HUDScript.new()
	add_child(hud)
	hud.setup()
	_refresh_hud()

# ═════════════════════════════════════════════════════════════
#  REGION: PHYSICS LOOP (setiap frame)
# ═════════════════════════════════════════════════════════════
func _physics_process(delta: float) -> void:
	if player == null or _boss_open: return

	player.move_player(delta)
	_check_fall()
	_check_checkpoint()
	_check_coins()
	_check_enemies()
	_check_boss_trigger()

func _check_fall() -> void:
	var death_limit := world.get_node("DeathLimit") as Marker2D
	if player.position.y > death_limit.position.y:
		respawn()

func _check_checkpoint() -> void:
	var checkpoint := world.get_node("Checkpoint") as Marker2D
	if player.position.x > checkpoint.position.x and respawn_position.x < checkpoint.position.x:
		respawn_position = checkpoint.position
		hud.show_message("Checkpoint!", 1.5)

func _check_coins() -> void:
	for coin in coin_nodes.duplicate():
		if not is_instance_valid(coin): continue
		if player.position.distance_to(coin.position) < 38:
			coin.queue_free()
			coin_nodes.erase(coin)
			coins += 1
			_refresh_hud()

func _check_enemies() -> void:
	for enemy in enemies.duplicate():
		if not is_instance_valid(enemy): continue
		if enemy.can_be_stomped(player):
			enemy.queue_free()
			enemies.erase(enemy)
			player.velocity.y = -380   # bouncing setelah stomp
		elif enemy.touches(player):
			_take_damage()
			break

func _check_boss_trigger() -> void:
	var trigger := world.get_node("BossTrigger") as Marker2D
	if player.position.x > trigger.position.x:
		_open_boss()

# ═════════════════════════════════════════════════════════════
#  REGION: DAMAGE & RESPAWN
# ═════════════════════════════════════════════════════════════
func _take_damage() -> void:
	player.show_damage()
	hp -= 1
	_refresh_hud()
	if hp <= 0:
		hp = 3
		_refresh_hud()
		hud.show_message("HP habis — kembali ke checkpoint!", 2.0)
	respawn()

func respawn() -> void:
	if player == null: return
	player.position = respawn_position
	player.velocity = Vector2.ZERO

func _refresh_hud() -> void:
	if hud:
		var char_data := GameData.get_character(selected_char_id)
		hud.update(char_data.label, hp, coins)

# ═════════════════════════════════════════════════════════════
#  REGION: BOSS CHALLENGE
# ═════════════════════════════════════════════════════════════
func _open_boss() -> void:
	if _boss_open: return
	_boss_open = true
	player.velocity = Vector2.ZERO
	player.show_idle()

	# Boss tampil dan menyelesaikan animasi kemunculannya terlebih dahulu.
	if boss_visual and is_instance_valid(boss_visual):
		await _zoom_to_boss()
		boss_visual.visible = true
		await boss_visual.play_spawn()
		await get_tree().create_timer(0.55).timeout
		await _return_camera_to_player()

	# Percakapan singkat sebelum coding challenge dibuka.
	hud.show_message(GameData.LEVELS[level_index].boss + ": Berhenti!\nKau tidak bisa melewatiku begitu saja.", 2.4)
	await get_tree().create_timer(2.5).timeout
	hud.show_message("Buktikan kemampuan coding-mu!", 1.8)
	await get_tree().create_timer(1.9).timeout

	var challenge := BossChallenge.new()
	add_child(challenge)
	challenge.setup(GameData.LEVELS[level_index])
	player.show_coding()
	challenge.submitted.connect(
		func(answer: String): _validate_answer(answer, challenge)
	)

func _zoom_to_boss() -> void:
	if player_camera == null or boss_visual == null:
		return
	player_camera.position_smoothing_enabled = false
	var boss_offset := boss_visual.global_position - player.global_position + Vector2(0, -45)
	var cinematic := create_tween().set_parallel(true)
	cinematic.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	cinematic.tween_property(player_camera, "position", boss_offset, 1.15)
	cinematic.tween_property(player_camera, "zoom", Vector2(1.65, 1.65), 1.15)
	await cinematic.finished

func _return_camera_to_player() -> void:
	if player_camera == null:
		return
	var cinematic := create_tween().set_parallel(true)
	cinematic.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	cinematic.tween_property(player_camera, "position", Vector2.ZERO, 0.85)
	cinematic.tween_property(player_camera, "zoom", Vector2.ONE, 0.85)
	await cinematic.finished
	player_camera.position = Vector2.ZERO
	player_camera.position_smoothing_enabled = true

func _validate_answer(given: String, challenge: BossChallenge) -> void:
	var expected: String = GameData.LEVELS[level_index].answer
	if given.strip_edges() == expected:
		challenge.show_result("✔ BENAR!  Raja dikalahkan!", true)
		await get_tree().create_timer(0.8).timeout
		if boss_visual and is_instance_valid(boss_visual):
			await boss_visual.play_death()
		challenge.queue_free()
		_boss_open = false
		if level_index + 1 < GameData.LEVELS.size():
			start_level(level_index + 1)
		else:
			show_victory()
	else:
		player.show_damage()
		hp -= 1
		_refresh_hud()
		if hp <= 0:
			hp = 3
			_refresh_hud()
			challenge.queue_free() # TextEdit hilang bersama challenge saat HP habis.
			_boss_open = false
			respawn()
			hud.show_message("HP habis — kembali ke checkpoint!", 2.0)
		else:
			challenge.show_result("✘ Salah! HP berkurang. Coba lagi.", false)

# ═════════════════════════════════════════════════════════════
#  REGION: VICTORY
# ═════════════════════════════════════════════════════════════
func show_victory() -> void:
	_clear_world()
	var ui := CanvasLayer.new()
	add_child(ui)

	ui.add_child(UIHelper.full_bg(Color("1a3a2a")))

	var title := UIHelper.label("🏆  VICTORY!", 56)
	title.position = Vector2(230, 160)
	title.size     = Vector2(690, 80)
	ui.add_child(title)

	var sub := UIHelper.label("Semua level telah diselesaikan!", 24)
	sub.position = Vector2(230, 255)
	sub.size     = Vector2(690, 40)
	sub.modulate = Color("aaffaa")
	ui.add_child(sub)

	var coin_lbl := UIHelper.label("Coin terkumpul: %d" % coins, 20)
	coin_lbl.position = Vector2(230, 305)
	coin_lbl.size     = Vector2(690, 35)
	coin_lbl.modulate = Color("ffdd88")
	ui.add_child(coin_lbl)

	ui.add_child(UIHelper.button("MAIN LAGI", Vector2(405, 385), Vector2(340, 65), 26, show_menu))

# ═════════════════════════════════════════════════════════════
#  REGION: UTILITAS INTERNAL
# ═════════════════════════════════════════════════════════════
func _clear_world() -> void:
	for child in get_children():
		child.queue_free()
	player     = null
	player_camera = null
	boss_visual = null
	world      = null
	hud        = null
	enemies.clear()
	coin_nodes.clear()
	_boss_open = false
