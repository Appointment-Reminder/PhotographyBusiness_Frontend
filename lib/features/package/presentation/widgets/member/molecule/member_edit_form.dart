import 'package:flutter/material.dart';
import 'package:photography_business_frontend/core/presentation/theme/app_colors.dart';
import 'package:photography_business_frontend/core/presentation/theme/app_text_styles.dart';

class MemberEditForm extends StatefulWidget {
  final String memberName;
  final String memberEmail;
  final String initialRole;
  final List<String> roleOptions;
  final ValueChanged<String> onSave; // role only
  final VoidCallback onCancel;

  const MemberEditForm({
    super.key,
    required this.memberName,
    required this.memberEmail,
    required this.initialRole,
    required this.roleOptions,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<MemberEditForm> createState() => _MemberEditFormState();
}

class _MemberEditFormState extends State<MemberEditForm> {
  late String _role = widget.initialRole;

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
          Text(widget.memberName, style: AppTextStyles.body14.copyWith(fontWeight: FontWeight.w600)),
          Text(widget.memberEmail, style: AppTextStyles.muted12),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: widget.roleOptions.contains(_role) ? _role : null,
            items: widget.roleOptions
                .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                .toList(),
            onChanged: (v) { if (v != null) setState(() => _role = v); },
            decoration: const InputDecoration(isDense: true),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _ActionButton(label: 'Save', icon: Icons.check, isPrimary: true, onTap: () => widget.onSave(_role))),
              const SizedBox(width: 8),
              Expanded(child: _ActionButton(label: 'Cancel', icon: Icons.close, isPrimary: false, onTap: widget.onCancel)),
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