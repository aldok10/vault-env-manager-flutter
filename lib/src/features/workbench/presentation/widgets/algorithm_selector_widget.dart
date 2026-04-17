import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/design_system/molecules/seraphine_dropdown.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_spacing.dart';

/// ⚛️ SeraphineAlgorithmSelector
/// Adaptive 2026 selector for encryption algorithms and syntax.
class AlgorithmSelectorWidget extends StatelessWidget {
  final RxString selectedAlgorithm;
  final List<String> algorithms;
  final RxString selectedSyntax;
  final List<String> syntaxes;
  final bool showSyntax;
  final bool isDense;

  const AlgorithmSelectorWidget({
    super.key,
    required this.selectedAlgorithm,
    required this.algorithms,
    required this.selectedSyntax,
    required this.syntaxes,
    this.showSyntax = true,
    this.isDense = false,
  });

  @override
  Widget build(BuildContext context) {
    // We use a simple layout logic that fits into the staggered bento grid.
    // The parent grid handles the overall responsiveness.
    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 400;

        if (isNarrow) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildAlgorithmSelector(),
              if (showSyntax) ...[SeraphineSpacing.smV, _buildSyntaxSelector()],
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(child: _buildAlgorithmSelector()),
            if (showSyntax) ...[
              SeraphineSpacing.mdH,
              Expanded(child: _buildSyntaxSelector()),
            ],
          ],
        );
      },
    );
  }

  Widget _buildAlgorithmSelector() {
    return SeraphineDropdown<String>(
      value: selectedAlgorithm,
      items: algorithms,
      isUppercase: true,
      isDense: isDense,
    );
  }

  Widget _buildSyntaxSelector() {
    return SeraphineDropdown<String>(
      value: selectedSyntax,
      items: syntaxes,
      isUppercase: true,
      isDense: isDense,
    );
  }
}
