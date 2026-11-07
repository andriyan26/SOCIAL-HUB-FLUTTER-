# 📱 Social Hub (Flutter Clean Architecture & Local Database)

Aplikasi media sosial modern bertema vertikal video & reels (ala TikTok) yang dibangun dengan standar industri **Clean Architecture** (Presentation, Domain, Data, Core), database lokal **SQLite (sqflite)**, **Persistent Session (SharedPreferences)**, dan terintegrasi penuh dengan video sinematik serta aset visual.

---

## 📸 Referensi Fitur & Tampilan (Berdasarkan Aset Pengguna)

| Layar / Fitur | File Referensi | Deskripsi Implementasi |
| :--- | :--- | :--- |
| **Landing & Welcome** | `KONSEP SEBELUM LOGIN.mp4` | Looping video player sinematik dengan overlay gradien & tombol aksi masuk/daftar. |
| **Login & Transisi** | `KONSEP LOGIN.mp4` | Alur animasi transisi mulus, form validation, autentikasi SQLite, dan loading state. |
| **Beranda / Video Feed** | `IMG_8664.jpg` | Feed vertikal reels, tombol aksi (Love counter, Comments, Bookmark, Share), tab atas (LIVE, Komunitas, Depok, Mengikuti, Saran), piringan musik berputar, dan audio ticker. |
| **Teman / Komunitas** | `IMG_8665.jpg` | Halaman teman dengan sinkronisasi kontak (*Temukan Kontak*), pencarian, daftar rekomendasi akun (`ei.kaa`, `s`, `Angsuran17`, dll.), tombol *Hapus*, dan tombol *Ikuti/Mengikuti* real-time. |
| **Kamera & Studio Konten** | `IMG_8666.jpg` | Viewfinder kamera live, panel alat vertikal (Flip, Flash, Timer, Grid, Filter Kecantikan, Captions), pemilih durasi (10 mnt, 60 dtk, 15 dtk, FOTO, TEKS), tombol rekam pulsating merah, dan pemilih filter. |
| **Kotak Masuk / Notifikasi**| `IMG_8667.jpg` | Header dropdown status, row story/widget, kategori notifikasi (*Aktivitas*, *Sistem*, *TikTok Tako*, *Pesan Toko*, *Direct Message*), unread badge, dan saran akun. |
| **Profil Akun** | `IMG_8668.jpg` | Info profil (`@andrianpei`, bio *Taken 🤍*, avatar ungu `a` dengan badge story), statistik akun, tombol edit profil (tersimpan ke database), dan grid pos 3-kolom dengan indikator tayangan `▷ 0`. |

---

## 🏗️ Arsitektur Proyek (Clean Architecture)

```
lib/
├── core/
│   ├── constants/             # AppColors (TikTok style), AppAssets, AppStrings
│   ├── database/              # SQLite database (sqflite + web fallback cross-platform)
│   ├── services/              # SessionService (Persistent Login Session)
│   ├── theme/                 # AppTheme (Dark mode & typography)
│   └── utils/                 # Formatters (format count '844.3 rb', tanggal, dll.)
│
├── data/
│   ├── datasources/           # LocalDataSource (Akses tabel SQLite)
│   ├── models/                # UserModel, PostModel, NotificationModel, FriendModel
│   └── repositories/          # Implementasi Repository Domain
│
├── domain/
│   ├── entities/              # UserEntity, PostEntity, NotificationEntity, FriendEntity
│   └── repositories/          # Interface Kontrak Repository
│
└── presentation/
    ├── providers/             # State Management (AuthProvider, FeedProvider, dll.)
    ├── screens/
    │   ├── landing/           # LandingScreen (Video looping background)
    │   ├── auth/              # LoginScreen & RegisterScreen
    │   ├── main/              # MainScreen (Bottom Navigation Bar)
    │   ├── feed/              # FeedScreen (Video reels & overlay interaktif)
    │   ├── community/         # CommunityScreen (Teman & Kontak)
    │   ├── camera/            # CameraStudioScreen (Studio & Shutter)
    │   ├── inbox/             # InboxScreen (Notifikasi & Pesan)
    │   └── profile/           # ProfileScreen (Profil & 3x3 Grid Galeri)
    └── widgets/               # TikTokNavBar, CustomButton, CustomTextField
```

---

## 🗄️ Skema Database SQLite Lokal

Aplikasi menggunakan skema database lokal dengan tabel:
1. `users`: Menyimpan kredensial pengguna, profil bio, jumlah following/followers, dan avatar.
2. `posts`: Menyimpan video postingan, jumlah likes, komentar, share, bookmark, dan play count.
3. `notifications`: Menyimpan pesan sistem, aktivitas teman, chat tako, dan status `is_read`.
4. `friends`: Menyimpan daftar akun rekomendasi kontak dengan status `is_following`.
5. `comments`: Menyimpan komentar interaktif pengguna pada setiap video.

### Akun Bawaan (Pre-Seeded) untuk Uji Coba:
- **Username:** `andrianpei`
- **Password:** `password123`
*(Sesi login otomatis tersimpan di SharedPreferences/SQLite, sehingga tidak perlu login ulang saat aplikasi dibuka kembali).*

---

## ☁️ Menjalankan di GitHub Codespaces (1-Click Run)

Repository ini telah dilengkapi dengan `.devcontainer/devcontainer.json` sehingga dapat dijalankan secara instan di browser melalui GitHub Codespaces:

1. Buka repositori Anda di GitHub: `https://github.com/andriyan26/SOCIAL-HUB-FLUTTER-`
2. Klik tombol hijau **Code** -> pilih tab **Codespaces** -> klik **Create codespace on main**.
3. Setelah environment siap, terminal Codespace akan otomatis melakukan `flutter pub get`.
4. Jalankan aplikasi web dengan perintah:
   ```bash
   flutter run -d web-server --web-port=8080 --web-hostname=0.0.0.0
   ```
5. Codespaces akan otomatis membuka pop-up pratinjau browser atau Anda dapat membuka tab **Ports** dan klik tautan pada port **8080**.

---

## 💻 Menjalankan Secara Lokal (Local Machine)

1. Pastikan Flutter SDK telah terinstal:
   ```bash
   flutter doctor
   ```
2. Pasang semua dependensi:
   ```bash
   flutter pub get
   ```
3. Jalankan di perangkat emulator / Chrome / Windows:
   ```bash
   flutter run
   ```

---

## 🚀 Push ke GitHub Repository

Untuk mengunggah seluruh kode ini ke repositori `https://github.com/andriyan26/SOCIAL-HUB-FLUTTER-.git`:

```bash
git init
git add .
git commit -m "feat: complete social hub flutter clean architecture with local sqlite and media integration"
git branch -M main
git remote add origin https://github.com/andriyan26/SOCIAL-HUB-FLUTTER-.git
git push -u origin main
```
