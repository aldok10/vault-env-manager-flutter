import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vault_env_manager/src/core/app/data/services/storage_service.dart';

/// Intercepts every call on the `plugins.it_nomads.com/flutter_secure_storage`
/// method channel and routes it through an in-memory map so
/// `StorageService` can be driven end-to-end without a keychain.
class _SecureStorageChannelFake {
  _SecureStorageChannelFake({this.throwOnAny = false});

  static const MethodChannel _channel = MethodChannel(
    'plugins.it_nomads.com/flutter_secure_storage',
  );

  final Map<String, String> store = {};

  /// When true every method call throws a `PlatformException` — the
  /// exact failure shape that `StorageService.init` must refuse to
  /// silently downgrade around.
  final bool throwOnAny;

  void install() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, _handler);
  }

  void uninstall() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
  }

  Future<Object?> _handler(MethodCall call) async {
    if (throwOnAny) {
      throw PlatformException(code: 'Unavailable', message: 'keychain locked');
    }
    final args = (call.arguments as Map?)?.cast<String, Object?>() ?? const {};
    switch (call.method) {
      case 'write':
        store[args['key'] as String] = args['value'] as String;
        return null;
      case 'read':
        return store[args['key'] as String];
      case 'readAll':
        return Map<String, String>.from(store);
      case 'delete':
        store.remove(args['key'] as String);
        return null;
      case 'deleteAll':
        store.clear();
        return null;
      case 'containsKey':
        return store.containsKey(args['key'] as String);
      default:
        return null;
    }
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('StorageService — happy path (secure + prefs both available)', () {
    late _SecureStorageChannelFake fake;
    late SharedPreferences prefs;
    late StorageService svc;

    setUp(() async {
      fake = _SecureStorageChannelFake();
      fake.install();
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      svc = StorageService(sharedPreferences: prefs);
      await svc.init();
    });

    tearDown(() => fake.uninstall());

    test('saveSecure / get round-trips through the secure backend', () async {
      await svc.saveSecure('master_hash', 'pbkdf2\$100000\$salt\$dk');
      expect(await svc.get('master_hash'), 'pbkdf2\$100000\$salt\$dk');
      // And it really did reach the secure channel, not prefs:
      expect(fake.store['master_hash'], 'pbkdf2\$100000\$salt\$dk');
      expect(prefs.getString('master_hash'), isNull);
    });

    test(
      'saveNormal / get(isSecure: false) round-trips via SharedPreferences',
      () async {
        await svc.saveNormal('theme', 'dark');
        expect(await svc.get('theme', isSecure: false), 'dark');
        // Lives in prefs, NOT in the secure store:
        expect(prefs.getString('theme'), 'dark');
        expect(fake.store['theme'], isNull);
      },
    );

    test('delete(secure) removes only from the secure store', () async {
      await svc.saveSecure('k', 'v');
      await svc.saveNormal('k', 'plain');
      await svc.delete('k'); // isSecure defaults to true
      expect(await svc.get('k'), isNull);
      expect(await svc.get('k', isSecure: false), 'plain');
    });

    test('delete(normal) removes only from SharedPreferences', () async {
      await svc.saveSecure('k', 'v');
      await svc.saveNormal('k', 'plain');
      await svc.delete('k', isSecure: false);
      expect(await svc.get('k'), 'v');
      expect(await svc.get('k', isSecure: false), isNull);
    });

    test('clear wipes both backends', () async {
      await svc.saveSecure('a', '1');
      await svc.saveNormal('b', '2');
      await svc.clear();
      expect(await svc.get('a'), isNull);
      expect(await svc.get('b', isSecure: false), isNull);
      expect(fake.store, isEmpty);
    });

    test('idempotent init is a no-op on the second call', () async {
      await svc.saveSecure('once', '1');
      await svc.init();
      expect(await svc.get('once'), '1');
    });
  });

  group('StorageService — fail-loud when secure backend is unavailable', () {
    late _SecureStorageChannelFake fake;

    setUp(() {
      fake = _SecureStorageChannelFake(throwOnAny: true);
      fake.install();
      SharedPreferences.setMockInitialValues({});
    });

    tearDown(() => fake.uninstall());

    test(
      'PlatformException during probe surfaces as '
      'SecureStorageUnavailableException, NOT silent in-memory fallback',
      () async {
        final prefs = await SharedPreferences.getInstance();
        final svc = StorageService(sharedPreferences: prefs);

        await expectLater(
          svc.init(),
          throwsA(
            isA<SecureStorageUnavailableException>().having(
              (e) => e.message,
              'message',
              allOf(
                contains('Secure storage'),
                contains('Refusing to fall back'),
              ),
            ),
          ),
        );
      },
    );

    test('exception is raised BEFORE the service is marked initialised, '
        'so subsequent operations also refuse to run', () async {
      final prefs = await SharedPreferences.getInstance();
      final svc = StorageService(sharedPreferences: prefs);

      try {
        await svc.init();
        fail('init() should have thrown.');
      } on SecureStorageUnavailableException {
        // expected
      }

      // Every getter / setter must now refuse to run because init()
      // was never successfully completed.
      expect(() => svc.saveSecure('k', 'v'), throwsA(isA<StateError>()));
      expect(() => svc.get('k'), throwsA(isA<StateError>()));
      expect(() => svc.saveNormal('k', 'v'), throwsA(isA<StateError>()));
    });

    test('the underlying PlatformException is preserved as the `cause` '
        'field so diagnostics survive the rethrow', () async {
      final prefs = await SharedPreferences.getInstance();
      final svc = StorageService(sharedPreferences: prefs);

      try {
        await svc.init();
        fail('init() should have thrown.');
      } on SecureStorageUnavailableException catch (e) {
        expect(e.cause, isA<PlatformException>());
        expect((e.cause as PlatformException).code, 'Unavailable');
      }
    });
  });

  group('StorageService — accessing storage before init throws', () {
    test('saveSecure before init throws StateError', () async {
      final svc = StorageService();
      expect(() => svc.saveSecure('k', 'v'), throwsA(isA<StateError>()));
    });

    test('get before init throws StateError', () async {
      final svc = StorageService();
      expect(() => svc.get('k'), throwsA(isA<StateError>()));
    });
  });
}
