import 'package:flutter/cupertino.dart';
import 'package:vault_env_manager/src/core/design_system/molecules/seraphine_workbench_widget.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_spacing.dart';
import 'package:vault_env_manager/src/features/settings/presentation/widgets/os_style_selector_widget.dart';
import 'package:vault_env_manager/src/features/settings/presentation/widgets/theme_selector_widget.dart';
import 'package:vault_env_manager/src/features/settings/presentation/widgets/ui_scale_selector_widget.dart';

/// 🎨 SettingsVisualConfig
/// Reimagined for SeraphineUI.
class SettingsVisualConfig extends StatelessWidget {
  const SettingsVisualConfig({super.key});

  @override
  Widget build(BuildContext context) {
    return const SeraphineWorkbenchWidget(
      title: 'Visual Core',
      icon: CupertinoIcons.paintbrush_fill,
      isCollapsible: true,
      initialCollapsed: false,
      child: Padding(
        padding: EdgeInsets.all(SeraphineSpacing.md),
        child: Column(
          children: [
            ThemeSelectorWidget(),
            SeraphineSpacing.xlV,
            OsStyleSelectorWidget(),
            SeraphineSpacing.xlV,
            UiScaleSelectorWidget(),
          ],
        ),
      ),
    );
  }
}
