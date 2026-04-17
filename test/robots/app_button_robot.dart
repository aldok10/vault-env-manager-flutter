import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vault_env_manager/src/core/design_system/molecules/seraphine_button.dart';
import 'base_robot.dart';

class SeraphineButtonRobot extends BaseRobot {
  SeraphineButtonRobot(super.tester);

  Finder get buttonFinder => find.byType(SeraphineButton);
  Finder get elevatedButtonFinder => find.byType(ElevatedButton);
  Finder get labelFinder => find.byType(Text);
  Finder get loadingFinder => find.byType(CircularProgressIndicator);

  void expectLabel(String label) {
    expect(find.text(label), findsOneWidget);
  }

  void expectLoading(bool isLoading) {
    if (isLoading) {
      expectVisible(loadingFinder);
    } else {
      expectNotVisible(loadingFinder);
    }
  }

  Future<void> tapButton() async {
    // Ensuring we hit the internal button directly
    await tester.tap(
      find.descendant(of: buttonFinder, matching: find.byType(GestureDetector)),
    );
    await settle();
  }
}
