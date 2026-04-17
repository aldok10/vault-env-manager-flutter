import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/design_system/molecules/seraphine_dropdown.dart';
import 'package:vault_env_manager/src/core/design_system/seraphine_theme.dart';

void main() {
  testWidgets('SeraphineDropdown opens overlay and selects item', (WidgetTester tester) async {
    final value = 'A'.obs;
    final items = ['A', 'B', 'C'];
    String? selectedValue;

    await tester.pumpWidget(
      GetMaterialApp(
        theme: SeraphineTheme.dark,
        home: Scaffold(
          body: Center(
            child: SeraphineDropdown<String>(
              value: value,
              items: items,
              onChanged: (v) => selectedValue = v,
            ),
          ),
        ),
      ),
    );

    // Initial value
    expect(find.text('A'), findsOneWidget);

    // Tap to open
    await tester.tap(find.text('A'));
    await tester.pumpAndSettle();

    // Verify overlay presence (check for another text item)
    expect(find.text('B'), findsOneWidget);
    expect(find.text('C'), findsOneWidget);

    // Tap 'B'
    await tester.tap(find.text('B').last); // .last because 'A' might be in the button and menu
    await tester.pumpAndSettle();

    // Verify value changed
    expect(value.value, 'B');
    expect(selectedValue, 'B');
    
    // Verify overlay closed
    expect(find.text('C'), findsNothing);
  });
}
