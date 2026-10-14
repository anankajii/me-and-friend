Option Explicit

' Macro Microsoft Word untuk membuat dokumentasi game Me And Friend.
' Cara pakai: Word > Alt+F11 > Insert > Module > Import File,
' lalu pilih file DOKUMENTASI_GAME_WORD.bas dan jalankan BuatDokumentasiMeAndFriend.

Public Sub BuatDokumentasiMeAndFriend()
    Dim doc As Document
    Set doc = Documents.Add

    AturFormatDokumen doc

    TambahJudul doc, "DOKUMENTASI GAME ME AND FRIEND"
    TambahParagraf doc, "Game Edukasi 2D untuk Mata Kuliah Multimedia Permainan", wdStyleSubtitle

    TambahHeading doc, "1. Gambaran Umum", wdStyleHeading1
    TambahParagraf doc, "Me And Friend adalah game edukasi 2D bergenre platformer yang dibuat sebagai proyek pembelajaran mata kuliah Multimedia Permainan. Pemain menjelajahi area kampus bergaya pixel-art, mengumpulkan koin, menghindari atau mengalahkan musuh, serta menyelesaikan tantangan kode saat menghadapi boss.", wdStyleNormal
    TambahParagraf doc, "Konsep game menggabungkan unsur permainan platformer dengan latihan berpikir logis dan pengenalan pemrograman. Pemain tidak hanya bergerak dan melompat, tetapi juga membaca instruksi, memahami soal kode, lalu mengirimkan jawaban untuk menyelesaikan level.", wdStyleNormal
    TambahParagraf doc, "Aplikasi dibuat menggunakan Godot Engine 4 dengan bahasa GDScript. Visual menggunakan gaya pixel-art dengan dukungan animasi karakter, antarmuka interaktif, musik, dan efek suara.", wdStyleNormal

    TambahHeading doc, "2. Tujuan Pengembangan", wdStyleHeading1
    TambahBullet doc, "Menerapkan konsep dasar pengembangan game 2D."
    TambahBullet doc, "Membuat media belajar pemrograman yang lebih interaktif."
    TambahBullet doc, "Menggabungkan gambar, animasi, teks, interaksi, musik, dan efek suara."
    TambahBullet doc, "Menerapkan desain antarmuka permainan yang mudah dipahami pemain."
    TambahBullet doc, "Melatih pengelolaan scene, collision, UI, audio, dan logika permainan."

    TambahHeading doc, "3. Konsep Cerita dan Tema", wdStyleHeading1
    TambahParagraf doc, "Permainan berlatar lingkungan kampus teknologi informasi. Pemain memilih salah satu mahasiswa untuk menjelajahi area kampus, menghadapi bug sebagai musuh, dan mengumpulkan koin. Di akhir level terdapat boss bernama Dosen Bug yang melambangkan masalah atau bug dalam proses pemrograman.", wdStyleNormal
    TambahParagraf doc, "Untuk mengalahkan Dosen Bug, pemain harus menyelesaikan tantangan kode. Dengan demikian, aktivitas belajar pemrograman dimasukkan ke dalam alur permainan tanpa menghilangkan unsur petualangan dan tantangan platformer.", wdStyleNormal

    TambahHeading doc, "4. Karakter", wdStyleHeading1
    TambahBullet doc, "Khanan - Pemimpin tim."
    TambahBullet doc, "Jeki - Super kompas."
    TambahBullet doc, "Bayu - Atlet lompat."
    TambahBullet doc, "Reni - Analis bug."
    TambahBullet doc, "Ervania - Logika UI."
    TambahBullet doc, "Laras - Data explorer."
    TambahParagraf doc, "Setiap karakter mempunyai scene sendiri sehingga sprite, ukuran, dan animasinya dapat diedit secara terpisah melalui Godot Editor. Animasi yang tersedia meliputi idle, berjalan, melompat, terkena damage, dan coding.", wdStyleNormal

    TambahHeading doc, "5. Alur Permainan", wdStyleHeading1
    TambahNomor doc, "Pemain membuka Main Menu."
    TambahNomor doc, "Pemain memilih Main/Play lalu memilih salah satu karakter."
    TambahNomor doc, "Level 1 dimulai pada area kampus TI."
    TambahNomor doc, "Pemain bergerak, melompat, mengambil koin, dan menghadapi musuh."
    TambahNomor doc, "Pemain mencapai area boss dan melihat animasi kemunculan Dosen Bug."
    TambahNomor doc, "Dialog boss tampil sebelum editor kode dibuka."
    TambahNomor doc, "Pemain mengirim jawaban melalui editor kode."
    TambahNomor doc, "Game menampilkan hasil menang atau kalah sesuai kondisi permainan."

    TambahHeading doc, "6. Mekanik Gameplay", wdStyleHeading1
    TambahHeading doc, "6.1 Kontrol Pemain", wdStyleHeading2
    TambahParagraf doc, "Pemain bergerak menggunakan tombol panah atau tombol A dan D. Pemain melompat menggunakan panah atas, tombol accept, atau Space. Sistem fisika menggunakan kecepatan horizontal, gravitasi, dan kecepatan lompatan yang dapat disesuaikan pada script pemain.", wdStyleNormal

    TambahHeading doc, "6.2 Koin", wdStyleHeading2
    TambahParagraf doc, "Koin ditempatkan manual pada scene level. Saat pemain berada dalam radius pengambilan, koin menghilang, total koin bertambah, HUD diperbarui, dan efek suara coin dimainkan. Total koin digunakan untuk perhitungan bintang pada layar hasil.", wdStyleNormal

    TambahHeading doc, "6.3 Musuh", wdStyleHeading2
    TambahParagraf doc, "Musuh dapat bersifat idle atau melakukan patroli maju-mundur. Pemain dapat mengalahkan musuh dengan menginjaknya dari atas. Sentuhan dari samping atau bawah mengurangi HP pemain.", wdStyleNormal

    TambahHeading doc, "6.4 HP dan Checkpoint", wdStyleHeading2
    TambahParagraf doc, "Pemain memulai level dengan tiga HP. Jika terkena musuh, HP berkurang dan pemain kembali ke checkpoint terakhir. Jika HP habis, game menampilkan hasil kalah. Checkpoint mencegah pemain harus selalu kembali ke awal level.", wdStyleNormal

    TambahHeading doc, "6.5 Boss dan Tantangan Kode", wdStyleHeading2
    TambahParagraf doc, "Saat pemain memasuki area boss, kamera melakukan zoom, Dosen Bug memainkan animasi kemunculan, dan dialog ditampilkan. Setelah dialog selesai, editor kode bergaya code editor terbuka. Pemain harus mengirim jawaban yang benar untuk mengalahkan boss.", wdStyleNormal
    TambahParagraf doc, "Tantangan level pertama meminta pemain melengkapi kode Python. Jawaban yang divalidasi adalah: print(""Hello World""). Editor kode menggunakan font JetBrains Mono dan syntax highlighter untuk membedakan kata kunci, fungsi, string, angka, komentar, dan identifier.", wdStyleNormal

    TambahHeading doc, "7. Sistem Menang, Kalah, dan Bintang", wdStyleHeading1
    TambahParagraf doc, "Pemain menang setelah mengirim jawaban kode yang benar. Boss memainkan animasi kematian, musik serta efek suara dihentikan, arena melakukan fade singkat, kemudian layar hasil muncul dan efek suara game-win diputar.", wdStyleNormal
    TambahParagraf doc, "Pemain kalah apabila HP habis atau jawaban kode salah sebanyak tiga kali. Layar hasil kalah tetap menampilkan koin dan waktu, tetapi jumlah bintang adalah nol.", wdStyleNormal
    TambahBullet doc, "3 bintang: seluruh koin dalam level terkumpul."
    TambahBullet doc, "2 bintang: minimal 65 persen koin terkumpul."
    TambahBullet doc, "1 bintang: kurang dari 65 persen koin terkumpul, tetapi level berhasil diselesaikan."
    TambahBullet doc, "0 bintang: pemain kalah."

    TambahHeading doc, "8. Antarmuka Pengguna", wdStyleHeading1
    TambahBullet doc, "Main Menu: judul game, tombol Main/Play, Settings, Quit, dan preview karakter idle."
    TambahBullet doc, "Pemilihan Karakter: enam kartu karakter di sisi kiri dan preview karakter terpilih di sisi kanan."
    TambahBullet doc, "HUD: nama karakter, indikator HP berbentuk hati, jumlah koin, dan tombol pause."
    TambahBullet doc, "Pause Menu: lanjutkan permainan, ulangi level, pengaturan, dan menu utama."
    TambahBullet doc, "Pengaturan Audio: slider terpisah untuk Music dan Sound Effect."
    TambahBullet doc, "Layar Hasil: bintang, jumlah koin, waktu penyelesaian, dan tombol aksi berikutnya."

    TambahHeading doc, "9. Sistem Audio", wdStyleHeading1
    TambahParagraf doc, "Audio dikelola oleh AudioManager sebagai autoload. Sistem memiliki bus Music untuk musik latar dan SFX untuk efek suara. Volume kedua bus dapat diatur melalui slider pada menu dan pause menu.", wdStyleNormal
    TambahBullet doc, "the_mountain-retro-game-music.mp3 sebagai musik latar."
    TambahBullet doc, "game-start.mp3 saat pemain memulai permainan."
    TambahBullet doc, "coin.mp3 saat pemain mengambil koin."
    TambahBullet doc, "game-win.mp3 saat layar hasil kemenangan muncul."
    TambahBullet doc, "game-over.mp3 saat pemain kalah."

    TambahHeading doc, "10. Struktur Teknis Proyek", wdStyleHeading1
    TambahParagraf doc, "Scene utama mencakup Main Menu, Character Select, Level01, scene karakter, musuh, boss, dialog boss, Code Challenge Editor, Level Result, dan Boss Defeat Fade. Script utama berada pada folder managers, player, enemy, boss, dan ui.", wdStyleNormal
    TambahBullet doc, "main.gd mengatur alur menu, level, HP, koin, boss, hasil, dan pergantian scene."
    TambahBullet doc, "game_data.gd menyimpan data karakter, level, pertanyaan, dan jawaban."
    TambahBullet doc, "player.gd menangani gerakan, lompatan, fisika, dan animasi pemain."
    TambahBullet doc, "enemy.gd menangani musuh idle, patroli, stomp, dan damage."
    TambahBullet doc, "audio_manager.gd menangani musik serta SFX global."
    TambahBullet doc, "python_code_highlighter.gd mengatur warna sintaks pada editor kode."

    TambahHeading doc, "11. Pengembangan Lanjutan", wdStyleHeading1
    TambahBullet doc, "Menambah level dan variasi soal pemrograman."
    TambahBullet doc, "Menambah SFX lompatan, damage, tombol, dan boss."
    TambahBullet doc, "Menambahkan penyimpanan skor, waktu terbaik, dan progres level."
    TambahBullet doc, "Menambahkan materi Python seperti variabel, percabangan, perulangan, dan fungsi."
    TambahBullet doc, "Mengoptimalkan game untuk web atau perangkat mobile."

    TambahHeading doc, "12. Kesimpulan", wdStyleHeading1
    TambahParagraf doc, "Me And Friend menerapkan unsur multimedia permainan secara menyeluruh melalui visual pixel-art, animasi, gameplay platformer, audio, UI, dan tantangan coding. Game ini dapat menjadi media pembelajaran yang lebih menarik sekaligus menjadi bukti penerapan konsep pengembangan game 2D menggunakan Godot Engine.", wdStyleNormal

    MsgBox "Dokumentasi Word berhasil dibuat.", vbInformation, "Me And Friend"
End Sub

Private Sub AturFormatDokumen(ByVal doc As Document)
    With doc.PageSetup
        .TopMargin = CentimetersToPoints(2.5)
        .BottomMargin = CentimetersToPoints(2.5)
        .LeftMargin = CentimetersToPoints(3)
        .RightMargin = CentimetersToPoints(3)
    End With

    With doc.Styles(wdStyleNormal)
        .Font.Name = "Times New Roman"
        .Font.Size = 12
        .ParagraphFormat.Alignment = wdAlignParagraphJustify
        .ParagraphFormat.SpaceAfter = 6
        .ParagraphFormat.LineSpacingRule = wdLineSpace1pt5
    End With
End Sub

Private Sub TambahJudul(ByVal doc As Document, ByVal isi As String)
    Dim rng As Range
    Set rng = doc.Range(doc.Content.End - 1, doc.Content.End - 1)
    rng.Style = wdStyleTitle
    rng.ParagraphFormat.Alignment = wdAlignParagraphCenter
    rng.Text = isi & vbCr
End Sub

Private Sub TambahHeading(ByVal doc As Document, ByVal isi As String, ByVal gaya As WdBuiltinStyle)
    Dim rng As Range
    Set rng = doc.Range(doc.Content.End - 1, doc.Content.End - 1)
    rng.Style = gaya
    rng.ParagraphFormat.Alignment = wdAlignParagraphLeft
    rng.Text = isi & vbCr
End Sub

Private Sub TambahParagraf(ByVal doc As Document, ByVal isi As String, ByVal gaya As WdBuiltinStyle)
    Dim rng As Range
    Set rng = doc.Range(doc.Content.End - 1, doc.Content.End - 1)
    rng.Style = gaya
    rng.Text = isi & vbCr & vbCr
End Sub

Private Sub TambahBullet(ByVal doc As Document, ByVal isi As String)
    Dim rng As Range
    Set rng = doc.Range(doc.Content.End - 1, doc.Content.End - 1)
    rng.Style = wdStyleNormal
    rng.ParagraphFormat.LeftIndent = CentimetersToPoints(0.7)
    rng.ParagraphFormat.FirstLineIndent = CentimetersToPoints(-0.35)
    rng.Text = ChrW(8226) & " " & isi & vbCr
End Sub

Private Sub TambahNomor(ByVal doc As Document, ByVal isi As String)
    Static nomor As Integer
    Dim rng As Range

    nomor = nomor + 1
    Set rng = doc.Range(doc.Content.End - 1, doc.Content.End - 1)
    rng.Style = wdStyleNormal
    rng.ParagraphFormat.LeftIndent = CentimetersToPoints(0.7)
    rng.ParagraphFormat.FirstLineIndent = CentimetersToPoints(-0.35)
    rng.Text = CStr(nomor) & ". " & isi & vbCr

    If nomor = 8 Then nomor = 0
End Sub
