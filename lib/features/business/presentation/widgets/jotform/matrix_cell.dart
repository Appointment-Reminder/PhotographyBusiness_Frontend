import 'package:flutter/material.dart';
import 'package:photography_business_frontend/core/Presentation/widgets/atoms/configured_cell_icon.dart';
import 'package:photography_business_frontend/core/Presentation/widgets/atoms/unconfigured_cell_icon.dart';
import 'package:photography_business_frontend/core/presentation/theme/app_colors.dart';
import 'package:photography_business_frontend/core/presentation/theme/app_text_styles.dart';

class MatrixCell extends StatefulWidget {
  final bool isConfigured;
  final VoidCallback onTap;

  const MatrixCell({
    super.key,
    required this.isConfigured,
    required this.onTap,
  });

  @override
  State<MatrixCell> createState() => _MatrixCellState();
}

class _MatrixCellState extends State<MatrixCell> {
  bool _isHovered = false;

  Color _getBorderColor() {
    if (widget.isConfigured) {
      return _isHovered
          ? const Color(0xFF86EFAC) // green-300
          : const Color(0xFFBBF7D0); // green-200
    }
    return _isHovered
        ? AppColors.primaryText.withOpacity(0.2)
        : AppColors.border;
  }

  Color _getBgColor() {
    if (widget.isConfigured) {
      return _isHovered
          ? const Color(0xFFDCFCE7) // green-100
          : const Color(0xFFF0FDF4); // green-50
    }
    return _isHovered ? AppColors.sidebarBg : AppColors.active;
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
          decoration: BoxDecoration(
            color: _getBgColor(),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: _getBorderColor()),
          ),
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              widget.isConfigured
                  ? const ConfiguredCellIcon()
                  : UnconfiguredCellIcon(isHovered: _isHovered),
              const SizedBox(height: 4),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 150),
                opacity: _isHovered ? 1.0 : 0.0,
                child: Text(
                  widget.isConfigured ? 'edit' : 'setup',
                  style: AppTextStyles.mono10.copyWith(
                    color: widget.isConfigured
                        ? const Color(0xFF15803D) // green-700
                        : AppColors.mutedText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}