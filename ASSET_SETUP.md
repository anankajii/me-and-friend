# Setup asset tanpa ubah kode

Setiap objek gameplay memakai scene yang dapat diedit di Godot. Tambahkan atau ganti spritesheet hanya di scene terkait.

| Objek | Scene yang diedit | Node yang diperlukan |
|---|---|---|
| Khanan | `scenes/player/Khanan.tscn` | `AnimatedSprite2D` |
| Jeki | `scenes/player/Jeki.tscn` | `AnimatedSprite2D` |
| Bayu | `scenes/player/Bayu.tscn` | `AnimatedSprite2D` |
| Reni | `scenes/player/Reni.tscn` | `AnimatedSprite2D` |
| Ervania | `scenes/player/Ervania.tscn` | `AnimatedSprite2D` |
| Laras | `scenes/player/Laras.tscn` | `AnimatedSprite2D` |
| Enemy | `scenes/enemies/Enemy.tscn` | `AnimatedSprite2D` |
| Coin | `scenes/enemies/Coin.tscn` | `AnimatedSprite2D` |
| Boss | `scenes/bosses/Boss.tscn` | `AnimatedSprite2D` turunan dari Enemy |
| Obstacle | `scenes/tiles/Obstacle.tscn` | Ganti node `Visual` dengan `Sprite2D` atau `AnimatedSprite2D` |

## Character animations

Nama animasi yang dipakai game:

```text
idle       # diam
walk       # jalan kanan/kiri; kiri memakai flip_h otomatis
jump       # tersedia untuk animasi lompat
 damaged   # tersedia untuk animasi terkena musuh
coding     # tersedia untuk challenge boss
```

Tambahkan `AnimatedSprite2D`, buat `SpriteFrames`, slice spritesheet, dan beri nama animasi di atas. `player.gd` otomatis mencari node bernama `AnimatedSprite2D` di mana pun dalam scene—jadi perubahan posisi node tidak memerlukan perubahan kode. `CharacterBase.tscn` hanya template fungsi/collision, bukan karakter ketujuh.

## Enemy dan coin

Tambahkan `AnimatedSprite2D` ke scene masing-masing dan pilih animasi default di Inspector. `enemy.gd` dan `coin.gd` akan otomatis memutarnya pada `_ready()`.

`CollisionShape2D` jangan dihapus; atur bentuk/ukuran collision langsung di scene objeknya.

## Tileset dan obstacle map

Tileset aktif tersimpan di `assets/tiles/campus_tileset.png`. Untuk obstacle tunggal, buka
`scenes/tiles/Obstacle.tscn`, ganti node `Visual` dengan `Sprite2D`, lalu masukkan
texture melalui Inspector. Atur ukuran `CollisionShape2D` agar sesuai gambarnya.

Semua objek level sekarang ditempatkan manual di `scenes/levels/Level01.tscn`.
Buka scene tersebut, pilih objek, lalu gunakan Move Tool atau `Transform > Position`.
Drag scene `Platform.tscn`, `Obstacle.tscn`, `Coin.tscn`, atau `Enemy.tscn` dari
FileSystem ke node container yang sesuai untuk menambah objek baru.

Enemy memiliki properti `Patrol Enabled`, `Patrol Distance`, dan `Patrol Speed` di
Inspector. Semua properti tersebut dapat diatur tanpa mengubah kode.

Marker `PlayerSpawn`, `Checkpoint`, `BossTrigger`, `DeathLimit`, `CameraStart`, dan
`CameraEnd` juga dapat dipindahkan langsung melalui editor.
