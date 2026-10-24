class_name GameData
extends RefCounted

const PROGRESS_PATH := "user://me_and_friend_progress.cfg"
static var unlocked_level: int = 0

## Premis utama permainan. Dapat dipakai UI/narasi pembuka bila diperlukan.
const STORY_PREMISE := "Menjelang masa KRS, jaringan kampus lumpuh total. Sekelompok hacker misterius menyandera database mahasiswa dan meminta tebusan nilai A. Lacak sinyal mereka, kalahkan para pelaku, dan rebut kembali Data Kampus."

# ─────────────────────────────────────────
#  LEVELS
# ─────────────────────────────────────────
const LEVELS := [
	{
		"name"    : "Level 1 — TI Campus",
		"boss"    : "Poor Hacker (Script Kiddie)",
		"boss_portrait": "res://assets/bosses/script_kiddie_portrait.png",
		"boss_dialogues": [
			"Terlambat! Aku Poor Hacker, Script Kiddie yang memasang malware di Area Kampus Cabang.",
			"Jaringan kampus sedang lumpuh menjelang KRS. Sinyal database mahasiswa sudah kuarahkan ke markas sindikat!",
			"Kalau ingin menghentikan malware-ku, tembus dulu firewall dasar kampus dengan kode Python yang valid.",
			"Kirim kode Python-mu. Jika gagal tiga kali, malware ini akan mengunci lebih banyak data!"
		],
		"victory_text": "MALWARE DI AREA KAMPUS CABANG BERHASIL DIHENTIKAN! Sinyal pertama sindikat berhasil dilacak.",
		"challenge": {
			"title": "TEMBUS FIREWALL DASAR",
			"instruction": "Tulis kode Python bebas yang valid untuk menembus firewall dasar dan menghentikan malware. Tidak ada jawaban khusus.",
			"starter_code": "# Tulis kode Python di bawah ini\n",
			"validation": {
				"type": "valid_python",
				"require_variable": false
			}
		}
	},
	{
		"name"    : "Level 2 — Gedung JTI",
		"boss"    : "Poor Hacker (Malware Spammer)",
		"boss_portrait": "res://assets/bosses/malware_spammer_portrait.png",
		"boss_dialogues": [
			"Kamu berhasil menembus firewall cabang, tetapi aku Poor Hacker, Malware Spammer, sudah menguasai Gedung JTI!",
			"Aku mengunci ulang sistem pintu dan menyebarkan ransomware ke layanan lokal. Tidak seorang pun bisa masuk untuk KRS.",
			"Aktifkan sistem pertahanan lokal dengan kode Python valid yang memiliki minimal satu variabel.",
			"Gagal tiga kali, pintu gedung dan layanan akademik akan tetap terkunci. Coba hentikan spam malware-ku!"
		],
		"victory_text": "SISTEM PERTAHANAN GEDUNG JTI AKTIF! Ransomware lokal berhasil dihentikan.",
		"challenge": {
			"title": "AKTIFKAN PERTAHANAN LOKAL",
			"instruction": "Buat program Python valid yang memakai minimal satu variabel untuk mengaktifkan pertahanan lokal Gedung JTI.",
			"starter_code": "# Contoh: nilai = 80\n# Tulis solusi Python-mu di bawah ini\n",
			"validation": {
				"type": "valid_python",
				"require_variable": true
			}
		}
	},
	{
		"name"    : "Level 3 — Gedung Rektorat",
		"boss"    : "Ketua Sindikat Hacker",
		"boss_portrait": "res://assets/bosses/syndicate_leader_anonymous_portrait.png",
		"boss_dialogues": [
			"Akhirnya kamu tiba di Rektorat. Aku Ketua Sindikat Hacker, dalang di balik lumpuhnya jaringan kampus!",
			"Database mahasiswa utama sudah terenkripsi. Nilai, KRS, dan dokumen kampus akan tetap tersandera sampai tebusan nilai A kami dipenuhi.",
			"Dua jejak yang kamu rebut tidak cukup. Perbaiki kode server ini untuk mendekripsi Data Kampus utama.",
			"Ini kesempatan terakhirmu. Selesaikan seluruh error dan rebut kembali data sebelum ransomware menghapus kuncinya!"
		],
		"victory_text": "DATA KAMPUS BERHASIL DIDEKRIPSI! Ketua Sindikat Hacker dikalahkan dan jaringan kampus pulih menjelang KRS.",
		"challenge": {
			"title": "DEKRIPSI DATA KAMPUS",
			"instruction": "Kode server di bawah rusak pada beberapa baris. Perbaiki seluruh error untuk mendekripsi Data Kampus sampai program mencetak: Data Kampus: pulih.",
			"starter_code": "# Perbaiki kode untuk memulihkan Data Kampus\ndata_kampus = \"arsip mahasiswa\"\nkode_akses = \"REKTORAT\"\njumlah_fragmen = 3\nif jumlah_fragmen = 3:\n    status_data == \"pulih\"\nelse:\n    status_data = \"terkunci\"\nprint(\"Data Kampus:\", status_data)\n",
			"validation": {
				"type": "repair_campus_data"
			}
		}
	}
]

# Hasil terbaik per level: bintang tertinggi dan waktu selesai tercepat.
static var level_stars: Array[int] = [0, 0, 0]
static var best_times: Array[int] = [-1, -1, -1]

# ─────────────────────────────────────────
#  CHARACTERS
#  Tambah karakter baru di sini.
#  "scene" = scene karakter yang digunakan.
#  "color" = warna preview sementara di layar pemilihan karakter.
# ─────────────────────────────────────────
const CHARACTERS := [
	{
		"id"    : "Khanan",
		"label" : "Khanan",
		"scene" : "res://scenes/player/Khanan.tscn",
		"color" : Color("80cbc4")   # hijau tosca
	},
	{
		"id"    : "Jeki",
		"label" : "Jeki",
		"scene" : "res://scenes/player/Jeki.tscn",
		"color" : Color("4fc3f7")   # biru muda
	},
	{
		"id"    : "Bayu",
		"label" : "Bayu",
		"scene" : "res://scenes/player/Bayu.tscn",
		"color" : Color("ffcb77")   # kuning
	},
	{
		"id"    : "Reni",
		"label" : "Reni",
		"scene" : "res://scenes/player/Reni.tscn",
		"color" : Color("f28482")   # merah muda
	},
	{
		"id"    : "Ervania",
		"label" : "Ervania",
		"scene" : "res://scenes/player/Ervania.tscn",
		"color" : Color("a8dadc")   # tosca
	},
	{
		"id"    : "Laras",
		"label" : "Laras",
		"scene" : "res://scenes/player/Laras.tscn",
		"color" : Color("cdb4db")   # ungu muda
	}
]

static func load_progress() -> void:
	var progress := ConfigFile.new()
	_ensure_progress_slots()
	if progress.load(PROGRESS_PATH) == OK:
		unlocked_level = clampi(int(progress.get_value("progress", "unlocked_level", 0)), 0, LEVELS.size() - 1)
		for index in LEVELS.size():
			level_stars[index] = clampi(int(progress.get_value("level_%d" % index, "stars", 0)), 0, 3)
			best_times[index] = int(progress.get_value("level_%d" % index, "best_time", -1))
	else:
		unlocked_level = 0
		for index in LEVELS.size():
			level_stars[index] = 0
			best_times[index] = -1

static func unlock_level(level_index: int) -> void:
	if level_index <= unlocked_level:
		return
	unlocked_level = clampi(level_index, 0, LEVELS.size() - 1)
	_save_progress()

static func calculate_stars(won: bool, earned_coins: int, total_coins: int) -> int:
	if not won or total_coins <= 0:
		return 0
	var ratio := float(earned_coins) / float(total_coins)
	if ratio >= 1.0:
		return 3
	if ratio >= 0.65:
		return 2
	return 1

static func record_level_result(index: int, stars: int, elapsed_seconds: int) -> void:
	_ensure_progress_slots()
	if index < 0 or index >= LEVELS.size():
		return
	level_stars[index] = maxi(level_stars[index], clampi(stars, 0, 3))
	if elapsed_seconds >= 0 and (best_times[index] < 0 or elapsed_seconds < best_times[index]):
		best_times[index] = elapsed_seconds
	_save_progress()

static func get_level_stars(index: int) -> int:
	_ensure_progress_slots()
	return level_stars[index] if index >= 0 and index < level_stars.size() else 0

static func get_best_time(index: int) -> int:
	_ensure_progress_slots()
	return best_times[index] if index >= 0 and index < best_times.size() else -1

static func _ensure_progress_slots() -> void:
	while level_stars.size() < LEVELS.size():
		level_stars.append(0)
	while best_times.size() < LEVELS.size():
		best_times.append(-1)

static func _save_progress() -> void:
	var progress := ConfigFile.new()
	progress.set_value("progress", "unlocked_level", unlocked_level)
	for index in LEVELS.size():
		progress.set_value("level_%d" % index, "stars", level_stars[index])
		progress.set_value("level_%d" % index, "best_time", best_times[index])
	progress.save(PROGRESS_PATH)

# Ambil data karakter berdasarkan id
static func get_character(id: String) -> Dictionary:
	for c in CHARACTERS:
		if c.id == id:
			return c
	return CHARACTERS[0]
