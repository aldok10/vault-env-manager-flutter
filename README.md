# Vault Env Manager Flutter

[![Flutter](https://img.shields.io/badge/Flutter-3.19-blue.svg)](https://flutter.dev)
[![License](https://img.shields.io/badge/license-MIT-green.svg)](https://opensource.org/licenses/MIT)
[![CI/CD](https://github.com/aldok10/vault-env-manager-flutter/actions/workflows/test_and_build.yml/badge.svg)](https://github.com/aldok10/vault-env-manager-flutter/actions)
[![Lint](https://github.com/aldok10/vault-env-manager-flutter/actions/workflows/lint.yml/badge.svg)](https://github.com/aldok10/vault-env-manager-flutter/actions)

A secure Flutter application for managing environment variables with encryption and secure storage.

---

## 📌 Fitur Utama

- 🔒 **Penyimpanan Aman**: Environment variables disimpan terenkripsi menggunakan `flutter_secure_storage`.
- 📦 **Multi-Platform**: Dukungan untuk Android, iOS, Web, Windows, Linux, dan macOS.
- 🔄 **Import/Export**: Dukungan untuk format `.env`, JSON, dan YAML.
- 🛠 **Linting & Analisis**: Analisis statis dan linting yang ketat untuk kualitas code.
- 🚀 **CI/CD Otomatis**: Automated testing dan build untuk semua platform.
- 🌐 **Multi-Bahasa**: Dukungan untuk bahasa Inggris dan Indonesia.
- 📖 **Dokumentasi Lengkap**: Panduan penggunaan dan kontribusi yang mudah dipahami.

---

## 📋 Screenshots

![Home Screen](https://via.placeholder.com/400x200?text=Home+Screen+Placeholder)
![Add Variable](https://via.placeholder.com/400x200?text=Add+Variable+Placeholder)

---

## 📂 Struktur Proyek

```
lib/
├── models/
│   └── environment_variable.dart    # Model untuk environment variables
├── services/
│   ├── secure_storage_service.dart # Service untuk penyimpanan terenkripsi
│   └── api_service.dart             # Service untuk integrasi API eksternal
├── screens/
│   ├── home_screen.dart             # Halaman utama
│   ├── add_variable_screen.dart     # Halaman untuk menambah variabel
│   └── settings_screen.dart         # Halaman pengaturan
├── utils/
│   ├── file_utils.dart              # Utility untuk import/export file
│   └── encryption_utils.dart        # Utility untuk enkripsi/dekripsi
└── main.dart                        # Entry point aplikasi
```

---

## 🚀 Instalasi

1. **Clone Repository**
   ```bash
   git clone https://github.com/aldok10/vault-env-manager-flutter.git
   cd vault-env-manager-flutter
   ```

2. **Install Dependencies**
   ```bash
   flutter pub get
   ```

3. **Run Aplikasi**
   ```bash
   flutter run
   ```

---

## 🎯 Penggunaan

### Menambah Environment Variable

```dart
final envVar = EnvironmentVariable(
  key: 'API_KEY',
  value: 'your_api_key_here',
  description: 'API Key for external service',
  encrypted: true,
);

// Simpan ke penyimpanan terenkripsi
await SecureStorageService().writeSecureData(envVar.key, envVar.value);
```

### Membaca Environment Variable

```dart
final apiKey = await SecureStorageService().readSecureData('API_KEY');
print('API Key: $apiKey');
```

### Import/Export

```dart
// Import dari file .env
final envVars = await FileUtils.importFromEnvFile('path/to/.env');

// Export ke file JSON
await FileUtils.exportToJsonFile('path/to/output.json', envVars);
```

---

## 🤝 Kontribusi

1. Fork repository ini.
2. Buat branch baru: `git checkout -b feature/your-feature`.
3. Commit perubahan Anda: `git commit -m 'feat: add your feature'`.
4. Push ke branch: `git push origin feature/your-feature`.
5. Buka Pull Request.

---

## 📜 Lisensi

Distributed under the MIT License. See `LICENSE` for more information.

---

## 📧 Kontak

Aldo Karendra - [@aldok10](https://github.com/aldok10)

Project Link: [https://github.com/aldok10/vault-env-manager-flutter](https://github.com/aldok10/vault-env-manager-flutter)

---

## 📝 Roadmap

- Integrasi dengan HashiCorp Vault
- Dukungan untuk lebih banyak bahasa
- Fitur auto-lock setelah periode tidak aktif
- Peningkatan UI/UX dengan animasi dan tema gelap