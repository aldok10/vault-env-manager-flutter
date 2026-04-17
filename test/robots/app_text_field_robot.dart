import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'base_robot.dart';

class SeraphineInputFieldRobot extends BaseRobot {
  SeraphineInputFieldRobot(super.tester);

  Finder get textFieldFinder => find.byType(TextField);
  Finder get containerFinder => find.byType(AnimatedContainer);

  void expectHint(String hint) {
    expect(find.text(hint), findsOneWidget);
  }

  Future<void> enterSecretText(String text) async {
    await enterText(textFieldFinder, text);
  }

  void expectTextEntered(String text) {
    expect(find.text(text), findsOneWidget);
  }
}
