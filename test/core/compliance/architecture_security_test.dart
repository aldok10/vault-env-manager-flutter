import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Architectural Compliance & Security Guards', () {
    test(
      'Repositories MUST NOT perform blocking JSON parsing (ComputeService requirement)',
      () {
        final repositoryDir = Directory(
          'lib/src/features/workbench/data/repositories',
        );
        if (!repositoryDir.existsSync()) return;

        final files = repositoryDir.listSync(recursive: true);
        for (final file in files) {
          if (file is File && file.path.endsWith('_impl.dart')) {
            final content = file.readAsStringSync();

            // If the file uses JSON decoding from network/storage, it should use ComputeService
            if (content.contains('json.decode') ||
                content.contains('jsonDecode')) {
              expect(
                content.contains('ComputeService.to.parseJson'),
                isTrue,
                reason:
                    'Blocking JSON parsing detected in ${file.path}. Use ComputeService.to.parseJson instead.',
              );
            }
          }
        }
      },
    );

    test('SecureHttpClient MUST be used for network layer in controllers', () {
      final controllerDir = Directory('lib/src/features');
      if (!controllerDir.existsSync()) return;

      final files = controllerDir.listSync(recursive: true);
      for (final file in files) {
        if (file is File &&
            file.path.contains('controller.dart') &&
            !file.path.contains('initial_loader_controller.dart')) {
          final content = file.readAsStringSync();

          // Controllers should not instantiate http.Client directly
          expect(
            content.contains('http.Client()'),
            isFalse,
            reason:
                'Manual http.Client instantiation detected in ${file.path}. Use dependency injection.',
          );
        }
      }
    });

    test('Models MUST implement JsonValidatorMixin for anti-hallucination', () {
      final modelDir = Directory('lib/src/app/data/models');
      if (!modelDir.existsSync()) return;

      final files = modelDir.listSync(recursive: true);
      for (final file in files) {
        if (file is File && file.path.endsWith('.dart')) {
          final content = file.readAsStringSync();
          if (content.contains('class') && content.contains('fromMap')) {
            expect(
              content.contains('JsonValidatorMixin'),
              isTrue,
              reason:
                  'Data model ${file.path} missing JsonValidatorMixin for contract enforcement.',
            );
          }
        }
      }
    });
  });
}
