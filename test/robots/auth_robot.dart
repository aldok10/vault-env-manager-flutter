import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class AuthRobot {
  final WidgetTester tester;
  const AuthRobot(this.tester);

  Future<void> enterPassword(String password) async {
    final textFieldFinder = find.byType(TextField);
    expect(textFieldFinder, findsOneWidget);
    await tester.enterText(textFieldFinder, password);
  }

  Future<void> tapInitialize() async {
    final buttonFinder = find.text('INITIALIZE WORKBENCH');
    expect(buttonFinder, findsOneWidget);
    await tester.tap(buttonFinder);
    // Explicitly pump enough for the 800ms delay + snackbar animation
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.pumpAndSettle();
  }

  void expectErrorVisible() {
    // Search by text for the snackbar title
    final errorMessage = find.text('Security Error');
    expect(errorMessage, findsOneWidget);
  }

  void expectAppTitleVisible() {
    expect(find.text('SECURITY PROTOCOL'), findsOneWidget);
  }
}
