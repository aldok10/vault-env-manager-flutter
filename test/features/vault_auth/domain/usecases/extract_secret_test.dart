import 'package:flutter_test/flutter_test.dart';
import 'package:vault_env_manager/src/features/vault_auth/domain/usecases/extract_secret.dart';

void main() {
  group('ExtractSecret.extract', () {
    test('should extract single value from one-key map', () {
      final data = {'secret': 'my_password'};
      expect(ExtractSecret.extract(data), 'my_password');
    });

    test('should extract single value from one-key JSON string', () {
      const data = '{"apiKey": "12345"}';
      expect(ExtractSecret.extract(data), '12345');
    });

    test('should return stringified map if more than one key', () {
      final data = {'user': 'admin', 'pass': '123'};
      final result = ExtractSecret.extract(data);
      expect(result, contains('"user":"admin"'));
      expect(result, contains('"pass":"123"'));
    });

    test('should return non-JSON string as is', () {
      const data = 'plain text';
      expect(ExtractSecret.extract(data), 'plain text');
    });

    test('should return empty string for null', () {
      expect(ExtractSecret.extract(null), '');
    });
  });
}
