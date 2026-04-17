import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vault_env_manager/src/core/design_system/molecules/seraphine_input_field.dart';
import '../../../../robots/app_text_field_robot.dart';

void main() {
  group('SeraphineInputField Widget Tests', () {
    testWidgets('should display hint text when empty', (tester) async {
      // Arrange
      final robot = SeraphineInputFieldRobot(tester);
      const hint = 'Enter key';

      // Act
      await robot.pumpWidget(const SeraphineInputField(hint: hint));

      // Assert
      robot.expectHint(hint);
    });

    testWidgets('should allow entering text', (tester) async {
      // Arrange
      final robot = SeraphineInputFieldRobot(tester);
      const inputText = 'Hello-Master';

      await robot.pumpWidget(const SeraphineInputField(hint: 'Type here'));

      // Act
      await robot.enterSecretText(inputText);

      // Assert
      robot.expectTextEntered(inputText);
    });

    testWidgets('should show obscure text when enabled', (tester) async {
      // Arrange
      final robot = SeraphineInputFieldRobot(tester);
      const inputText = 'SensitiveData';

      await robot.pumpWidget(
        const SeraphineInputField(hint: 'Password', obscureText: true),
      );

      // Act
      await robot.enterSecretText(inputText);

      // Assert
      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.obscureText, true);
    });
  });
}
