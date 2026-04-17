import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:vault_env_manager/src/core/error/exceptions.dart';
import 'package:vault_env_manager/src/core/services/network_security_interceptor.dart';
import 'package:vault_env_manager/src/core/services/security_service.dart';

void main() {
  late SecurityService securityService;

  setUp(() async {
    Get.testMode = true;
    securityService = SecurityService();
    Get.put(securityService);
    await securityService.init();

    // Note: client is defined but not used here as it's often redefined in tests
  });

  tearDown(() {
    Get.reset();
  });

  group('SecureHttpClient Tests', () {
    test('POST request encrypts payload using AES-GCM', () async {
      final data = {'secret': 'password123'};

      var capturedBody = '';
      final mockInnerClient = MockClient((request) async {
        capturedBody = request.body;
        return http.Response(json.encode({'status': 'ok'}), 200);
      });

      final secureClient = SecureHttpClient(
        mockInnerClient,
        securityService.payloadKey,
      );

      await secureClient.post(
        Uri.parse('https://vault.local/data'),
        body: json.encode(data),
        headers: {'Content-Type': 'application/json'},
      );

      expect(capturedBody, isNot(contains('password123')));
      expect(capturedBody, contains('"n":')); // Nonce
      expect(capturedBody, contains('"c":')); // Ciphertext
      expect(capturedBody, contains('"m":')); // MAC
      expect(capturedBody, contains('"s":')); // HMAC Signature (Phase 2)
    });

    test('Payload can be decrypted by SecurityService', () async {
      final data = {'key': 'value'};
      final jsonStr = json.encode(data);

      // Encrypt
      final encrypted = await securityService.encrypt(jsonStr);

      // Decrypt
      final decrypted = await securityService.decrypt(encrypted);

      expect(decrypted, equals(jsonStr));
      expect(json.decode(decrypted)['key'], equals('value'));
    });

    test('Payload with tampered signature throws SecurityException', () async {
      final jsonStr = json.encode({'key': 'value'});
      final encrypted = await securityService.encrypt(jsonStr);

      final Map<String, dynamic> data = json.decode(encrypted);
      // Tamper with the ciphertext or nonce
      data['c'] = base64Encode(utf8.encode('tampered'));

      final tamperedPayload = json.encode(data);

      expect(
        () => securityService.decrypt(tamperedPayload),
        throwsA(isA<SecurityException>()),
      );
    });
  });
}
