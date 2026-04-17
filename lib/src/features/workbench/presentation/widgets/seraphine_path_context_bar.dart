import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_colors.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_shapes.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_spacing.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_typography.dart';
import 'package:vault_env_manager/src/features/workbench/presentation/controllers/workbench_controller.dart';

/// 📍 SeraphinePathContextBar
/// A glassmorphic path breadcrumb for 2026.
class SeraphinePathContextBar extends GetView<WorkbenchController> {
  const SeraphinePathContextBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: SeraphineColors.of(context).surface.withValues(alpha: 0.05),
        border: Border(
          top: BorderSide(
            color: SeraphineColors.of(
              context,
            ).glassBorder.withValues(alpha: 0.2),
          ),
          bottom: BorderSide(
            color: SeraphineColors.of(
              context,
            ).glassBorder.withValues(alpha: 0.2),
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            const Icon(
              CupertinoIcons.folder_fill,
              size: 13,
              color: SeraphineColors.accentPrimary,
            ),
            SeraphineSpacing.smH,
            Expanded(
              child: Obx(
                () => _buildPathDisplay(
                  context,
                  controller.selectedEnvPath.value,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPathDisplay(BuildContext context, String path) {
    if (path.isEmpty) return const SizedBox.shrink();

    final cleanedPath = path.replaceAll(RegExp(r'^/|/$'), '');
    final segments = cleanedPath.split('/');

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int i = 0; i < segments.length; i++) ...[
            if (i > 0)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Text(
                  '/',
                  style: SeraphineTypography.code.copyWith(
                    fontSize: 10,
                    color: SeraphineColors.of(context).textDetail,
                  ),
                ),
              ),
            _buildPathSegment(context, segments[i], i == segments.length - 1),
          ],
          _buildVersionBadge(context),
        ],
      ),
    );
  }

  Widget _buildPathSegment(
    BuildContext context,
    String segmentRaw,
    bool isLast,
  ) {
    final segment = segmentRaw.toUpperCase();
    Color? badgeColor;

    // Environment highlighting
    if (segment == 'PRODUCTION') {
      badgeColor = SeraphineColors.of(context).primary;
    }
    if (segment == 'STAGING') {
      badgeColor = SeraphineColors.of(context).warning;
    }
    if (segment == 'DEVELOPMENT') {
      badgeColor = SeraphineColors.of(context).primary;
    }

    if (badgeColor != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: ShapeDecoration(
          color: badgeColor.withValues(alpha: 0.1),
          shape: SeraphineShapes.squircle(
            radius: 4,
            side: BorderSide(color: badgeColor.withValues(alpha: 0.3)),
          ),
        ),
        child: Text(
          segment,
          style: SeraphineTypography.label.copyWith(
            fontSize: 9,
            fontWeight: FontWeight.w900,
            color: badgeColor,
          ),
        ),
      );
    }

    return Text(
      segment,
      style: SeraphineTypography.code.copyWith(
        fontSize: 11,
        fontWeight: isLast ? FontWeight.w800 : FontWeight.w400,
        color: isLast
            ? SeraphineColors.of(context).warning.withValues(alpha: 0.8)
            : SeraphineColors.of(context).textPrimary.withValues(alpha: 0.9),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildVersionBadge(BuildContext context) {
    return Obx(
      () => controller.selectedEnvVersion.value != null
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Container(
                    width: 1,
                    height: 12,
                    color: SeraphineColors.of(
                      context,
                    ).glassBorder.withValues(alpha: 0.2),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: ShapeDecoration(
                    color: SeraphineColors.accentPrimary.withValues(alpha: 0.1),
                    shape: SeraphineShapes.squircle(
                      radius: 4,
                      side: BorderSide(
                        color: SeraphineColors.accentPrimary.withValues(
                          alpha: 0.4,
                        ),
                      ),
                    ),
                  ),
                  child: Text(
                    'V${controller.selectedEnvVersion.value}',
                    style: SeraphineTypography.label.copyWith(
                      fontSize: 11,
                      color: SeraphineColors.of(context).textPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            )
          : const SizedBox.shrink(),
    );
  }
}
