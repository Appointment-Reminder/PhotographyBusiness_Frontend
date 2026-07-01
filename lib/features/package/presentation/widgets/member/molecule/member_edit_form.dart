import 'package:flutter/material.dart';
import 'package:photography_business_frontend/core/presentation/theme/app_colors.dart';
import 'package:photography_business_frontend/core/presentation/theme/app_text_styles.dart';

class MemberEditForm extends StatefulWidget {
  final String initialName;
  final String initialRole;
  final String initialEmail;
  final void Function(String name, String role, String email) onSave;
  final VoidCallback onCancel;

  const MemberEditForm({
    super.key,
    required this.initialName,
    required this.initialRole,
    required this.initialEmail,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<MemberEditForm> createState() => _MemberEditFormState();
}

class _MemberEditFormState extends State<MemberEditForm> {
  late TextEditingController _nameController;
  late TextEditingController _roleController;
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _nameController  = TextEditingController(text: widget.initialName);
    _roleController  = TextEditingController(text: widget.initialRole);
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _roleController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: AppTextStyles.monoMuted10,
    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: AppColors.primaryText, width: 1.5),
    ),
    filled: true,
    fillColor: AppColors.mainBg,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _nameController,
            style: AppTextStyles.mono12,
            decoration: _inputDecoration('Name'),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _roleController,
            style: AppTextStyles.mono12,
            decoration: _inputDecoration('Role'),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _emailController,
            style: AppTextStyles.mono12,
            decoration: _inputDecoration('Email'),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _ActionButton(
                  label: 'Save',
                  icon: Icons.check,
                  isPrimary: true,
                  onTap: () => widget.onSave(
                    _nameController.text,
                    _roleController.text,
                    _emailController.text,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ActionButton(
                  label: 'Cancel',
                  icon: Icons.close,
                  isPrimary: false,
                  onTap: widget.onCancel,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primaryText : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
          border: isPrimary
              ? null
              : Border.all(color: AppColors.border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 12,
              color: isPrimary ? AppColors.active : AppColors.mutedText,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.mono12.copyWith(
                color: isPrimary ? AppColors.active : AppColors.mutedText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}