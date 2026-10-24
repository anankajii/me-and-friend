# Dokumentasi Game: Me And Friend

## Gambaran Umum

**Me And Friend** adalah game edukasi platformer 2D bergaya pixel-art yang dibuat untuk mata kuliah **Multimedia Permainan**. Game dikembangkan menggunakan **Godot Engine 4.7** dan GDScript. Pemain memilih satu dari enam mahasiswa, menjelajahi tiga area kampus, mengumpulkan koin, menghadapi enemy, lalu menyelesaikan challenge Python untuk menghentikan serangan ransomware.

Game menggabungkan visual pixel-art, sprite dan animasi, musik, efek suara, antarmuka interaktif, gameplay platformer, serta latihan logika pemrograman dalam satu aplikasi.

## Premis Cerita

Menjelang masa KRS, jaringan kampus lumpuh total. Sekelompok hacker misterius menyandera database mahasiswa dan meminta tebusan nilai A. Malware menyebar dari Area Kampus Cabang, Gedung JTI, hingga Gedung Rektorat.

Pemain bertugas melacak sinyal ransomware, menghentikan malware, mengaktifkan pertahanan lokal, lalu mendekripsi Data Kampus utama sebelum data hilang.

## Karakter Pemain

Tersedia tepat enam karakter, masing-masing memiliki scene dan sprite sendiri sehingga ukuran, collision, serta animasinya dapat diedit manual melalui Godot Editor.

| Karakter | Peran |
|---|---|
| Khanan | Pemimpin tim |
| Jeki | Super kompas |
| Bayu | Atlet lompat |
| Reni | Analis bug |
| Ervania | Logika UI |
| Laras | Data explorer |

Animasi yang digunakan adalah `idle`, `walk`, `jump`, `damaged`, dan `coding`. Animasi `coding` hanya dipakai ketika dialog boss selesai dan code editor dibuka.

## Alur Permainan

```text
Main Menu
  -> Pilih Karakter
  -> Pilih Level
  -> Platformer: koin, platform, enemy, checkpoint
  -> Boss trigger
  -> Kamera zoom dan animasi boss
  -> Dialog boss
  -> Code editor challenge
  -> Menang / kalah
  -> Result screen
```

Level berikutnya terkunci sampai level sebelumnya diselesaikan. Progres pembukaan level tersimpan secara lokal pada `user://me_and_friend_progress.cfg`.

## Level, Boss, dan Challenge

| Level | Lokasi | Boss | Challenge |
|---|---|---|---|
| 1 | Area Kampus Cabang | Poor Hacker (Script Kiddie) | Menulis kode Python bebas yang valid untuk menembus firewall dasar. |
| 2 | Gedung JTI | Poor Hacker (Malware Spammer) | Menulis Python valid dengan minimal satu variabel untuk mengaktifkan pertahanan lokal. |
| 3 | Gedung Rektorat | Ketua Sindikat Hacker | Memperbaiki program Python sembilan baris hingga mencetak `Data Kampus: pulih`. |

Ketiga boss memakai aset pixel-art dan animasi spawn, idle, serta death. Khusus boss Level 3 menggunakan visual hacker ber-hoodie dengan topeng anonim.

Saat pemain memasuki `BossTrigger`, player berhenti dalam posisi idle, kamera melakukan zoom, boss muncul, lalu dialog ditampilkan di bawah layar. Player dapat menekan dialog untuk melanjutkan. Code editor baru tampil setelah dialog terakhir selesai.

## Gameplay

### Kontrol

- Bergerak: `A` / `D` atau panah kiri / kanan.
- Lompat: `Space`, panah atas, atau aksi accept.
- Pause: tombol pause pada HUD.

### Koin dan bintang

Koin ditempatkan manual pada node `Coins` di setiap scene level. Nilai bintang pada result screen dihitung dari rasio koin yang dikumpulkan.

| Hasil | Bintang |
|---|---:|
| Semua koin didapat | 3 |
| Minimal 65% koin didapat | 2 |
| Di bawah 65% koin didapat | 1 |
| Kalah | 0 |

Result screen selalu menampilkan jumlah koin dan durasi permainan. Bintang muncul dengan animasi.

### HP, checkpoint, dan gagal

Pemain memiliki tiga HP, yang ditampilkan sebagai ikon hati pada HUD. Tersentuh enemy atau proyektil akan mengurangi HP dan pemain kembali ke checkpoint jika HP masih ada. Pemain kalah apabila HP habis, termasuk setelah tiga jawaban code challenge yang salah.

### Enemy dan question block

Enemy dapat dibuat idle atau patrol melalui Inspector. Pada level lanjut, enemy dapat menembak satu atau tiga proyektil horizontal; tembakan tidak mengejar posisi player.

Level 3 memiliki `QuestionBlock.tscn`, yaitu blok tanda tanya yang dipukul dari bawah. Hadiahnya dapat diatur manual melalui Inspector menjadi koin atau enemy.

## Code Editor dan Keamanan

Code editor reusable menggunakan tampilan seperti VS Code: panel gelap tidak transparan, nomor baris, font JetBrains Mono, dan syntax highlighting untuk keyword, fungsi, string, angka, komentar, serta identifier.

Validasi challenge memakai Python asli melalui `scripts/tools/safe_python_runner.py`. Script tersebut memeriksa AST lebih dahulu dan hanya memperbolehkan subset aman seperti assignment sederhana, kondisi dasar, operasi sederhana, dan `print()`. Import, akses file, atribut, class, function, loop, `eval`, serta `exec` ditolak.

## UI dan Audio

### Main menu dan pengaturan

Main menu memakai background kampus, judul aset, serta tombol Play, Settings, dan Quit. Enam karakter idle tampil di bagian bawah.

Panel Settings dibuat langsung dalam scene `MainMenuUI.tscn`, bukan dibuat lewat kode. Di bawah `UI/SettingsPanel` tersedia node `SettingsCard`, `MusicSlider`, `SfxSlider`, dan `BackButton`. Artinya posisi, teks, warna, ukuran, atau aset tombol dapat diubah langsung lewat Inspector Godot tanpa mengubah script.

### Pemilihan karakter dan level

Scene pemilihan karakter menampilkan enam kartu di sisi kiri serta preview karakter aktif di sisi kanan. Scene pemilihan level menampilkan tiga kartu, status lock, dan bintang progres.

### HUD dan pause

HUD menampilkan nama karakter, tiga hati HP, jumlah koin, dan tombol pause di sisi kiri. Pause menu menyediakan Lanjutkan, Ulangi Level, Pengaturan, dan Menu Utama.

### Audio

`AudioManager` mengelola bus `Music` dan `SFX`. Volume keduanya diatur melalui slider Settings dan tetap berlaku saat berpindah menu atau level.

| Audio | Kondisi |
|---|---|
| Musik latar | Menu dan permainan |
| Game start | Saat level dimulai |
| Coin | Saat koin diambil |
| Game win | Saat result menang muncul |
| Game over | Saat result kalah muncul |

Saat boss dikalahkan, musik dan SFX aktif dihentikan, fade transisi dimainkan, kemudian result screen muncul dan SFX kemenangan diputar.

## Struktur Penting Proyek

```text
scenes/main_menu/  Main.tscn, MainMenuUI.tscn, CharacterSelectUI.tscn, LevelSelectUI.tscn
scenes/levels/     Level01.tscn, Level02.tscn, Level03.tscn
scenes/player/     Khanan.tscn, Jeki.tscn, Bayu.tscn, Reni.tscn, Ervania.tscn, Laras.tscn
scenes/enemies/    Coin.tscn, Enemy.tscn, EnemyProjectile.tscn
scenes/bosses/     Boss level 1 sampai 3
scenes/tiles/      Floor, Platform, Obstacle, QuestionBlock
scenes/ui/         Dialog boss, code editor, result, fade
scripts/managers/  Controller utama, data game, HUD, audio, UI menu
```

## Titik Kustomisasi Manual

| Keperluan | Lokasi |
|---|---|
| Posisi coin, enemy, platform, obstacle | Scene `Level01`, `Level02`, atau `Level03` di Godot Editor |
| Perilaku enemy | Inspector pada instance Enemy atau `scripts/enemy/enemy.gd` |
| Hadiah question block | Inspector instance `QuestionBlock.tscn` |
| Dialog, boss, dan challenge | `scripts/managers/game_data.gd` |
| Tampilan menu dan settings | `scenes/main_menu/MainMenuUI.tscn` |
| Kartu karakter | `CharacterSelectUI.tscn` dan `character_select_ui.gd` |
| Kartu level dan lock | `LevelSelectUI.tscn`, `level_select_ui.gd`, dan `game_data.gd` |
| Audio | Aset audio dan `audio_manager.gd` |

## Status Audit dan Pembersihan

Setelah audit, proyek berhasil memuat Main Menu serta Level 1--3 tanpa error game pada pemeriksaan headless. Referensi `res://` aktif ditemukan. Scene template karakter lama, spike obstacle yang sudah tidak digunakan, helper UI lama, cache Python, dan metadata `.uid` yatim telah dibersihkan. Aset serta skrip yang masih dipakai dipertahankan.

## Kesimpulan

Me And Friend menerapkan unsur multimedia permainan secara terpadu: visual pixel-art, animasi, audio, interaksi UI, gameplay platformer, penyimpanan progres, dan latihan Python berbasis konteks ransomware kampus. Proyek ini dapat dikembangkan lebih lanjut dengan menambah level, pola enemy, jenis challenge, dan variasi audio tanpa mengubah struktur dasar permainan.
