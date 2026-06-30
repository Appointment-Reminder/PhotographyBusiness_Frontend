import 'package:flutter/material.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_colors.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_text_styles.dart';

class CommissionTypeToggle extends StatelessWidget {
  final bool isPercent; // true = %, false = EUR
  final ValueChanged<bool> onChanged;

  const CommissionTypeToggle({
    super.key,
    required this.isPercent,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(6),
      ),
      clipBehavior: Clip.hardEdge,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleButton(
            label: '%',
            isActive: isPercent,
            onTap: () => onChanged(true),
          ),
          Container(width: 1, color: AppColors.border),
          _ToggleButton(
            label: '€',
            isActive: !isPercent,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }
}

class _ToggleButton extends StatefulWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ToggleButton({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_ToggleButton> createState() => _ToggleButtonState();
}

class _ToggleButtonState extends State<_ToggleButton> {
  bool _isHovered = false;

  Color _getBg() {
    if (widget.isActive) return AppColors.primaryText;
    if (_isHovered) return AppColors.sidebarBg;
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit:  (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          color: _getBg(),
          child: Text(
            widget.label,
            style: AppTextStyles.mono12.copyWith(
              color: widget.isActive ? AppColors.active : AppColors.mutedText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}