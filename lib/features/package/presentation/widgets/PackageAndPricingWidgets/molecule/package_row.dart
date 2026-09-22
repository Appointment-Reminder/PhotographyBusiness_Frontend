import 'package:flutter/material.dart';
import 'package:photography_business_frontend/core/presentation/theme/app_colors.dart';
import 'package:photography_business_frontend/core/presentation/theme/app_text_styles.dart';

class PackageRow extends StatefulWidget {
  final String name;
  final String description;
  final String? currentPrice; // e.g. "160 EUR"
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PackageRow({
    super.key,
    required this.name,
    required this.description,
    required this.isSelected,
    required this.onTap,
    this.currentPrice,
    this.onEdit,
    this.onDelete,
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
              // ── Left side: name + description (unchanged) ──
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

              // ── Right side: price + edit/delete icons, all in one Row ──
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.currentPrice != null)
                    Text(
                      widget.currentPrice!,
                      style: AppTextStyles.mono12.copyWith(
                        color: widget.isSelected
                            ? AppColors.primaryText
                            : AppColors.mutedText,
                      ),
                    ),

                  if (widget.onEdit != null) ...[
                    const SizedBox(width: 8),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 150),
                      opacity: _isHovered ? 1.0 : 0.0,
                      child: GestureDetector(
                        onTap: widget.onEdit,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          child: const Icon(
                            Icons.edit_outlined,
                            size: 14,
                            color: AppColors.mutedText,
                          ),
                        ),
                      ),
                    ),
                  ],

                  if (widget.onDelete != null) ...[
                    const SizedBox(width: 4),
                    AnimatedOpacity(
                      duration: const Duration(milliseconds: 150),
                      opacity: _isHovered ? 1.0 : 0.0,
                      child: GestureDetector(
                        onTap: widget.onDelete,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          child: const Icon(
                            Icons.delete_outline,
                            size: 14,
                            color: AppColors.mutedText,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}