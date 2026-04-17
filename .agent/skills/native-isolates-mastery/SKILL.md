---
name: Native Isolates Mastery
description: Implementation of industrial-grade Dart Isolates with zero-copy memory (TransferableTypedData) and background platform bridges.
---

# 🧵 Native Isolates Mastery

This skill defines the enterprise protocol for handling heavy computation (Cryptography, JSON Parsing, File IO) without blocking the UI thread.

## 🚀 1. Zero-Copy Performance (TransferableTypedData)
To achieve "Zero-Lag" with large payloads, use `TransferableTypedData` to move data between isolates instead of copying it.

### ✅ Implementation Pattern:
```dart
import 'dart:typed_data';
import 'dart:isolate';

Future<Uint8List> processData(Uint8List data) async {
  final transferable = TransferableTypedData.fromList([data]);
  return await Isolate.run(() {
    final list = transferable.materialize().asUint8List();
    // Perform heavy computation (e.g., encryption or large parsing)
    return list; 
  });
}
```

## 🌉 2. Platform Channel Bridge (BackgroundIsolateBinaryMessenger)
To access platform plugins (Secure Storage, Keychain, Path Provider) from a background isolate, you MUST use `BackgroundIsolateBinaryMessenger`.

### ✅ Bridge Setup:
```dart
import 'package:flutter/services.dart';

static Future<void> isolateEntryPoint(RootIsolateToken token) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(token);
  // Now you can call secure_storage or other plugins from here.
}
```

## 🧪 3. Verification Protocol
1. **Frame Pacing**: All isolate-offloaded tasks must result in **zero frame drops** (16.6ms for 60Hz, 8.3ms for 120Hz).
2. **Memory Analysis**: Use the DevTools Memory View to ensure no massive spikes in the main isolate heap during large data transfers.
3. **Isolate Safety**: Ensure all data passed to an isolate is either a primitive, a record, or `TransferableTypedData`.

---
*Protocol: Hardened. Threading: Zero-Lag. Status: Industrial.*
