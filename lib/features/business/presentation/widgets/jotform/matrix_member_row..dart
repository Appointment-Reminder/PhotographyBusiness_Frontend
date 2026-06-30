import 'package:flutter/material.dart';
import 'package:photography_business_frontend/core/Presentation/widgets/atoms/avatar_chip.dart';
import 'package:photography_business_frontend/core/presentation/theme/app_colors.dart';
import 'package:photography_business_frontend/core/presentation/theme/app_text_styles.dart';
import 'matrix_cell.dart';

class MatrixCategoryData {
  final String id;
  final String name;
  final Color color;

  const MatrixCategoryData({
    required this.id,
    required this.name,
    required this.color,
  });
}

class MatrixMemberRow extends StatelessWidget {
  final String memberId;
  final String name;
  final String email;
  final String initials;
  final List<MatrixCategoryData> categories;
  final Set<String> configuredCategoryIds; // which cells are configured
  final bool isCollapsed;
  final VoidCallback onToggleCollapse;
  final void Function(String categoryId) onCellTap;

  const MatrixMemberRow({
    super.key,
    required this.memberId,
    required this.name,
    required this.email,
    required this.initials,
    required this.categories,
    required this.configuredCategoryIds,
    required this.isCollapsed,
    required this.onToggleCollapse,
    required this.onCellTap,
  });

  @override
  Widget build(BuildContext context) {
    final configuredCount = configuredCategoryIds.length;

    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Member info — fixed width matching column header
          SizedBox(
            width: 280,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(right: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                children: [
                  AvatarChip(initials: initials),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: AppTextStyles.body14.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          email,
                          style: AppTextStyles.muted12,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Count + collapse toggle
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$configuredCount/${categories.length}',
                        style: AppTextStyles.monoMuted11,
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        onTap: onToggleCollapse,
                        child: Icon(
                          isCollapsed
                              ? Icons.keyboard_arrow_down
                              : Icons.keyboard_arrow_up,
                          size: 16,
                          color: AppColors.mutedText,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Cells
          ...categories.map((cat) {
            final isConfigured = configuredCategoryIds.contains(cat.id);
            return Expanded(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  border: Border(right: BorderSide(color: AppColors.border)),
                ),
                child: isCollapsed
                    ? Center(
                  child: isConfigured
                      ? const Icon(
                    Icons.check,
                    size: 14,
                    color: Color(0xFF22C55E),
                  )
                      : Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.mutedText.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                )
                    : MatrixCell(
                  isConfigured: isConfigured,
                  onTap: () => onCellTap(cat.id),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}