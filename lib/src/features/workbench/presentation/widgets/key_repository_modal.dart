import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/design_system/seraphine_breakpoints.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_colors.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_spacing.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_typography.dart';
import 'package:vault_env_manager/src/features/workbench/presentation/controllers/workbench_controller.dart';
import 'package:vault_env_manager/src/features/workbench/presentation/widgets/_key_repository_manual_tab.dart';
import 'package:vault_env_manager/src/features/workbench/presentation/widgets/_key_repository_stored_tab.dart';
import 'package:vault_env_manager/src/features/workbench/presentation/widgets/_key_repository_tabs.dart';

class KeyRepositoryModal extends GetView<WorkbenchController> {
  const KeyRepositoryModal({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;

    return BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
      child: SafeArea(
        top: isMobile,
        bottom: isMobile,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: isMobile ? double.infinity : 600,
              height: isMobile ? double.infinity : 650,
              margin: isMobile ? EdgeInsets.zero : const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: SeraphineColors.of(
                  context,
                ).surface.withValues(alpha: 0.9),
                borderRadius:
                    isMobile ? BorderRadius.zero : SeraphineSpacing.radiusLG,
                border: isMobile
                    ? null
                    : Border.all(color: SeraphineColors.of(context).border),
                boxShadow: isMobile
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 40,
                          offset: const Offset(0, 20),
                        ),
                      ],
              ),
              child: const Column(
                children: [
                  _ModalHeader(),
                  KeyRepositoryTabs(),
                  Expanded(child: _ModalBody()),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ModalHeader extends StatelessWidget {
  const _ModalHeader();

  @override
  Widget build(BuildContext context) {
    final isMobile = context.isMobile;
    return Padding(
      padding: isMobile
          ? const EdgeInsets.symmetric(horizontal: 16, vertical: 20)
          : SeraphineSpacing.pAllLG,
      child: Row(
        children: [
          Icon(
            CupertinoIcons.archivebox,
            color: SeraphineColors.of(context).primary,
            size: 20,
          ),
          SeraphineSpacing.mdH,
          Text(
            'KEY REPOSITORY',
            style: SeraphineTypography.h3.copyWith(
              fontSize: 16,
              letterSpacing: 1,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Get.back(),
            icon: Icon(
              CupertinoIcons.xmark,
              color: SeraphineColors.of(context).textDetail,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}

class _ModalBody extends GetView<WorkbenchController> {
  const _ModalBody();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      switch (controller.repositoryTab.value) {
        case 0:
          return const KeyRepositoryStoredTab();
        case 1:
          return const KeyRepositoryManualTab();
        default:
          return const SizedBox.shrink();
      }
    });
  }
}
