---
name: Vault Resilience Engineering
description: Implementation of industrial-grade data safety, atomic persistence, and recovery for the Vault Env Manager project.
---

# 🛡️ Vault Resilience Engineering

This skill defines the mandatory data safety standards to prevent corruption during system crashes or power failures.

## 📁 1. Atomic Persistence (Write-and-Rename)
**NEVER** overwrite the primary vault file directly. This is a critical failure of resilience.

### ✅ Atomic Pattern:
```dart
import 'dart:io';

Future<void> saveVaultAtomic(File target, List<int> data) async {
  final tempFile = File('${target.path}.tmp');
  await tempFile.writeAsBytes(data, flush: true);
  await tempFile.rename(target.path); // Atomic rename on Unix/macOS
}
```

## 🔐 2. Integrity Verification (Checksums)
All vault payloads MUST include a HMAC-SHA256 signature to detect accidental corruption or malicious tampering at the hardware level.

### ✅ Verification Flow:
1. **Read**: Load `VaultPayload`.
2. **Compute**: Calculate `check_sum` of the ciphertext.
3. **Compare**: If `payload.sum != current_sum`, **HALT** and notify the user of potential corruption.

## 💾 3. Multi-Version Recovery (Backup)
Before any structural migration or major update, the `VaultRepository` MUST create a `.bak` copy of the existing vault.

---
*Protocol: Hardened. Reliability: Backend-Grade. Status: Industrial.*
