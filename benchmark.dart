import 'package:dartz/dartz.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vault_env_manager/src/core/error/failures.dart';
import 'package:vault_env_manager/src/features/workbench/domain/services/vault_scout_service.dart';
import 'package:vault_env_manager/src/features/workbench/domain/repositories/i_vault_repository.dart';

class MockVaultRepository extends Mock implements IVaultRepository {}

void main() async {
  final mockRepository = MockVaultRepository();
  final service = VaultScoutService(mockRepository);

  final keys = List.generate(1000, (i) => 'secret_$i');

  when(() => mockRepository.listKeys('root/'))
      .thenAnswer((_) async => Right(keys));

  when(() => mockRepository.getMetadata(any()))
      .thenAnswer((_) async {
    await Future.delayed(const Duration(milliseconds: 1)); // Simulate network latency
    return const Right({'current_version': 1});
  });

  final stopwatch = Stopwatch()..start();
  await service.scout('root/');
  stopwatch.stop();

  print('Benchmark completed in ${stopwatch.elapsedMilliseconds} ms');
}
