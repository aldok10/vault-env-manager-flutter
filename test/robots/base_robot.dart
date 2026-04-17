import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/app/data/services/app_config_service.dart';
import '../test_mocks.dart';

abstract class BaseRobot {
  final WidgetTester tester;

  BaseRobot(this.tester);

  void expectVisible(Finder finder) {
    expect(finder, findsOneWidget);
  }

  void expectNotVisible(Finder finder) {
    expect(finder, findsNothing);
  }

  void expectText(String text) {
    expect(find.text(text), findsOneWidget);
  }

  Future<void> tap(Finder finder) async {
    await tester.tap(finder, warnIfMissed: false);
    await settle();
  }

  Future<void> enterText(Finder finder, String text) async {
    await tester.enterText(finder, text);
    await settle();
  }

  Future<void> pumpWidget(Widget widget) async {
    // Ensure core services are available for design system tokens (Colors -> AppConfigService)
    if (!Get.isRegistered<AppConfigService>()) {
      await setupTestConfig();
    }

    await tester.pumpWidget(GetMaterialApp(home: Scaffold(body: widget)));
    await settle();
  }

  /// Settles the UI, but avoids timing out on infinite animations.
  Future<void> settle() async {
    try {
      // We set a very short timeout (100ms * 5) to detect infinite animations quickly.
      await tester.pumpAndSettle(
        const Duration(milliseconds: 100),
        EnginePhase.sendSemanticsUpdate,
        const Duration(milliseconds: 500),
      );
    } catch (_) {
      // If it times out (likely due to CircularProgressIndicator), we just pump once
      // to ensure the widget is rendered and stable enough for interaction.
      await tester.pump();
    }
  }
}
