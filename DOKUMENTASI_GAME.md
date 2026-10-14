# Dokumentasi Game **Me And Friend**

## 1. Gambaran Umum

**Me And Friend** adalah game edukasi 2D bergenre *platformer* yang dibuat sebagai proyek pembelajaran mata kuliah **Multimedia Permainan**. Pemain menjelajahi area kampus bergaya *pixel-art*, mengumpulkan koin, menghindari atau mengalahkan musuh, dan menyelesaikan tantangan kode saat menghadapi boss.

Konsep utama game ini adalah menggabungkan unsur permainan platformer dengan latihan berpikir logis dan pengenalan pemrograman. Pemain tidak hanya diminta bergerak dan melompat, tetapi juga harus membaca instruksi, memahami tantangan kode, lalu mengirimkan jawaban yang benar agar dapat menyelesaikan level.

Game dibuat menggunakan **Godot Engine 4** dengan bahasa **GDScript**. Tampilan menggunakan aset visual *pixel-art*, animasi karakter, UI interaktif, musik latar, dan efek suara.

---

## 2. Tujuan Pengembangan

Tujuan aplikasi ini adalah:

- Menerapkan konsep dasar pengembangan game 2D.
- Membuat pengalaman belajar yang lebih interaktif melalui permainan.
- Menggabungkan elemen multimedia: gambar, animasi, teks, interaksi, musik, dan efek suara.
- Melatih pemahaman logika dasar pemrograman melalui tantangan kode.
- Menerapkan desain antarmuka permainan yang mudah dipahami pemain.

Dalam konteks mata kuliah Multimedia Permainan, proyek ini menunjukkan penggunaan aset grafis, animasi sprite, pengelolaan scene, collision, UI, audio, dan logika permainan dalam satu aplikasi.

---

## 3. Konsep Cerita dan Tema

Permainan mengambil latar lingkungan kampus teknologi informasi. Pemain memilih salah satu mahasiswa untuk memulai petualangan di area kampus. Sepanjang level, pemain menemukan rintangan, musuh berbentuk bug, dan koin.

Di akhir level terdapat boss bernama **Dosen Bug**. Boss ini menjadi representasi masalah atau bug dalam proses pemrograman. Untuk mengalahkannya, pemain harus menyelesaikan tantangan kode yang ditampilkan melalui editor bergaya *code editor*.

Tema ini dipilih agar pembelajaran pemrograman terasa lebih dekat dengan konteks mahasiswa dan lebih menarik dibandingkan latihan kode biasa.

---

## 4. Karakter yang Tersedia

Game menyediakan enam karakter yang dapat dipilih pemain.

| Karakter | Peran/Identitas dalam Game |
|---|---|
| Khanan | Pemimpin tim |
| Jeki | Super kompas |
| Bayu | Atlet lompat |
| Reni | Analis bug |
| Ervania | Logika UI |
| Laras | Data explorer |

Setiap karakter memiliki scene sendiri agar sprite, animasi, dan tampilannya dapat diatur secara terpisah melalui Godot Editor. Pemilihan karakter dilakukan sebelum level dimulai melalui scene pemilihan karakter.

Animasi karakter meliputi:

- **Idle**, saat karakter diam.
- **Walk/run**, saat karakter bergerak ke kiri atau kanan.
- **Jump**, saat karakter melompat.
- **Damaged**, saat terkena musuh.
- **Coding**, saat pemain memasuki tahap pengerjaan kode.

---

## 5. Alur Permainan

Alur utama permainan adalah sebagai berikut:

1. Pemain membuka **Main Menu**.
2. Pemain dapat menekan tombol Main/Play, membuka Pengaturan, atau keluar dari game.
3. Pemain memilih salah satu dari enam karakter.
4. Level 1 dimulai pada area kampus TI.
5. Pemain bergerak, melompat, mengumpulkan koin, dan menghadapi musuh.
6. Setelah mencapai area boss, kamera menampilkan kemunculan boss terlebih dahulu.
7. Dosen Bug menampilkan dialog pengantar tantangan.
8. Editor kode muncul setelah dialog selesai.
9. Pemain mengirim jawaban kode melalui tombol Kirim/Validasi.
10. Jika jawaban benar, boss dikalahkan dan game menampilkan layar hasil menang.
11. Jika jawaban salah sebanyak tiga kali atau HP pemain habis, game menampilkan layar hasil kalah.

---

## 6. Mekanik Gameplay

### 6.1 Pergerakan Pemain

Pemain dapat bergerak ke kiri dan kanan menggunakan tombol panah atau tombol **A** dan **D**. Pemain dapat melompat menggunakan tombol panah atas, tombol *accept*, atau **Space**.

Nilai dasar gerakan dalam game meliputi:

- Kecepatan horizontal: `300`.
- Kecepatan lompatan: `-520`.
- Gravitasi: `1200`.

Nilai ini dapat disesuaikan pada script pemain apabila diperlukan perubahan rasa kontrol permainan.

### 6.2 Koin

Koin ditempatkan secara manual pada scene level. Saat karakter berada dalam radius pengambilan koin, koin akan hilang, jumlah koin bertambah, HUD diperbarui, dan efek suara koin dimainkan.

Jumlah seluruh koin pada level digunakan sebagai dasar perhitungan bintang pada layar hasil.

### 6.3 Musuh

Musuh memiliki dua perilaku utama:

- **Idle**: musuh diam pada posisi yang ditempatkan di level.
- **Patrol**: musuh bergerak maju dan mundur dalam jarak yang dapat diatur.

Pemain dapat mengalahkan musuh dengan menginjaknya dari atas. Jika pemain menyentuh musuh dari samping atau bawah, HP pemain berkurang.

### 6.4 HP dan Checkpoint

Pemain memulai level dengan tiga HP. HUD menampilkan indikator hati untuk merepresentasikan HP.

- Jika terkena musuh, HP berkurang satu.
- Jika HP masih tersisa, pemain kembali ke checkpoint terakhir.
- Jika HP habis, permainan menampilkan layar hasil kalah.
- Checkpoint digunakan agar pemain tidak selalu kembali ke awal level.

### 6.5 Boss dan Tantangan Kode

Boss level pertama adalah **Dosen Bug**. Saat pemain memasuki area boss:

- Kamera melakukan zoom ke boss.
- Boss memainkan animasi kemunculan.
- Pemain tetap pada animasi idle selama dialog.
- Dialog boss menjelaskan bahwa pemain perlu memperbaiki atau melengkapi kode.
- Setelah dialog selesai, karakter pemain masuk ke animasi coding dan editor kode dibuka.

Tantangan level pertama meminta pemain melengkapi kode Python. Jawaban yang divalidasi pada data level adalah:

```python
print("Hello World")
```

Editor kode menggunakan font **JetBrains Mono** dan *syntax highlighter* sederhana. Warna teks membedakan kata kunci, fungsi, string, angka, komentar, dan identifier agar tampilannya menyerupai editor kode asli.

---

## 7. Sistem Menang, Kalah, dan Penilaian

### 7.1 Kondisi Menang

Pemain menang apabila berhasil mengirim jawaban kode yang benar saat menghadapi boss. Boss memainkan animasi kematian, kemudian arena melakukan fade singkat sebelum layar hasil tampil.

Saat boss dikalahkan:

1. Musik latar dan SFX aktif dihentikan.
2. Layar game melakukan fade gelap singkat.
3. Scene hasil permainan dimunculkan.
4. Efek suara kemenangan dimainkan.

### 7.2 Kondisi Kalah

Pemain kalah jika:

- HP habis setelah terkena musuh; atau
- Pemain salah mengirim jawaban tantangan kode sebanyak tiga kali.

Layar hasil kalah tetap menampilkan jumlah koin dan waktu yang telah diperoleh, tetapi jumlah bintangnya adalah nol.

### 7.3 Sistem Bintang

Penilaian hasil kemenangan didasarkan pada rasio koin yang dikumpulkan terhadap seluruh koin dalam level.

| Kondisi | Bintang |
|---|---:|
| Semua koin terkumpul | 3 bintang |
| Minimal 65% koin terkumpul | 2 bintang |
| Kurang dari 65% koin terkumpul | 1 bintang |
| Kalah | 0 bintang |

Layar hasil juga menampilkan:

- Jumlah koin: `koin didapat / total koin`.
- Durasi waktu penyelesaian level dalam format menit dan detik.
- Animasi kemunculan bintang.
- Tombol untuk mengulangi level, melanjutkan level berikutnya, atau kembali ke menu utama sesuai kondisi permainan.

---

## 8. Antarmuka Pengguna

### 8.1 Main Menu

Main menu menggunakan background kampus dan aset UI bertema *pixel-art*. Elemen utamanya adalah:

- Judul game dalam bentuk aset gambar.
- Tombol Main/Play.
- Tombol Settings/Pengaturan.
- Tombol Quit/Keluar.
- Preview karakter dengan animasi idle di bagian bawah menu.

Tombol menggunakan animasi *hover* berupa pembesaran kecil agar lebih responsif dan tidak terlihat datar.

### 8.2 Pemilihan Karakter

Scene pemilihan karakter menampilkan daftar enam kartu karakter di sisi kiri dan preview karakter terpilih di sisi kanan. Pemain dapat mengganti karakter sebelum memulai permainan.

Kartu karakter memuat portrait, nama, dan deskripsi singkat. Warna kartu normal serta kartu terpilih dibuat berbeda agar status pilihan mudah dikenali.

### 8.3 HUD dalam Level

HUD permainan menampilkan informasi penting secara langsung:

- Nama karakter yang digunakan.
- Indikator HP berbentuk hati.
- Jumlah koin yang telah dikumpulkan.
- Tombol pause.

### 8.4 Pause Menu

Menu pause dapat digunakan saat permainan berjalan. Pilihan yang tersedia adalah:

- Lanjutkan permainan.
- Ulangi level.
- Buka pengaturan.
- Kembali ke menu utama.

### 8.5 Pengaturan Audio

Panel pengaturan menyediakan slider terpisah untuk:

- **Music**, mengatur volume musik latar.
- **Sound Effect**, mengatur volume efek suara.

---

## 9. Sistem Audio

Audio dikelola melalui autoload `AudioManager`. Sistem ini membuat dua audio bus:

- `Music` untuk musik latar.
- `SFX` untuk seluruh efek suara.

Audio yang digunakan saat ini adalah:

| Audio | Kondisi Diputar |
|---|---|
| `the_mountain-retro-game-music.mp3` | Musik latar menu dan permainan |
| `game-start.mp3` | Saat pemain memulai permainan dari menu |
| `coin.mp3` | Saat pemain mengambil koin |
| `game-win.mp3` | Saat layar hasil kemenangan tampil |
| `game-over.mp3` | Saat pemain kalah |

Pengaturan volume tetap memengaruhi audio walaupun pemain berpindah antara scene menu, level, dan hasil permainan.

---

## 10. Struktur Scene dan Script

Berikut struktur utama proyek.

```text
scenes/
├── main_menu/
│   ├── Main.tscn                 # Scene utama dan controller game
│   ├── MainMenuUI.tscn           # Tampilan menu utama
│   └── CharacterSelectUI.tscn    # Tampilan pemilihan karakter
├── levels/
│   └── Level01.tscn              # Level kampus TI
├── player/
│   ├── CharacterBase.tscn
│   ├── Khanan.tscn
│   ├── Jeki.tscn
│   ├── Bayu.tscn
│   ├── Reni.tscn
│   ├── Ervania.tscn
│   └── Laras.tscn
├── enemies/
│   ├── Enemy.tscn
│   └── Coin.tscn
├── bosses/
│   └── Boss.tscn
└── ui/
    ├── BossDialoguePanel.tscn
    ├── CodeChallengeEditor.tscn
    ├── LevelResult.tscn
    └── BossDefeatFade.tscn

scripts/
├── managers/
│   ├── main.gd                   # Alur utama game dan pergantian scene
│   ├── game_data.gd              # Data karakter, level, soal, dan jawaban
│   ├── hud.gd                    # HUD, pause, dan pengaturan audio
│   └── audio_manager.gd           # Musik serta efek suara global
├── player/player.gd              # Gerak dan animasi karakter
├── enemy/
│   ├── enemy.gd                  # Musuh idle dan patroli
│   └── coin.gd                   # Perilaku koin
├── boss/
│   ├── boss.gd                   # Animasi boss
│   └── boss_challenge.gd         # Dialog dan tantangan boss
└── ui/
    ├── code_challenge_editor.gd
    ├── python_code_highlighter.gd
    ├── boss_dialogue_panel.gd
    ├── level_result.gd
    └── boss_defeat_fade.gd
```

---

## 11. Pengembangan Lanjutan

Beberapa pengembangan yang dapat dilakukan pada versi berikutnya adalah:

- Menambah level baru dengan soal pemrograman yang lebih bervariasi.
- Menambahkan jenis musuh dan pola gerak yang lebih kompleks.
- Menambahkan SFX untuk lompatan, serangan, kerusakan, tombol UI, dan boss.
- Menambah sistem penyimpanan skor, waktu terbaik, dan progres level.
- Menambah variasi tantangan Python, seperti percabangan, perulangan, variabel, dan fungsi.
- Menambahkan narasi antar-level agar cerita lebih kuat.
- Mengoptimalkan game untuk perangkat mobile atau web.

---

## 12. Kesimpulan

Me And Friend menunjukkan penerapan unsur multimedia permainan secara menyeluruh: visual pixel-art, animasi karakter, gameplay platformer, audio, UI, interaksi, dan pembelajaran coding. Game ini dirancang agar pemain dapat belajar konsep pemrograman dasar melalui aktivitas bermain yang lebih menarik, sekaligus menjadi media praktik pengembangan game menggunakan Godot Engine.
