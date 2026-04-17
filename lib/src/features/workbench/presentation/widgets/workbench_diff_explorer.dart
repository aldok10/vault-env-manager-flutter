import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/design_system/seraphine_color_extension.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_colors.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_shapes.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_spacing.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_typography.dart';
import 'package:vault_env_manager/src/features/workbench/presentation/controllers/workbench_controller.dart';
import 'package:vault_env_manager/src/shared/utils/line_diff.dart';

class WorkbenchDiffExplorer extends GetView<WorkbenchController> {
  const WorkbenchDiffExplorer({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = SeraphineColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DiffHeader(),
        SeraphineSpacing.mdV,
        _DiffBody(),
      ],
    );
  }
}

// ── Header with stats badge ────────────────────────────────────────────
class _DiffHeader extends GetView<WorkbenchController> {
  @override
  Widget build(BuildContext context) {
    final colors = SeraphineColors.of(context);
    return Row(
      children: [
        Icon(Icons.compare, color: colors.primary, size: 20),
        const SizedBox(width: 12),
        Text(
          'DIFF EXPLORER',
          style: SeraphineTypography.label.copyWith(
            color: colors.textPrimary,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const Spacer(),
        Obx(() => _buildStatsBadge(context, colors)),
      ],
    );
  }

  Widget _buildStatsBadge(
    BuildContext context,
    SeraphineColorExtension colors,
  ) {
    final newText = controller.livePlaintext.value;
    final oldText = controller.vaultDecryptedBaseline.value;
    final isModified = newText != oldText;

    if (!isModified) {
      return _StatusChip(
        label: 'SYNCHRONIZED',
        color: colors.primary,
        bgColor: colors.primary.withValues(alpha: 0.1),
      );
    }

    final stats = const LineDiff().computeStats(oldText, newText);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (stats.additions > 0)
          _StatusChip(
            label: '+${stats.additions}',
            color: colors.success,
            bgColor: colors.success.withValues(alpha: 0.1),
          ),
        if (stats.additions > 0 && stats.deletions > 0)
          const SizedBox(width: 6),
        if (stats.deletions > 0)
          _StatusChip(
            label: '-${stats.deletions}',
            color: colors.error,
            bgColor: colors.error.withValues(alpha: 0.1),
          ),
        const SizedBox(width: 8),
        _StatusChip(
          label: 'UNSAVED',
          color: colors.warning,
          bgColor: colors.warning.withValues(alpha: 0.1),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;
  final Color bgColor;

  const _StatusChip({
    required this.label,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    final colors = SeraphineColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: ShapeDecoration(
        color: bgColor,
        shape: SeraphineShapes.squircle(
          radius: colors.cardRadius * 0.5,
          side: BorderSide(color: color.withValues(alpha: 0.2)),
        ),
      ),
      child: Text(
        label,
        style: SeraphineTypography.label.copyWith(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ── Diff Body ──────────────────────────────────────────────────────────
class _DiffBody extends GetView<WorkbenchController> {
  @override
  Widget build(BuildContext context) {
    final colors = SeraphineColors.of(context);
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
      decoration: ShapeDecoration(
        color: colors.surface.withValues(alpha: 0.5),
        shape: SeraphineShapes.squircle(
          radius: colors.cardRadius,
          side: BorderSide(color: colors.glassBorder),
        ),
      ),
      child: Obx(() {
        final newText = controller.livePlaintext.value;
        final oldText = controller.vaultDecryptedBaseline.value;

        if (newText == oldText) {
          return _buildSynchronizedState(colors);
        }

        return _GitDiffView(oldText: oldText, newText: newText);
      }),
    );
  }

  Widget _buildSynchronizedState(SeraphineColorExtension colors) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline,
              color: colors.success.withValues(alpha: 0.4),
              size: 48,
            ),
            SeraphineSpacing.mdV,
            Text(
              'Current session matches Vault version.',
              style: SeraphineTypography.bodySmall.copyWith(
                color: colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Git-style Unified Diff View ────────────────────────────────────────
class _GitDiffView extends StatelessWidget {
  final String oldText;
  final String newText;

  const _GitDiffView({required this.oldText, required this.newText});

  @override
  Widget build(BuildContext context) {
    final colors = SeraphineColors.of(context);
    final hunks = const LineDiff(contextLines: 3).computeHunks(
      oldText,
      newText,
    );

    if (hunks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          'No visible changes.',
          style: SeraphineTypography.bodySmall.copyWith(
            color: colors.textSecondary,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < hunks.length; i++) ...[
          if (i > 0) _HunkSeparator(),
          _HunkWidget(hunk: hunks[i]),
        ],
      ],
    );
  }
}

// ── Single Hunk ────────────────────────────────────────────────────────
class _HunkWidget extends StatelessWidget {
  final DiffHunk hunk;

  const _HunkWidget({required this.hunk});

  @override
  Widget build(BuildContext context) {
    final colors = SeraphineColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hunk header (@@ -1,5 +1,7 @@)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          color: colors.info.withValues(alpha: 0.08),
          child: Text(
            hunk.header,
            style: SeraphineTypography.code.copyWith(
              color: colors.info.withValues(alpha: 0.7),
              fontSize: 11,
            ),
          ),
        ),
        // Lines
        for (final line in hunk.lines) _DiffLineWidget(diffLine: line),
      ],
    );
  }
}

// ── Single Diff Line ───────────────────────────────────────────────────
class _DiffLineWidget extends StatelessWidget {
  final DiffLine diffLine;

  const _DiffLineWidget({required this.diffLine});

  @override
  Widget build(BuildContext context) {
    final colors = SeraphineColors.of(context);
    final op = diffLine.operation;

    final Color bgColor;
    final Color textColor;
    final Color gutterColor;
    final Color prefixColor;

    switch (op) {
      case DiffOperation.insert:
        bgColor = colors.success.withValues(alpha: 0.08);
        textColor = colors.success;
        gutterColor = colors.success.withValues(alpha: 0.15);
        prefixColor = colors.success;
      case DiffOperation.delete:
        bgColor = colors.error.withValues(alpha: 0.08);
        textColor = colors.error;
        gutterColor = colors.error.withValues(alpha: 0.15);
        prefixColor = colors.error;
      case DiffOperation.equal:
        bgColor = Colors.transparent;
        textColor = colors.textSecondary.withValues(alpha: 0.7);
        gutterColor = Colors.transparent;
        prefixColor = colors.textDetail.withValues(alpha: 0.3);
    }

    return Container(
      color: bgColor,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Old line number gutter
            _LineNumberGutter(
              number: diffLine.oldLineNumber,
              color: gutterColor,
              textColor: colors.textDetail.withValues(alpha: 0.5),
            ),
            // New line number gutter
            _LineNumberGutter(
              number: diffLine.newLineNumber,
              color: gutterColor,
              textColor: colors.textDetail.withValues(alpha: 0.5),
            ),
            // Prefix (+, -, space)
            Container(
              width: 20,
              color: gutterColor,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                diffLine.prefix,
                style: SeraphineTypography.code.copyWith(
                  color: prefixColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            // Line content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 2,
                ),
                child: Text(
                  diffLine.text,
                  style: SeraphineTypography.code.copyWith(
                    color: textColor,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Line Number Gutter ─────────────────────────────────────────────────
class _LineNumberGutter extends StatelessWidget {
  final int? number;
  final Color color;
  final Color textColor;

  const _LineNumberGutter({
    required this.number,
    required this.color,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      color: color,
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 8, top: 2, bottom: 2),
      child: Text(
        number?.toString() ?? '',
        style: SeraphineTypography.code.copyWith(
          color: textColor,
          fontSize: 11,
        ),
      ),
    );
  }
}

// ── Hunk Separator (collapsed context) ─────────────────────────────────
class _HunkSeparator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = SeraphineColors.of(context);
    return Container(
      width: double.infinity,
      height: 1,
      color: colors.divider,
    );
  }
}
