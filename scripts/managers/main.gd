# main.gd
# Controller utama game. Mengelola alur: menu → pilih karakter → level → boss → victory.
# Setiap bagian sudah dipisah ke fungsi/region masing-masing agar mudah diedit.

extends Node2D

# ─── Preload scenes ───────────────────────────────────────────
const DefaultCharacterScene = preload("res://scenes/player/Jeki.tscn")
const LevelScenes := [
	preload("res://scenes/levels/Level01.tscn"),
	preload("res://scenes/levels/Level02.tscn"),
	preload("res://scenes/levels/Level03.tscn")
]
const MainMenuScene     = preload("res://scenes/main_menu/MainMenuUI.tscn")
const CharacterSelectScene = preload("res://scenes/main_menu/CharacterSelectUI.tscn")
const LevelSelectScene = preload("res://scenes/main_menu/LevelSelectUI.tscn")
const LevelResultScene = preload("res://scenes/ui/LevelResult.tscn")
const BossDefeatFadeScene = preload("res://scenes/ui/BossDefeatFade.tscn")

# ─── Preload scripts ──────────────────────────────────────────
const HUDScript         = preload("res://scripts/managers/hud.gd")

# Offset ini menjaga player sedikit di bawah tengah layar dan membuat kamera
# tetap bebas bergerak ke atas saat player melompat.
const PLAYER_CAMERA_OFFSET := Vector2(0, -90)
const PythonChallengeJudge = preload("res://scripts/ui/python_challenge_judge.gd")

# ─── State game ───────────────────────────────────────────────
var selected_char_id := "Khanan"   # id karakter yang dipilih
var level_index      := 0
var hp               := 3
var coins            := 0
var respawn_position := Vector2.ZERO
var _total_coins := 0
var _level_started_at := 0

# ─── Referensi node aktif ─────────────────────────────────────
var player: CharacterBody2D
var player_camera: Camera2D
var boss_visual: Node2D
var world: Node2D
var hud: HUD
var enemies:    Array = []
var coin_nodes: Array[Area2D] = []

var _boss_open := false
var _result_open := false

# ═════════════════════════════════════════════════════════════
#  INISIALISASI
# ═════════════════════════════════════════════════════════════
func _ready() -> void:
	GameData.load_progress()
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
		show_level_select()
	)

func show_level_select() -> void:
	_clear_world()
	var level_select = LevelSelectScene.instantiate()
	add_child(level_select)
	level_select.back_requested.connect(show_character_select)
	level_select.level_selected.connect(start_level)

# ═════════════════════════════════════════════════════════════
#  REGION: LEVEL SETUP
# ═════════════════════════════════════════════════════════════
func start_level(index: int) -> void:
	_clear_world()
	level_index  = index
	hp           = 3
	coins        = 0
	_boss_open   = false
	_result_open  = false

	if index < 0 or index >= LevelScenes.size() or index >= GameData.LEVELS.size():
		show_menu()
		return
	world = LevelScenes[index].instantiate()
	add_child(world)
	_read_level_nodes()
	_total_coins = coin_nodes.size()
	_level_started_at = Time.get_ticks_msec()
	_build_player()
	_build_hud()

	var lv: Dictionary = GameData.LEVELS[level_index]
	hud.show_message(lv.name + "\nKalahkan " + lv.boss, 3.0)

# Ambil objek yang sudah ditempatkan manual di Level01.tscn.
func _read_level_nodes() -> void:
	boss_visual = world.get_node_or_null("Boss") as Node2D
	enemies.assign(world.get_node("Enemies").get_children())
	for enemy in enemies:
		if enemy.has_signal("projectile_hit"):
			enemy.projectile_hit.connect(_on_enemy_projectile_hit)
	coin_nodes.assign(world.get_node("Coins").get_children())
	var question_blocks := world.get_node_or_null("QuestionBlocks")
	if question_blocks != null:
		for block in question_blocks.get_children():
			if block.has_signal("reward_spawned"):
				block.reward_spawned.connect(_on_question_block_reward_spawned)
	respawn_position = (world.get_node("PlayerSpawn") as Marker2D).position

func _on_question_block_reward_spawned(reward: Node) -> void:
	if reward is Area2D:
		coin_nodes.append(reward as Area2D)
		_total_coins += 1
		return
	if reward is Enemy:
		enemies.append(reward)
		if reward.has_signal("projectile_hit"):
			reward.projectile_hit.connect(_on_enemy_projectile_hit)

# ─── Player ───────────────────────────────────────────────────
func _build_player() -> void:
	var char_data: Dictionary = GameData.get_character(selected_char_id)
	var packed_scene: PackedScene = load(char_data.get("scene", ""))
	player = packed_scene.instantiate() if packed_scene != null else DefaultCharacterScene.instantiate()
	player.position = respawn_position
	world.add_child(player)
	player.add_to_group("player")
	player.apply_character(char_data)

	# Kamera mengikuti player
	player_camera = Camera2D.new()
	player_camera.position_smoothing_enabled = true
	player_camera.position_smoothing_speed   = 20.0
	player_camera.position = PLAYER_CAMERA_OFFSET
	var camera_start := world.get_node("CameraStart") as Marker2D
	var camera_end := world.get_node("CameraEnd") as Marker2D
	player_camera.limit_left   = int(camera_start.position.x)
	player_camera.limit_right  = int(camera_end.position.x)
	player_camera.limit_top    = int(camera_start.position.y)
	# Beri ruang vertikal agar kamera dapat ikut naik ketika player melompat.
	# Sebelumnya batas bawah terlalu dekat sehingga posisi kamera terkunci di lantai.
	player_camera.limit_bottom = int(camera_end.position.y + 110.0)
	player.add_child(player_camera)

# ─── HUD ──────────────────────────────────────────────────────
func _build_hud() -> void:
	hud = HUDScript.new()
	add_child(hud)
	hud.setup()
	hud.restart_requested.connect(func(): start_level(level_index))
	hud.main_menu_requested.connect(show_menu)
	_refresh_hud()

# ═════════════════════════════════════════════════════════════
#  REGION: PHYSICS LOOP (setiap frame)
# ═════════════════════════════════════════════════════════════
func _physics_process(delta: float) -> void:
	if player == null or world == null or _boss_open: return

	player.move_player(delta)
	_check_fall()
	_check_checkpoint()
	_check_coins()
	_check_enemies()
	if player == null or world == null or _boss_open:
		return
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
		if coin.overlaps_body(player):
			coin.queue_free()
			coin_nodes.erase(coin)
			coins += 1
			AudioManager.play_sfx(&"coin")
			_refresh_hud()

func _check_enemies() -> void:
	# Kontak fisik dari move_and_slide: paling akurat untuk enemy yang diam.
	for collision_index in player.get_slide_collision_count():
		var collision := player.get_slide_collision(collision_index)
		var collided_enemy := collision.get_collider() as Enemy
		if collided_enemy == null or not is_instance_valid(collided_enemy):
			continue
		if collided_enemy.can_be_stomped(player):
			_defeat_enemy(collided_enemy)
		else:
			_take_damage()
		return

	# Fallback untuk enemy yang bergerak masuk ke player.
	for enemy in enemies.duplicate():
		if not is_instance_valid(enemy): continue
		if enemy.can_be_stomped(player):
			_defeat_enemy(enemy)
		elif enemy.touches(player):
			_take_damage()
			break

func _defeat_enemy(enemy: Enemy) -> void:
	enemy.queue_free()
	enemies.erase(enemy)
	player.velocity.y = -380   # bouncing setelah stomp

func _on_enemy_projectile_hit() -> void:
	if _boss_open or _result_open or player == null:
		return
	_take_damage()

func _check_boss_trigger() -> void:
	if player == null or world == null:
		return
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
		_show_level_result(false)
		return
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

	# Simpan referensi lokal. Saat await berjalan, referensi global dapat berubah
	# ketika world dibersihkan atau scene berganti.
	var active_boss := boss_visual
	if is_instance_valid(active_boss):
		await _zoom_to_boss(active_boss)
		if is_instance_valid(active_boss):
			active_boss.visible = true
			await active_boss.play_spawn()
		await get_tree().create_timer(0.55).timeout
		await _return_camera_to_player()

	# Percakapan boss ditampilkan dan dikontrol klik di panel bawah.
	var challenge := BossChallenge.new()
	add_child(challenge)
	challenge.setup(GameData.LEVELS[level_index])
	challenge.code_phase_started.connect(func():
		if player and is_instance_valid(player):
			player.show_coding()
	)
	challenge.submitted.connect(
		func(answer: String): _validate_answer(answer, challenge)
	)

func _zoom_to_boss(target_boss: Node2D) -> void:
	if player_camera == null or not is_instance_valid(target_boss) or player == null:
		return
	player_camera.position_smoothing_enabled = false
	var boss_offset := target_boss.global_position - player.global_position + Vector2(0, -45)
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
	cinematic.tween_property(player_camera, "position", PLAYER_CAMERA_OFFSET, 0.85)
	cinematic.tween_property(player_camera, "zoom", Vector2.ONE, 0.85)
	await cinematic.finished
	player_camera.position = PLAYER_CAMERA_OFFSET
	player_camera.position_smoothing_enabled = true

func _validate_answer(given: String, challenge: BossChallenge) -> void:
	var evaluation: Dictionary = PythonChallengeJudge.validate(given, GameData.LEVELS[level_index])
	if evaluation.get("ok", false):
		var victory_text := str(GameData.LEVELS[level_index].get("victory_text", "KODE BENAR! Data Kampus berhasil dipulihkan."))
		challenge.show_result("✔ %s" % victory_text, true)
		await get_tree().create_timer(0.8).timeout
		if boss_visual and is_instance_valid(boss_visual):
			await boss_visual.play_death()
		if is_instance_valid(challenge):
			challenge.close_challenge()
			challenge.queue_free()
		# queue_free bersifat tertunda; tunggu satu frame agar dialog tidak
		# sempat terlihat di belakang result screen.
		await get_tree().process_frame
		await _start_boss_defeat_transition()
		return
	else:
		player.show_damage()
		hp -= 1
		_refresh_hud()
		if hp <= 0:
			_show_level_result(false)
			return
		else:
			challenge.show_result("✘ %s HP berkurang." % str(evaluation.get("message", "Jawaban belum sesuai.")), false)

# ═════════════════════════════════════════════════════════════
#  REGION: VICTORY
# ═════════════════════════════════════════════════════════════
func _start_boss_defeat_transition() -> void:
	AudioManager.stop_sfx()
	AudioManager.stop_music()
	var fade = BossDefeatFadeScene.instantiate()
	add_child(fade)
	# Mulai fade, lalu lanjutkan lewat timer yang pasti selesai. Result berada
	# di layer lebih tinggi sehingga tidak dapat lagi tertahan layar hitam.
	fade.cover_screen()
	await get_tree().create_timer(0.36).timeout
	_show_level_result(true, fade)
	await get_tree().process_frame
	AudioManager.play_sfx(&"game_win")
	if is_instance_valid(fade):
		fade.reveal_result()

func _show_level_result(won: bool, fade = null) -> void:
	if _result_open:
		return
	_result_open = true
	var elapsed_seconds := int((Time.get_ticks_msec() - _level_started_at) / 1000)
	if won:
		GameData.record_level_result(level_index, GameData.calculate_stars(true, coins, _total_coins), elapsed_seconds)
		GameData.unlock_level(level_index + 1)
	if fade == null:
		AudioManager.stop_sfx()
		if not won:
			AudioManager.play_sfx(&"game_over")
	_clear_world(fade)
	var result: LevelResult = LevelResultScene.instantiate()
	add_child(result)
	var has_next_level := won and level_index + 1 < GameData.LEVELS.size()
	var action_label := "LEVEL BERIKUTNYA" if has_next_level else ("MENU UTAMA" if won else "ULANGI LEVEL")
	result.setup(won, coins, _total_coins, elapsed_seconds, action_label)
	result.action_requested.connect(_on_result_action.bind(won))
	if won and fade == null:
		AudioManager.play_sfx(&"game_win")

func _on_result_action(_button_was_success: bool, won: bool) -> void:
	if won and level_index + 1 < GameData.LEVELS.size():
		start_level(level_index + 1)
	elif won:
		show_menu()
	else:
		start_level(level_index)

func show_victory() -> void:
	_show_level_result(true)

# ═════════════════════════════════════════════════════════════
#  REGION: UTILITAS INTERNAL
# ═════════════════════════════════════════════════════════════
func _clear_world(kept_child: Node = null) -> void:
	get_tree().paused = false
	for child in get_children():
		if child == kept_child:
			continue
		child.queue_free()
	player     = null
	player_camera = null
	boss_visual = null
	world      = null
	hud        = null
	enemies.clear()
	coin_nodes.clear()
	_boss_open = false
