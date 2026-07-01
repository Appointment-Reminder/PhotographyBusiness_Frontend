import 'package:flutter/material.dart';
import 'package:photography_business_frontend/core/presentation/theme/app_colors.dart';
import 'package:photography_business_frontend/core/presentation/theme/app_text_styles.dart';

class MemberRow extends StatefulWidget {
  final String name;
  final String role;
  final String email;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onEditTap;

  const MemberRow({
    super.key,
    required this.name,
    required this.role,
    required this.email,
    required this.isSelected,
    required this.onTap,
    required this.onEditTap,
  });

  @override
  State<MemberRow> createState() => _MemberRowState();
}

class _MemberRowState extends State<MemberRow> {
  bool _isHovered = false;

  Color _getBg() {
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: _getBg(),
            border: const Border(
              bottom: BorderSide(color: AppColors.border),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.name,
                      style: AppTextStyles.body14.copyWith(
                        color: widget.isSelected
                            ? AppColors.primaryText
                            : AppColors.mutedText,
                        fontWeight: widget.isSelected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(widget.role, style: AppTextStyles.muted12),
                    const SizedBox(height: 2),
                    Text(widget.email, style: AppTextStyles.monoMuted10),
                  ],
                ),
              ),

              // Actions
              Row(
                children: [
                  // Edit — only visible on hover
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 150),
                    opacity: _isHovered ? 1.0 : 0.0,
                    child: GestureDetector(
                      onTap: widget.onEditTap,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.edit_outlined,
                          size: 14,
                          color: AppColors.mutedText,
                        ),
                      ),
                    ),
                  ),
                  // Chevron — only when selected
                  if (widget.isSelected) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right,
                      size: 16,
                      color: AppColors.primaryText,
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