\# PRD — Me and Friends



\## 1. Konsep



\*\*Me and Friends\*\* adalah game \*\*2D pixel-art platformer\*\* yang dibuat menggunakan \*\*Godot 4 + GDScript\*\*.



Gameplay terinspirasi platformer klasik seperti Mario, tetapi menggunakan karakter yang menggambarkan saya dan teman-teman.



Alur utama:



\*\*Pilih karakter → main level → kumpulkan coin → hindari enemy → sampai Boss → selesaikan coding challenge → Boss kalah → lanjut level.\*\*



\---



\## 2. Platform



\- Engine: Godot 4.x

\- Language: GDScript

\- Target: PC

\- Mode: Single Player

\- Style: 2D Pixel Art Side Scroller



\---



\## 3. Struktur Level



Game memiliki 3 level:



\### Level 1 — TI Campus

Background menggunakan gedung Teknologi Informasi dalam style pixel art.



Boss: \*\*Raja Syntax\*\*



Challenge:

```python

print("Hello World")

Level 2 — Forest



Tema hutan dengan platform dan rintangan lebih banyak.



Boss: Raja Variable



Challenge:



x = 10

print(x)

Level 3 — Digital World



Tema dunia digital/coding.



Boss: Final King



Challenge sederhana tentang if/else.



4\. Character



Pemain dapat memilih karakter:



Khanan

Friend 01

Friend 02

Friend 03



Untuk versi awal, semua karakter memiliki kemampuan yang sama. Perbedaannya hanya pada sprite dan nama.



5\. Gameplay



Player dapat:



Bergerak kiri/kanan

Melompat

Menginjak enemy

Terkena damage

Mengumpulkan coin

Menggunakan checkpoint

Melawan Boss



Control:



A / ←      = kiri

D / →      = kanan

SPACE      = lompat



Player memiliki 3 HP.



6\. Boss \& Coding Challenge



Setiap akhir level terdapat Raja.



Ketika Boss muncul:



BOSS

&#x20;↓

CODING CHALLENGE

&#x20;↓

INPUT JAWABAN

&#x20;↓

VALIDASI



Jawaban benar:



CORRECT!

KING DEFEATED!



Jawaban salah:



WRONG!

PLAYER LOSES 1 HP



Untuk MVP, kode tidak benar-benar dieksekusi. Jawaban cukup dibandingkan dengan jawaban yang sudah ditentukan.



7\. Scene Utama

MainMenu

&#x20;   ↓

CharacterSelect

&#x20;   ↓

Level01

&#x20;   ↓

Boss

&#x20;   ↓

Level02

&#x20;   ↓

Boss

&#x20;   ↓

Level03

&#x20;   ↓

FinalBoss

&#x20;   ↓

Victory

8\. Struktur res://

res://

├── assets/

│   ├── backgrounds/

│   ├── characters/

│   ├── enemies/

│   ├── bosses/

│   ├── tiles/

│   └── audio/

│

├── scenes/

│   ├── main\_menu/

│   ├── character\_select/

│   ├── levels/

│   └── bosses/

│

├── scripts/

│   ├── player/

│   ├── enemy/

│   ├── boss/

│   └── managers/

│

└── project.godot



Background Level 1:



res://assets/backgrounds/ti\_campus.png

9\. MVP



Fokus pertama:



Main Menu

Character Select

Player movement

Jump

Camera

Platform

Enemy sederhana

Coin

HP

Checkpoint

3 Level

Boss

Coding Challenge

Input jawaban

Validasi jawaban

Victory Screen



Jangan membuat multiplayer, database, login, inventory, atau sistem coding yang kompleks dulu.



10\. Urutan Development

1\. Setup Project Godot

2\. Player bisa jalan \& lompat

3\. Buat Level 1

4\. Tambahkan background kampus

5\. Tambahkan enemy \& coin

6\. Buat Character Select

7\. Buat Boss

8\. Buat Coding Challenge

9\. Buat Level 2 \& 3

10\. Tambahkan UI, sound, dan polish



Prioritas: game harus playable dulu, baru dipercantik.

