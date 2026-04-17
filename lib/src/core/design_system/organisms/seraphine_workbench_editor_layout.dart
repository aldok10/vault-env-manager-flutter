import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/design_system/molecules/seraphine_draggable_divider.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_colors.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_spacing.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_typography.dart';
import 'package:vault_env_manager/src/features/workbench/domain/models/system_log.dart';
import 'package:vault_env_manager/src/features/workbench/presentation/widgets/seraphine_editor_pane.dart';

/// 🏢 SeraphineWorkbenchEditorLayout Organism
/// A high-fidelity, responsive editor layout for 2026.
class SeraphineWorkbenchEditorLayout extends StatefulWidget {
  final TextEditingController plaintextController;
  final RxString plaintextStats;
  final VoidCallback onClearPlaintext;
  final VoidCallback onPasteToPlaintext;

  final TextEditingController ciphertextController;
  final RxString ciphertextStats;
  final VoidCallback onClearCiphertext;
  final VoidCallback onPasteToCiphertext;

  final RxBool isFlipped;
  final VoidCallback onSwap;
  final RxDouble splitRatio;
  final ValueChanged<double> onSplitRatioChanged;
  final void Function(String, {LogLevel? level}) appendLog;

  const SeraphineWorkbenchEditorLayout({
    super.key,
    required this.plaintextController,
    required this.plaintextStats,
    required this.onClearPlaintext,
    required this.onPasteToPlaintext,
    required this.ciphertextController,
    required this.ciphertextStats,
    required this.onClearCiphertext,
    required this.onPasteToCiphertext,
    required this.isFlipped,
    required this.onSwap,
    required this.splitRatio,
    required this.onSplitRatioChanged,
    required this.appendLog,
  });

  @override
  State<SeraphineWorkbenchEditorLayout> createState() =>
      _SeraphineWorkbenchEditorLayoutState();
}

class _SeraphineWorkbenchEditorLayoutState
    extends State<SeraphineWorkbenchEditorLayout> {
  int _activeMobileTab = 0; // 0: Plaintext, 1: Ciphertext

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 800; // Breakpoint for workbench

        return isMobile ? _buildMobile() : _buildDesktop(constraints.maxWidth);
      },
    );
  }

  Widget _buildMobile() {
    return Column(
      children: [
        _buildMobileTabs(),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            switchInCurve: Curves.easeOutQuart,
            switchOutCurve: Curves.easeInQuart,
            child: Padding(
              key: ValueKey<int>(_activeMobileTab),
              padding: const EdgeInsets.fromLTRB(
                SeraphineSpacing.md,
                0,
                SeraphineSpacing.md,
                100,
              ),
              child: _activeMobileTab == 0
                  ? _plaintextPane()
                  : _ciphertextPane(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktop(double totalWidth) {
    return Padding(
      padding: SeraphineSpacing.pHLG.copyWith(top: SeraphineSpacing.md),
      child: Obx(() {
        const double minPaneWidth = 350.0;
        final double gutter = SeraphineSpacing.md;
        final usableWidth = totalWidth - gutter - (SeraphineSpacing.lg * 2);

        final minRatio = minPaneWidth / usableWidth;
        final maxRatio = (usableWidth - minPaneWidth) / usableWidth;
        final ratio = widget.splitRatio.value.clamp(minRatio, maxRatio);

        final leftWidth = usableWidth * ratio;
        final rightWidth = usableWidth * (1.0 - ratio);

        final divider = SeraphineDraggableDivider(
          gutter: gutter,
          totalWidth: totalWidth,
          onDeltaUpdate: (delta) {
            // Convert pixel delta to ratio delta
            final ratioDelta = delta / usableWidth;
            widget.onSplitRatioChanged(widget.splitRatio.value + ratioDelta);
          },
        );

        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: widget.isFlipped.value
              ? [
                  SizedBox(width: leftWidth, child: _ciphertextPane()),
                  divider,
                  SizedBox(width: rightWidth, child: _plaintextPane()),
                ]
              : [
                  SizedBox(width: leftWidth, child: _plaintextPane()),
                  divider,
                  SizedBox(width: rightWidth, child: _ciphertextPane()),
                ],
        );
      }),
    );
  }

  Widget _plaintextPane({double? height}) => SeraphineEditorPane(
    label: 'PLAINTEXT',
    dotColor: SeraphineColors.accentPrimary,
    stats: widget.plaintextStats,
    controller: widget.plaintextController,
    hint: 'Input code or secret payload...',
    onClear: widget.onClearPlaintext,
    onPaste: widget.onPasteToPlaintext,
    onSwap: widget.onSwap,
    appendLog: widget.appendLog,
    height: height,
  );

  Widget _ciphertextPane({double? height}) => SeraphineEditorPane(
    label: 'CIPHERTEXT',
    dotColor: SeraphineColors.accentSecondary,
    stats: widget.ciphertextStats,
    controller: widget.ciphertextController,
    hint: 'Encrypted result will appear here...',
    onClear: widget.onClearCiphertext,
    onPaste: widget.onPasteToCiphertext,
    onSwap: widget.onSwap,
    appendLog: widget.appendLog,
    height: height,
  );

  Widget _buildMobileTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: SeraphineSpacing.md,
        vertical: 16,
      ),
      child: SizedBox(
        width: double.infinity,
        child: CupertinoSlidingSegmentedControl<int>(
          groupValue: _activeMobileTab,
          backgroundColor: SeraphineColors.of(
            context,
          ).surface.withValues(alpha: 0.1),
          thumbColor: SeraphineColors.accentPrimary.withValues(alpha: 0.2),
          children: {
            0: _tabLabel('SOURCE', CupertinoIcons.text_alignleft),
            1: _tabLabel('RESULT', CupertinoIcons.lock_shield),
          },
          onValueChanged: (val) {
            if (val != null) setState(() => _activeMobileTab = val);
          },
        ),
      ),
    );
  }

  Widget _tabLabel(String label, IconData icon) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 14, color: SeraphineColors.of(context).textPrimary),
        SeraphineSpacing.smH,
        Text(
          label,
          style: SeraphineTypography.label.copyWith(
            fontSize: 10,
            color: SeraphineColors.of(context).textPrimary,
          ),
        ),
      ],
    ),
  );
}
