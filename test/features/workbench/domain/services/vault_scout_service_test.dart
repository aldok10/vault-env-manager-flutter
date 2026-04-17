import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vault_env_manager/src/core/error/failures.dart';
import 'package:vault_env_manager/src/features/workbench/domain/models/scout_node.dart';
import 'package:vault_env_manager/src/features/workbench/domain/repositories/i_vault_repository.dart';
import 'package:vault_env_manager/src/features/workbench/domain/services/vault_scout_service.dart';

class MockVaultRepository extends Mock implements IVaultRepository {}

void main() {
  late VaultScoutService service;
  late MockVaultRepository mockRepository;

  setUp(() {
    mockRepository = MockVaultRepository();
    service = VaultScoutService(mockRepository);
  });

  group('VaultScoutService Unit Tests', () {
    test(
      'should perform recursive discovery and return list of nodes',
      () async {
        // Arrange
        // Root: folder/, secret1
        when(
          () => mockRepository.listKeys('root/'),
        ).thenAnswer((_) async => const Right(['folder/', 'secret1']));

        // Folder: secret2
        when(
          () => mockRepository.listKeys('root/folder/'),
        ).thenAnswer((_) async => const Right(['secret2']));

        // Metadata calls for discovery/versioning
        when(
          () => mockRepository.getMetadata('root/secret1'),
        ).thenAnswer((_) async => const Right({'current_version': 1}));
        when(
          () => mockRepository.getMetadata('root/folder/secret2'),
        ).thenAnswer((_) async => const Right({'current_version': 2}));

        final discoveredNodes = <ScoutNode>[];

        // Act
        final (result: result, nodesFound: _) = await service.scout(
          'root/',
          onNodeDiscovered: (node) => discoveredNodes.add(node),
        );

        // Assert
        expect(result.isRight(), true);
        result.fold((l) => fail('Should be Right'), (nodes) {
          expect(nodes.length, 3); // folder, secret1, secret2
          expect(nodes.any((n) => n.name == 'folder' && n.isFolder), true);
          expect(nodes.any((n) => n.name == 'secret1' && n.version == 1), true);
          expect(nodes.any((n) => n.name == 'secret2' && n.version == 2), true);
        });
        expect(discoveredNodes.length, 3);
      },
    );

    test('should skip folders that have no secrets deep down', () async {
      // Arrange
      // Root: empty_folder/
      when(
        () => mockRepository.listKeys('root/'),
      ).thenAnswer((_) async => const Right(['empty_folder/']));

      // empty_folder: empty
      when(
        () => mockRepository.listKeys('root/empty_folder/'),
      ).thenAnswer((_) async => const Right([]));

      // Act
      final (result: result, nodesFound: _) = await service.scout('root/');

      // Assert
      expect(result.isRight(), true);
      result.fold(
        (l) => fail('Should be Right'),
        (nodes) => expect(nodes.isEmpty, true),
      );
    });

    test('should enforce path security rules', () async {
      // Act
      final (result: result1, nodesFound: _) = await service.scout(
        '../../etc/passwd',
      );
      final (result: result2, nodesFound: _) = await service.scout(
        '/absolute/path',
      );

      // Assert
      expect(result1.isLeft(), true);
      expect(result2.isLeft(), true);

      result1.fold(
        (failure) => expect(failure, isA<VaultSecurityFailure>()),
        (r) => fail('Should be Left'),
      );
    });

    test('should handle repository failures gracefully and continue', () async {
      // Arrange
      when(
        () => mockRepository.listKeys('root/'),
      ).thenAnswer((_) async => const Right(['accessible/', 'forbidden/']));

      when(
        () => mockRepository.listKeys('root/accessible/'),
      ).thenAnswer((_) async => const Right(['secret']));

      when(
        () => mockRepository.getMetadata('root/accessible/secret'),
      ).thenAnswer((_) async => const Right({'current_version': 1}));

      when(
        () => mockRepository.listKeys('root/forbidden/'),
      ).thenAnswer((_) async => const Left(VaultAuthFailure()));

      // Act
      final (result: result, nodesFound: _) = await service.scout('root/');

      // Assert
      expect(result.isRight(), true);
      result.fold((f) => fail('Should be Right'), (nodes) {
        expect(nodes.length, 2); // accessible, secret
        expect(nodes.any((n) => n.name == 'accessible'), true);
      });
    });
    group('Consistency & Ordering', () {
      test(
        'should return nodes in alphabetical order for consistent UI',
        () async {
          // Arrange
          when(
            () => mockRepository.listKeys('root/'),
          ).thenAnswer((_) async => const Right(['c', 'a', 'b']));

          when(
            () => mockRepository.getMetadata(any()),
          ).thenAnswer((_) async => const Right({'current_version': 1}));

          // Act
          final (result: result, nodesFound: _) = await service.scout('root/');

          // Assert
          result.fold((l) => fail('Should be Right'), (nodes) {
            // Note: Our current implementation adds secrets first then folders,
            // but the keys are sorted before processing.
            // Let's check names.
            final names = nodes.map((n) => n.name).toList();
            // Since they are all secrets here, they should be in the order they were processed.
            // and processed in sorted order.
            expect(names, ['a', 'b', 'c']);
          });
        },
      );
    });
  });
}
