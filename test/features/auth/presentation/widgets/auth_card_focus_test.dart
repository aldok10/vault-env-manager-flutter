import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:vault_env_manager/src/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:vault_env_manager/src/features/auth/presentation/controllers/auth_controller.dart';
import 'package:vault_env_manager/src/features/auth/presentation/widgets/_auth_card.dart';

class MockIAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockIAuthRepository mockRepo;
  late AuthController controller;

  setUp(() {
    mockRepo = MockIAuthRepository();

    // Stubbing isSetup to return false for initialization screen
    when(() => mockRepo.isSetup()).thenReturn(false);

    controller = AuthController(mockRepo);
    Get.put<AuthController>(controller);
  });

  tearDown(() {
    Get.delete<AuthController>();
  });

  testWidgets('AuthCard field should have autofocus and stable FocusNode', (
    tester,
  ) async {
    // We need to provide a simple Material app wrapper
    await tester.pumpWidget(
      const GetMaterialApp(home: Scaffold(body: AuthCard())),
    );

    // Initial pump to settle animations
    await tester.pump();
    await tester.pump(
      const Duration(milliseconds: 1000),
    ); // Account for scale/fade animation

    // 1. Verify TextField is present
    final textFieldFinder = find.byType(TextField);
    expect(textFieldFinder, findsOneWidget);

    // 2. Verify autofocus works (the focus node in controller should have focus)
    // On web/desktop, autofocus might need a pump
    await tester.pump();
    expect(
      controller.focusNode.hasFocus,
      isTrue,
      reason: 'TextField should be autofocused',
    );

    // 3. Verify inputting text works
    await tester.enterText(textFieldFinder, 'secret-key');
    expect(controller.passwordController.text, 'secret-key');

    // 4. Verify focus is maintained after a rebuild (triggering Obx by changing isError)
    controller.isError.value = true;
    await tester.pump();

    expect(
      controller.focusNode.hasFocus,
      isTrue,
      reason: 'Should maintain focus after Obx rebuild',
    );

    // 5. Verify field is disabled when loading
    controller.isLoading.value = true;
    await tester.pump();

    final TextField textField = tester.widget(textFieldFinder);
    expect(
      textField.enabled,
      isFalse,
      reason: 'TextField should be disabled when loading',
    );
  });
}
