# Project Skills & Tools

## 🛠️ Core Technologies

| Technology | Version | Purpose |
|------------|---------|---------|
| **Flutter** | 3.19 | Framework utama untuk pengembangan aplikasi multi-platform |
| **Dart** | 3.3 | Bahasa pemrograman utama |
| **Flutter Secure Storage** | ^8.0.0 | Penyimpanan data terenkripsi |
| **Flutter Localizations** | ^0.18.1 | Dukungan multi-bahasa |
| **Intl** | ^0.18.1 | Internasionalisasi |
| **Flutter Lints** | ^2.0.0 | Aturan linting dan analisis statis |

---

## 📦 Dependencies Utama

### Flutter Secure Storage
- **Tujuan:** Menyimpan environment variables secara aman.
- **Referensi:** [pub.dev/packages/flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage)

### Flutter Lints
- **Tujuan:** Meningkatkan kualitas code dengan aturan linting yang ketat.
- **Aturan yang digunakan:**
  - `prefer_const_constructors`
  - `avoid_print`
  - `sort_pub_dependencies`
  - `directives_ordering`
  - `unawaited_futures`
  - Lebih dari 100 aturan lainnya.

### Flutter Localizations & Intl
- **Tujuan:** Dukungan multi-bahasa (Inggris dan Indonesia).
- **Referensi:** [flutter.dev/docs/development/accessibility-and-localization/internationalization](https://docs.flutter.dev/development/accessibility-and-localization/internationalization)

---

## 🚀 Development Tools

| Tool | Purpose |
|------|---------|
| **GitHub Actions** | CI/CD pipeline untuk automated testing dan build |
| **VS Code / Android Studio** | IDE utama untuk pengembangan |
| **Git** | Version control |
| **Dart DevTools** | Debugging dan analisis performa |

---

## 📡 CI/CD Pipeline

### GitHub Actions Workflows

#### 1. **Linting (`lint.yml`)**
- **Tujuan:** Analisis statis dan linting.
- **Langkah-langkah:**
  - Checkout code
  - Setup Flutter
  - Install dependencies
  - Run `flutter analyze --fatal-infos`

#### 2. **Testing & Build (`test_and_build.yml`)**
- **Tujuan:** Automated testing dan build untuk semua platform.
- **Langkah-langkah:**
  - Checkout code
  - Setup Flutter
  - Install dependencies
  - Run `flutter test`
  - Build APK, iOS, Web, Windows, Linux, dan macOS

---

## 🔐 Keamanan

### Flutter Secure Storage
- **Fitur:**
  - Penyimpanan data terenkripsi.
  - Akses terbatas ke data sensitif.
  - Dukungan untuk berbagai platform.
- **Penggunaan:**
  ```dart
  final storage = SecureStorageService();
  await storage.writeSecureData('API_KEY', 'your_api_key_here');
  final apiKey = await storage.readSecureData('API_KEY');
  ```

### Enkripsi
- **Tujuan:** Melindungi environment variables dari akses yang tidak sah.
- **Implementasi:**
  - Penggunaan `flutter_secure_storage` untuk enkripsi data.
  - Model `EnvironmentVariable` dengan flag `encrypted`.

---

## 🌐 Multi-Platform

| Platform | Status | Catatan |
|----------|--------|---------|
| **Android** | ✅ | Siap untuk build APK |
| **iOS** | ✅ | Siap untuk build IPA |
| **Web** | ✅ | Siap untuk hosting web |
| **Windows** | ✅ | Siap untuk build executable |
| **Linux** | ✅ | Siap untuk build package |
| **macOS** | ✅ | Siap untuk build app |

---

## 📂 Struktur Proyek

```
vault-env-manager-flutter/
├── .github/workflows/          # CI/CD pipelines
│   ├── lint.yml
│   └── test_and_build.yml
├── lib/
│   ├── models/
│   │   ├── environment_variable.dart
│   │   └── api_config.dart
│   ├── services/
│   │   ├── secure_storage_service.dart
│   │   ├── api_service.dart
│   │   └── file_service.dart
│   ├── screens/
│   │   ├── home_screen.dart
│   │   ├── add_variable_screen.dart
│   │   ├── settings_screen.dart
│   │   └── api_integration_screen.dart
│   ├── utils/
│   │   ├── file_utils.dart
│   │   └── encryption_utils.dart
│   ├── l10n/
│   │   ├── app_en.arb
│   │   └── app_id.arb
│   └── main.dart
├── test/                       # Unit, widget, dan integration tests
├── analysis_options.yaml       # Aturan linting
├── pubspec.yaml                # Dependencies
├── README.md                   # Dokumentasi utama
├── AGENT.md                    # Dokumentasi internal
└── PROJECT_SKILL.md            # Dokumentasi skills dan tools
```

---

## 📖 Dokumentasi

| Dokumen | Tujuan |
|---------|--------|
| **README.md** | Panduan penggunaan dan kontribusi |
| **AGENT.md** | Dokumentasi internal dan state proyek |
| **PROJECT_SKILL.md** | Dokumentasi skills dan tools yang digunakan |
| **WIKI.md** | Dokumentasi tambahan dan FAQ |

---

## 🤝 Kontribusi

### Aturan Umum
- Gunakan `prefer_final` untuk variabel yang tidak diubah.
- Gunakan `const` untuk widget dan konstruktor yang statis.
- Dokumentasikan setiap fungsi dan class dengan komentar yang jelas.
- Ikuti aturan linting yang telah ditetapkan.
- Selalu lakukan `flutter analyze` sebelum commit.

### Langkah Kontribusi
1. Fork repository.
2. Buat branch baru: `git checkout -b feature/your-feature`.
3. Commit perubahan: `git commit -m 'feat: add your feature'`.
4. Push ke branch: `git push origin feature/your-feature`.
5. Buka Pull Request.

---

## 📧 Kontak

**Aldo Karendra**
- GitHub: [@aldok10](https://github.com/aldok10)
- Email: akarendra835@gmail.com

---

**Status:** Project siap untuk kontribusi dan pengembangan lebih lanjut!

**Terakhir diperbarui:** 19 April 2026