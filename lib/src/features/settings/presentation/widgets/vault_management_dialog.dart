import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:vault_env_manager/src/core/app/data/models/vault_profile.dart';
import 'package:vault_env_manager/src/core/app/data/services/app_config_service.dart';
import 'package:vault_env_manager/src/core/design_system/molecules/seraphine_button.dart';
import 'package:vault_env_manager/src/core/design_system/molecules/seraphine_input_field.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_colors.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_motion.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_shapes.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_spacing.dart';
import 'package:vault_env_manager/src/core/design_system/tokens/seraphine_typography.dart';

/// 🏛️ VaultManagementDialog
/// High-fidelity multi-tenant management reimagined for 2026.
class VaultManagementDialog extends StatefulWidget {
  const VaultManagementDialog({super.key});

  static Future<void> show(BuildContext context) async {
    await showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (context) => const VaultManagementDialog(),
    );
  }

  @override
  State<VaultManagementDialog> createState() => _VaultManagementDialogState();
}

class _VaultManagementDialogState extends State<VaultManagementDialog> {
  final AppConfigService _config = AppConfigService.to;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(40),
      child: AnimatedContainer(
        duration: SeraphineMotion.slow,
        width: 800,
        height: 600,
        decoration: ShapeDecoration(
          color: SeraphineColors.of(context).surface,
          shape: SeraphineShapes.squircle(
            radius: 24,
            side: BorderSide(
              color: SeraphineColors.of(
                context,
              ).glassBorder.withValues(alpha: 0.5),
            ),
          ),
          shadows: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 40,
              spreadRadius: -10,
            ),
          ],
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildProfileList()),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(SeraphineSpacing.lg),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: SeraphineColors.of(
              context,
            ).glassBorder.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                CupertinoIcons.square_stack_3d_down_right,
                color: SeraphineColors.of(context).primary,
              ),
              SeraphineSpacing.mdH,
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'VAULT TENANTS',
                    style: SeraphineTypography.label.copyWith(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Manage your isolated vault environments',
                    style: SeraphineTypography.caption.copyWith(
                      color: SeraphineColors.of(context).textDetail,
                    ),
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(CupertinoIcons.xmark),
            color: SeraphineColors.of(context).textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildProfileList() {
    return Obx(() {
      final profiles = _config.vaultProfiles;
      return ListView.separated(
        padding: const EdgeInsets.all(SeraphineSpacing.lg),
        itemCount: profiles.length,
        separatorBuilder: (_, _) => SeraphineSpacing.mdV,
        itemBuilder: (context, index) {
          final profile = profiles[index];
          final isActive = profile.id == _config.activeProfileId.value;

          return _VaultProfileTile(
            profile: profile,
            isActive: isActive,
            onEdit: () => _showEditDialog(profile),
            onDelete: profiles.length > 1
                ? () => _confirmDelete(profile)
                : null,
            onSwitch: isActive ? null : () => _config.switchVault(profile.id),
          );
        },
      );
    });
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(SeraphineSpacing.lg),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: SeraphineColors.of(
              context,
            ).glassBorder.withValues(alpha: 0.3),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SeraphineButton.glass(
            text: 'ADD NEW TENANT',
            icon: CupertinoIcons.add,
            onPressed: () => _showEditDialog(null),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(VaultProfile? profile) {
    showDialog(
      context: context,
      builder: (ctx) => _EditProfileDialog(
        profile: profile,
        onSave: (p) async {
          await _config.saveProfile(p);
        },
      ),
    );
  }

  void _confirmDelete(VaultProfile profile) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text('Delete Tenant?'),
        content: Text(
          'This will permanently remove "${profile.name}" and its associated credentials.',
        ),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(ctx),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              _config.deleteProfile(profile.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _VaultProfileTile extends StatelessWidget {
  final VaultProfile profile;
  final bool isActive;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;
  final VoidCallback? onSwitch;

  const _VaultProfileTile({
    required this.profile,
    required this.isActive,
    required this.onEdit,
    this.onDelete,
    this.onSwitch,
  });

  @override
  Widget build(BuildContext context) {
    final color = profile.accentColor != null
        ? Color(profile.accentColor!)
        : SeraphineColors.of(context).primary;
    final icon = profile.iconData != null
        ? IconData(
            profile.iconData!,
            fontFamily: 'CupertinoIcons',
            fontPackage: 'cupertino_icons',
          )
        : CupertinoIcons.cloud_fill;

    return AnimatedContainer(
      duration: SeraphineMotion.fast,
      padding: const EdgeInsets.all(SeraphineSpacing.md),
      decoration: ShapeDecoration(
        color: isActive
            ? color.withValues(alpha: 0.1)
            : SeraphineColors.of(
                context,
              ).surfaceHighlight.withValues(alpha: 0.1),
        shape: SeraphineShapes.squircle(
          radius: 16,
          side: BorderSide(
            color: isActive
                ? color.withValues(alpha: 0.5)
                : SeraphineColors.of(
                    context,
                  ).glassBorder.withValues(alpha: 0.3),
            width: isActive ? 1.5 : 1.0,
          ),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          SeraphineSpacing.mdH,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      profile.name,
                      style: SeraphineTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (isActive) ...[
                      SeraphineSpacing.smH,
                      _buildActiveBadge(color),
                    ],
                  ],
                ),
                Text(
                  profile.vaultOrigin,
                  style: SeraphineTypography.caption.copyWith(
                    color: SeraphineColors.of(context).textDetail,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              if (onSwitch != null)
                TextButton(
                  onPressed: onSwitch,
                  child: Text(
                    'SWITCH',
                    style: SeraphineTypography.label.copyWith(
                      color: color,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(CupertinoIcons.settings, size: 18),
                color: SeraphineColors.of(context).textSecondary,
              ),
              if (onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(CupertinoIcons.trash, size: 18),
                  color: SeraphineColors.of(
                    context,
                  ).primary.withValues(alpha: 0.7),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveBadge(Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'ACTIVE',
        style: TextStyle(
          color: Colors.white,
          fontSize: 8,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _EditProfileDialog extends StatefulWidget {
  final VaultProfile? profile;
  final Function(VaultProfile) onSave;

  const _EditProfileDialog({this.profile, required this.onSave});

  @override
  State<_EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<_EditProfileDialog> {
  late TextEditingController _nameController;
  late TextEditingController _originController;
  int? _selectedColor;
  int? _selectedIcon;

  final List<int> _colors = [
    0xFF007AFF,
    0xFF5856D6,
    0xFFFF9500,
    0xFF34C759,
    0xFFFF3B30,
    0xFF5AC8FA,
  ];

  final List<int> _icons = [
    CupertinoIcons.cloud_fill.codePoint,
    CupertinoIcons.lock_fill.codePoint,
    CupertinoIcons.briefcase_fill.codePoint,
    CupertinoIcons.house_fill.codePoint,
    CupertinoIcons.gear_alt_fill.codePoint,
    CupertinoIcons.shield_fill.codePoint,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile?.name ?? '');
    _originController = TextEditingController(
      text: widget.profile?.vaultOrigin ?? '',
    );
    _selectedColor = widget.profile?.accentColor ?? _colors.first;
    _selectedIcon = widget.profile?.iconData ?? _icons.first;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: SeraphineColors.of(context).surface,
      shape: SeraphineShapes.squircle(radius: 20),
      title: Text(
        widget.profile == null ? 'NEW TENANT' : 'EDIT TENANT',
        style: SeraphineTypography.label.copyWith(
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SeraphineInputField(
              label: 'Name',
              controller: _nameController,
              hint: 'Production, Personal, etc.',
            ),
            SeraphineSpacing.mdV,
            SeraphineInputField(
              label: 'Vault Origin URL',
              controller: _originController,
              hint: 'https://vault.example.com',
            ),
            SeraphineSpacing.lgV,
            Text(
              'BRANDING',
              style: SeraphineTypography.label.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
            SeraphineSpacing.smV,
            Row(children: [..._colors.map((c) => _buildColorPicker(c))]),
            SeraphineSpacing.mdV,
            Row(children: [..._icons.map((i) => _buildIconPicker(i))]),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'CANCEL',
            style: SeraphineTypography.label.copyWith(
              color: SeraphineColors.of(context).textDetail,
              fontSize: 11,
            ),
          ),
        ),
        SeraphineButton(
          text: 'SAVE',
          variant: SeraphineButtonVariant.solid,
          onPressed: () {
            final p =
                widget.profile?.copyWith(
                  name: _nameController.text,
                  vaultOrigin: _originController.text,
                  accentColor: _selectedColor,
                  iconData: _selectedIcon,
                ) ??
                VaultProfile(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: _nameController.text,
                  vaultOrigin: _originController.text,
                  vaultUiDomain: '',
                  scrapingUrl: '',
                  vaultNamespace: '',
                  vaultDiscoveryPath: '',
                  verifySsl: true,
                  accentColor: _selectedColor,
                  iconData: _selectedIcon,
                );
            widget.onSave(p);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Widget _buildColorPicker(int colorValue) {
    final isSelected = _selectedColor == colorValue;
    return GestureDetector(
      onTap: () => setState(() => _selectedColor = colorValue),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Color(colorValue),
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Color(colorValue).withValues(alpha: 0.5),
                    blurRadius: 4,
                  ),
                ]
              : null,
        ),
      ),
    );
  }

  Widget _buildIconPicker(int iconCode) {
    final isSelected = _selectedIcon == iconCode;
    return GestureDetector(
      onTap: () => setState(() => _selectedIcon = iconCode),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isSelected
              ? Color(_selectedColor!).withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          IconData(
            iconCode,
            fontFamily: 'CupertinoIcons',
            fontPackage: 'cupertino_icons',
          ),
          size: 20,
          color: isSelected
              ? Color(_selectedColor!)
              : SeraphineColors.of(context).textSecondary,
        ),
      ),
    );
  }
}
