# Konteks Lengkap Proyek — Me And Friend

> Dokumen ini adalah konteks teknis dan desain untuk proyek game **Me And Friend**. Gunakan sebagai pegangan saat melanjutkan pengembangan, memperbaiki bug, menambah level, atau menjelaskan proyek pada mata kuliah Multimedia Permainan.

## 1. Identitas Proyek

| Item | Keterangan |
|---|---|
| Nama aplikasi | **Me And Friend** |
| Engine | Godot Engine 4.7 |
| Bahasa scripting | GDScript |
| Genre | Platformer 2D edukasi berbasis pixel-art |
| Mata kuliah | Multimedia Permainan |
| Scene awal | `scenes/main_menu/Main.tscn` |
| Resolusi UI | Mengikuti `canvas_items` dengan aspek `expand` |
| Tema | Petualangan kampus, serangan ransomware, penyelamatan Data Kampus, dan latihan logika Python |

Game ini menggabungkan platformer dengan pengenalan pemrograman Python. Pemain menjelajah lingkungan kampus, mengumpulkan koin, menghindari atau mengalahkan enemy, lalu menyelesaikan challenge kode untuk mengalahkan boss dan memulihkan **Data Kampus**.

## 2. Tujuan dan Premis Cerita

Menjelang masa KRS, jaringan kampus lumpuh total. Sekelompok hacker misterius menyandera database mahasiswa dan meminta tebusan nilai A. Pemain berperan sebagai salah satu mahasiswa yang dipilih untuk melacak sinyal mereka, menghentikan ransomware, dan merebut kembali Data Kampus.

Perjalanan dibagi menjadi tiga tahap:

1. Menembus firewall dasar dan menghentikan malware di Area Kampus Cabang.
2. Mengaktifkan pertahanan lokal setelah sistem pintu Gedung JTI dikunci ulang.
3. Mendekripsi database utama di Gedung Rektorat dan mengalahkan dalang sindikat.

Boss bukan hanya rintangan visual. Mereka mewakili masalah pemrograman: bug dasar, algoritma, dan struktur data. Setelah mencapai boss, pemain berdialog terlebih dahulu. Editor kode hanya muncul setelah seluruh dialog dibaca.

## 3. Alur Pemain

```text
Main Menu
  -> Pilih Karakter
  -> Pilih Level (level terkunci bila belum dibuka)
  -> Bermain platformer
  -> Trigger boss
  -> Kamera zoom ke boss + animasi kemunculan
  -> Dialog boss (klik untuk lanjut)
  -> Code editor challenge
  -> Menang atau kalah
  -> Result screen
  -> Level berikutnya / ulangi level / kembali menu
```

## 4. Karakter Pemain

Terdapat tepat **enam karakter**. Masing-masing memiliki scene sendiri supaya sprite, ukuran, collision, dan animasi dapat disesuaikan melalui Godot Editor.

| Karakter | ID | Peran tampilan | Scene |
|---|---|---|---|
| Khanan | `Khanan` | Pemimpin tim | `scenes/player/Khanan.tscn` |
| Jeki | `Jeki` | Super kompas | `scenes/player/Jeki.tscn` |
| Bayu | `Bayu` | Atlet lompat | `scenes/player/Bayu.tscn` |
| Reni | `Reni` | Analis bug | `scenes/player/Reni.tscn` |
| Ervania | `Ervania` | Logika UI | `scenes/player/Ervania.tscn` |
| Laras | `Laras` | Data explorer | `scenes/player/Laras.tscn` |

Data karakter berada di `scripts/managers/game_data.gd`, pada konstanta `CHARACTERS`.

### Animasi karakter

Format animasi yang dipakai oleh controller karakter:

- `idle` — karakter diam.
- `walk` — karakter berjalan ke kiri/kanan.
- `jump` — karakter berada di udara.
- `damaged` — karakter terkena serangan.
- `coding` — karakter berada dalam fase code challenge.

`scripts/player/grid_sprite_sheet.gd` adalah bantuan untuk membangun `SpriteFrames` dari sheet grid 5×5. Jika ingin mengatur frame manual melalui panel **SpriteFrames**, lepaskan script itu dari `AnimatedSprite2D` agar frame tidak dibuat ulang otomatis saat scene berjalan.

## 5. Struktur Level

| Level | Scene | Latar | Boss | Tujuan pembelajaran |
|---|---|---|---|---|
| 1 | `scenes/levels/Level01.tscn` | Area Kampus Cabang | Poor Hacker (Script Kiddie) | Menulis Python bebas yang valid untuk menembus firewall dasar |
| 2 | `scenes/levels/Level02.tscn` | Gedung JTI | Poor Hacker (Malware Spammer) | Menulis Python valid dengan minimal satu variabel untuk mengaktifkan pertahanan lokal |
| 3 | `scenes/levels/Level03.tscn` | Gedung Rektorat | Ketua Sindikat Hacker | Memperbaiki kode Python Data Kampus yang sengaja error untuk dekripsi database utama |

Setiap scene level ditempatkan dan diedit manual melalui Godot. Node penting yang perlu tetap ada pada setiap level adalah:

```text
LevelXX
├── PlayerSpawn      # Marker2D posisi awal pemain
├── CameraStart      # Marker2D batas kiri/atas kamera
├── CameraEnd        # Marker2D batas kanan/bawah kamera
├── DeathLimit       # Marker2D batas jatuh
├── Checkpoint       # Marker2D titik respawn setelah checkpoint
├── BossTrigger      # Marker2D pemicu boss
├── Boss             # Node2D boss visual
├── Enemies          # Container untuk instance Enemy
├── Coins            # Container untuk instance Coin
└── QuestionBlocks   # Opsional; khusus blok hadiah level 3
```

Jangan mengubah `FloorLevel02.tscn` untuk level 1 atau sebaliknya. Masing-masing level memakai floor scene terpisah:

- `scenes/tiles/Floor.tscn` untuk Level 1.
- `scenes/tiles/FloorLevel02.tscn` untuk Level 2.
- `scenes/tiles/FloorLevel03.tscn` untuk Level 3.

## 6. Gameplay Utama

### Kontrol pemain

- Bergerak: `A` / `D` atau tombol panah kiri / kanan.
- Lompat: `Space`, tombol atas, atau aksi accept.
- Pause: tombol pause pada HUD.

Karakter memakai `CharacterBody2D`. Kamera adalah `Camera2D` yang ditambahkan ke player secara runtime oleh `main.gd`, dengan smoothing dan batas kamera berdasarkan marker level. Batas bawah diberi ruang ekstra sehingga kamera dapat mengikuti lompatan pemain.

### HP, checkpoint, dan kalah

- Pemain mulai dengan **3 HP**.
- HUD menunjukkan HP melalui ikon hati.
- Menyentuh enemy atau proyektil mengurangi satu HP.
- Jika HP masih ada, pemain respawn di `Checkpoint` terakhir.
- Jika HP habis, result screen kalah dibuka dengan 0 bintang.
- Pemain juga kalah bila mengirim jawaban challenge salah sampai HP habis. Setiap jawaban salah mengurangi satu HP.

### Koin dan bintang

- Koin diletakkan manual di node `Coins` setiap level.
- Koin diambil berdasarkan jarak player dengan node koin.
- Jumlah koin tampil di HUD dan result screen.
- Hasil kemenangan memiliki bintang berdasarkan persentase koin:

| Koin yang diperoleh | Bintang |
|---|---:|
| Semua koin | 3 |
| Minimal 65% | 2 |
| Di bawah 65% | 1 |
| Kalah | 0 |

Result screen juga menampilkan waktu bermain. Challenge box lama tidak ditampilkan pada result screen.

### Enemy

Enemy diatur melalui Inspector pada instance `Enemy.tscn`.

| Properti | Fungsi |
|---|---|
| `patrol_enabled` | Enemy bergerak bolak-balik bila aktif. |
| `patrol_distance` | Jarak patroli horizontal. |
| `patrol_speed` | Kecepatan patroli. |
| `shoot_enabled` | Mengaktifkan serangan proyektil. |
| `shoot_range` | Jarak horizontal sebelum enemy menembak. |
| `shoot_cooldown` | Jeda antar tembakan. |
| `projectile_count` | Pilihan satu atau tiga proyektil. |
| `triple_shot_spacing` | Jarak vertikal antar proyektil saat tiga tembakan. |

Proyektil bergerak **horizontal**, sesuai arah enemy, dan tidak membidik posisi player. Player dapat mengalahkan enemy dengan menginjaknya dari atas saat sedang jatuh.

### Obstacle dan platform

Platform, floor, obstacle, koin, dan enemy ditempatkan sebagai instance scene di editor Godot. Prinsipnya: posisi objek permainan diatur manual di scene level, sedangkan fungsi perilakunya berada pada script scene tersebut.

### Question block Level 3

`QuestionBlock.tscn` adalah kotak tanda tanya yang dipukul dari bawah ketika pemain melompat.

- `reward_type`: memilih hadiah `Coin` atau `Enemy`.
- `coin_count`: jumlah koin hadiah (1 sampai 3).
- `enemy_patrol`: menentukan apakah enemy hadiah berpatroli.
- Hanya dapat dipukul sekali dan berubah abu-abu setelah dipakai.

## 7. Boss dan Challenge Kode

### Urutan boss

1. Player melewati `BossTrigger`.
2. Player dihentikan pada pose `idle`.
3. Kamera zoom ke boss.
4. Boss muncul dengan animasi spawn.
5. Kamera kembali ke player.
6. Dialog bawah muncul dan dilanjutkan dengan klik.
7. Setelah dialog terakhir, panel dialog ditutup.
8. Player berpindah ke animasi `coding` dan editor kode ditampilkan.
9. Jika kode valid, boss memainkan animasi kalah, audio dihentikan, fade transisi berjalan, lalu result screen muncul.

Panel dialog berasal dari `scenes/ui/BossDialoguePanel.tscn`. Card/portrait boss berada di sisi kiri dialog. Tidak ada HP bar boss.

### Editor kode

Editor kode reusable berada di:

- Scene: `scenes/ui/CodeChallengeEditor.tscn`
- Controller: `scripts/ui/code_challenge_editor.gd`
- Highlighter: `scripts/ui/python_code_highlighter.gd`
- Validator: `scripts/ui/python_challenge_judge.gd`

Gaya editor dibuat menyerupai VS Code: panel gelap tidak transparan, nomor baris, font JetBrains Mono, dan pewarnaan sintaks untuk keyword, fungsi, string, angka, komentar, dan identifier.

### Validasi Python dan keamanan

Untuk Level 1 dan Level 2, kode dieksekusi sebagai Python asli melalui Python yang dikonfigurasi pada:

```ini
[python_sandbox]
executable="C:/Python313/python.exe"
```

Eksekusi dijalankan melalui `scripts/tools/safe_python_runner.py` dengan batasan AST/whitelist. Kode challenge tidak seharusnya mempunyai akses bebas ke file, import, sistem operasi, `eval`, `exec`, atau bagian game lain.

Aturan level:

| Level | Validasi |
|---|---|
| 1 | Kode Python apa pun yang valid diterima. Tidak ada jawaban wajib seperti `print("Hello World")`. |
| 2 | Kode Python valid dan minimal satu assignment variabel wajib ada. |
| 3 | Pemain memperbaiki kode 9 baris hingga output tepat `Data Kampus: pulih`. |

Data challenge, dialog boss, dan teks kemenangan dikelola dalam `GameData.LEVELS` di `scripts/managers/game_data.gd`.

## 8. UI dan Navigasi

### Main menu

Scene: `scenes/main_menu/MainMenuUI.tscn`

Memuat background `BG_MainMenu`, judul aset UI, tombol Play/Main, Settings, dan Quit. Semua tombol berbasis aset UI sehingga dapat ditukar lewat Inspector. Di bagian bawah terdapat karakter idle. Pengaturan audio memiliki slider Music dan SFX.

Panel pengaturan berada langsung di `UI/SettingsPanel` pada `MainMenuUI.tscn`. Node `SettingsCard`, `MusicSlider`, `SfxSlider`, dan `BackButton` sengaja diletakkan di scene agar posisi, teks, warna, ukuran, serta asetnya dapat diedit manual melalui Inspector tanpa membuat UI melalui script.

### Pemilihan karakter

Scene: `scenes/main_menu/CharacterSelectUI.tscn`

- Daftar kartu enam karakter di sisi kiri.
- Kartu terpilih memiliki warna/status berbeda.
- Sisi kanan adalah preview karakter, nama, serta informasi singkat.
- Tombol pilih dan mulai menjalankan level select.

### Pemilihan level

Scene: `scenes/main_menu/LevelSelectUI.tscn`

- Terdapat tiga kartu level.
- Level 1 terbuka dari awal.
- Level selanjutnya terkunci sampai level sebelumnya dimenangkan.
- Kartu menampilkan status, ikon lock, dan bintang.
- Kartu memiliki animasi masuk dan sedikit pembesaran saat dipilih.

### HUD dan pause

HUD dibuat runtime oleh `scripts/managers/hud.gd`.

Elemen yang tampil:

- Nama karakter.
- Ikon hati / HP.
- Ikon serta jumlah koin.
- Tombol pause di sisi kiri.

Menu pause menyediakan Lanjutkan, Ulangi Level, Pengaturan, dan Menu Utama. Menu dan tombol menggunakan aset bergaya kayu/pixel agar konsisten dengan tema permainan.

### Result screen

Scene: `scenes/ui/LevelResult.tscn`

Menampilkan menang/kalah, bintang dengan animasi, koin, waktu, dan tombol aksi. Pada kalah, nilai bintang selalu 0 tetapi jumlah koin dan waktu tetap ditampilkan.

## 9. Audio

`AudioManager` adalah autoload global: `scripts/managers/audio_manager.gd`.

Audio dipisahkan ke bus `Music` dan `SFX`, masing-masing dapat diatur dari Settings.

| Audio | File | Kondisi |
|---|---|---|
| Musik latar | `assets/audio/music/the_mountain-retro-game-music.mp3` | Menu dan permainan |
| Game mulai | `assets/audio/sfx/game-start.mp3` | Memulai permainan |
| Koin | `assets/audio/sfx/coin.mp3` | Mengambil koin |
| Menang | `assets/audio/sfx/game-win.mp3` | Setelah result menang muncul |
| Kalah | `assets/audio/sfx/game-over.mp3` | Setelah result kalah muncul |

Saat boss dikalahkan, SFX dan musik dihentikan sebelum transisi fade. SFX kemenangan baru diputar setelah result screen dibuat.

## 10. Penyimpanan Progres

Progres level disimpan lokal melalui `ConfigFile` di:

```text
user://me_and_friend_progress.cfg
```

Data yang disimpan adalah `unlocked_level`. Saat level dimenangkan, game membuka level berikutnya dengan `GameData.unlock_level(level_index + 1)`. Untuk menguji game dari awal, hapus file tersebut melalui FileSystem Godot atau lokasi `user://` proyek.

## 11. Struktur Direktori Penting

```text
assets/
├── audio/                       # Musik dan SFX
├── backgrounds/                 # Background menu dan tiga level
├── bosses/                      # Sprite dan portrait boss
├── characters/                  # Sprite/sprite sheet enam karakter
├── enemies/                     # Aset enemy dan proyektil
├── tiles/                       # Floor, obstacle, question block
└── ui/                          # Tombol, panel, ikon, result asset

scenes/
├── main_menu/
│   ├── Main.tscn                # Root/controller aplikasi
│   ├── MainMenuUI.tscn
│   ├── CharacterSelectUI.tscn
│   └── LevelSelectUI.tscn
├── levels/
│   ├── Level01.tscn
│   ├── Level02.tscn
│   └── Level03.tscn
├── player/                      # Enam scene karakter pemain
├── enemies/                     # Coin, Enemy, EnemyProjectile
├── bosses/                      # Boss dan variasi boss
├── tiles/                       # Floor, platform, obstacle, question block
└── ui/                          # Dialog, code editor, result, fade

scripts/
├── managers/
│   ├── main.gd                  # State/alur utama game
│   ├── game_data.gd             # Data karakter, level, boss, challenge, progres
│   ├── audio_manager.gd
│   ├── hud.gd
│   ├── main_menu_ui.gd
│   ├── character_select_ui.gd
│   └── level_select_ui.gd
├── player/
│   ├── player.gd
│   └── grid_sprite_sheet.gd
├── enemy/
│   ├── enemy.gd
│   ├── enemy_projectile.gd
│   └── coin.gd
├── boss/
│   ├── boss.gd
│   └── boss_challenge.gd
├── tiles/question_block.gd
├── ui/
│   ├── boss_dialogue_panel.gd
│   ├── code_challenge_editor.gd
│   ├── python_code_highlighter.gd
│   ├── python_challenge_judge.gd
│   ├── level_result.gd
│   └── boss_defeat_fade.gd
└── tools/safe_python_runner.py  # Sandbox runner Python
```

## 12. Titik Kustomisasi Cepat

| Keperluan | Lokasi yang diubah |
|---|---|
| Mengubah nama/dialog/challenge boss | `scripts/managers/game_data.gd` → `LEVELS` |
| Menambah karakter | `GameData.CHARACTERS`, scene karakter baru, aset sprite baru |
| Mengubah posisi koin/enemy/platform | Buka `Level01/02/03.tscn` di editor dan pindahkan instance node |
| Mengubah perilaku enemy | Inspector instance enemy atau `scripts/enemy/enemy.gd` |
| Menambah question block | Instance `QuestionBlock.tscn` di Level 3 / level lain |
| Mengubah UI menu | `MainMenuUI.tscn`, aset dalam `assets/ui/` |
| Mengubah karakter select | `CharacterSelectUI.tscn` dan `character_select_ui.gd` |
| Mengubah kartu level dan lock | `LevelSelectUI.tscn`, `level_select_ui.gd`, `GameData` |
| Mengganti audio | Ganti file aset lalu perbarui path di `audio_manager.gd` bila nama berubah |
| Mengatur font | Inspector node `Label` / `RichTextLabel` serta aset font proyek |

## 13. Catatan Pengembangan dan Batasan

- Aset sprite sheet AI dapat memiliki bagian tubuh melewati batas sel. Perbaiki source PNG di editor pixel seperti Aseprite/Piskel, atau atur region frame manual di Godot.
- Bila `grid_sprite_sheet.gd` aktif, edit `SpriteFrames` manual dapat ditimpa karena script membangun frame kembali.
- Python sandbox membutuhkan Python sesuai path pada `project.godot`. Bila Python tidak tersedia, validasi challenge Level 1–3 akan gagal.
- Jangan menjalankan kode Python pemain langsung tanpa `safe_python_runner.py`; challenge hanya boleh dieksekusi melalui sandbox.
- Objek tiap level harus ditempatkan pada scene level yang benar agar perubahan Level 2 tidak mengubah Level 1.
- Sebelum menghapus aset, cari dulu referensinya di `.tscn` dan `.gd` menggunakan `rg` agar tidak menghapus file yang masih dipakai.
- Audit pembersihan terakhir sudah menghapus `CharacterBase.tscn`, `SpikeObstacle.tscn`, helper UI lama, cache Python, dan metadata `.uid` yatim. Jangan menambahkan kembali file tersebut kecuali memang dipakai oleh scene atau script baru.

## 14. Ringkasan Nilai Multimedia

Proyek ini menerapkan unsur multimedia permainan secara terpadu:

- **Visual:** background pixel-art kampus, sprite karakter, boss, UI, tile, dan efek transisi.
- **Animasi:** idle, jalan, lompat, coding, enemy patrol, boss spawn/death, kartu UI, serta bintang result.
- **Audio:** musik latar, SFX koin, mulai, menang, kalah, dan pengaturan volume.
- **Interaksi:** kontrol platformer, pause, pemilihan karakter/level, tombol UI, dialog klik, serta code editor.
- **Logika:** collision sederhana, HP, checkpoint, progres, scoring bintang, level lock, enemy projectile, dan validasi kode Python aman.
- **Edukasi:** pemain belajar validitas sintaks Python, variabel, percabangan, assignment, dan perbaikan bug melalui konteks permainan.
