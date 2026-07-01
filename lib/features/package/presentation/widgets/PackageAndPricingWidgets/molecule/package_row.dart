import 'package:flutter/material.dart';
import 'package:photography_business_frontend/core/presentation/theme/app_colors.dart';
import 'package:photography_business_frontend/core/presentation/theme/app_text_styles.dart';

class PackageRow extends StatefulWidget {
  final String name;
  final String description;
  final String? currentPrice; // e.g. "160 EUR"
  final bool isSelected;
  final VoidCallback onTap;

  const PackageRow({
    super.key,
    required this.name,
    required this.description,
    required this.isSelected,
    required this.onTap,
    this.currentPrice,
  });

  @override
  State<PackageRow> createState() => _PackageRowState();
}

class _PackageRowState extends State<PackageRow> {
  bool _isHovered = false;

  Color _getBackgroundColor() {
    if (widget.isSelected) return AppColors.primaryText.withOpacity(0.05);
    if (_isHovered) return AppColors.primaryText.withOpacity(0.05);
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
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            border: const Border(
              bottom: BorderSide(color: AppColors.border),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 150),
                      style: AppTextStyles.body14.copyWith(
                        color: widget.isSelected
                            ? AppColors.primaryText
                            : AppColors.mutedText,
                        fontWeight: widget.isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                      child: Text(widget.name),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.description,
                      style: AppTextStyles.muted12,
                    ),
                  ],
                ),
              ),
              if (widget.currentPrice != null)
                Text(
                  widget.currentPrice!,
                  style: AppTextStyles.mono12.copyWith(
                    color: widget.isSelected
                        ? AppColors.primaryText
                        : AppColors.mutedText,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}