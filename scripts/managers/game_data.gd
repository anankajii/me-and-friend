class_name GameData
extends RefCounted

# ─────────────────────────────────────────
#  LEVELS
# ─────────────────────────────────────────
const LEVELS := [
	{
		"name"    : "Level 1 — TI Campus",
		"boss"    : "Dosen Bug",
		"question": "Lengkapi baris kode Python berikut:\nprint(____)",
		"answer"  : 'print("Hello World")'
	}
]

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

# Ambil data karakter berdasarkan id
static func get_character(id: String) -> Dictionary:
	for c in CHARACTERS:
		if c.id == id:
			return c
	return CHARACTERS[0]
