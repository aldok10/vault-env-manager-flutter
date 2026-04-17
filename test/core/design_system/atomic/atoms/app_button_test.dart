import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/design_system/molecules/seraphine_button.dart';

import '../../../../robots/app_button_robot.dart';
import '../../../../test_mocks.dart';

void main() {
  setUpAll(() async {
    await setupTestConfig();
  });

  tearDown(() async {
    Get.reset();
    await setupTestConfig();
  });

  group('SeraphineButton Widget Tests', () {
    testWidgets('should display label', (tester) async {
      // Arrange
      final robot = SeraphineButtonRobot(tester);
      const label = 'Click Me';

      // Act
      await robot.pumpWidget(const SeraphineButton(text: label));

      // Assert
      robot.expectLabel(label);
    });

    testWidgets('should show loading indicator when isLoading is true', (
      tester,
    ) async {
      // Arrange
      final robot = SeraphineButtonRobot(tester);

      // Act
      await robot.pumpWidget(
        const SeraphineButton(text: 'Loading', isLoading: true),
      );

      // Assert
      robot.expectLoading(true);
    });

    testWidgets('should trigger onPressed when tapped', (tester) async {
      // Arrange
      final robot = SeraphineButtonRobot(tester);
      bool pressed = false;

      await robot.pumpWidget(
        SeraphineButton(text: 'Tap Me', onPressed: () => pressed = true),
      );

      // Act
      await robot.tapButton();

      // Assert
      expect(pressed, true);
    });

    testWidgets('should not trigger onPressed when isLoading is true', (
      tester,
    ) async {
      // Arrange
      final robot = SeraphineButtonRobot(tester);
      bool pressed = false;

      await robot.pumpWidget(
        SeraphineButton(
          text: 'Wait',
          isLoading: true,
          onPressed: () => pressed = true,
        ),
      );

      // Act
      await robot.tapButton();

      // Assert
      expect(pressed, false);
    });
  });
}
