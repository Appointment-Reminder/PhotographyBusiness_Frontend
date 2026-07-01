import 'package:flutter/material.dart';
import 'package:photography_business_frontend/core/presentation/theme/app_colors.dart';
import 'package:photography_business_frontend/core/presentation/theme/app_text_styles.dart';

class CategoryRow extends StatefulWidget {
  final String name;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryRow({
    super.key,
    required this.name,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<CategoryRow> createState() => _CategoryRowState();
}

class _CategoryRowState extends State<CategoryRow> {
  bool _isHovered = false;

  Color _getBackgroundColor() {
    if (widget.isSelected) return AppColors.primaryText.withOpacity(0.05);
    if (_isHovered) return AppColors.primaryText.withOpacity(0.05);
    return Colors.transparent;
  }

  Color _getTextColor() {
    if (widget.isSelected) return AppColors.primaryText;
    if (_isHovered) return AppColors.primaryText;
    return AppColors.mutedText;
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            border: const Border(
              bottom: BorderSide(color: AppColors.border),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 150),
                  style: AppTextStyles.body14.copyWith(
                    color: _getTextColor(),
                    fontWeight: widget.isSelected
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                  child: Text(widget.name),
                ),
              ),
              if (widget.isSelected)
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryText,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}