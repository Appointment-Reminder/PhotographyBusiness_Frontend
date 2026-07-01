import 'package:flutter/material.dart';
import 'package:photography_business_frontend/core/presentation/theme/app_colors.dart';
import 'package:photography_business_frontend/core/presentation/theme/app_text_styles.dart';
import 'package:photography_business_frontend/core/presentation/widgets/section_label.dart';
import 'package:photography_business_frontend/features/business/presentation/widgets/jotform/matrix_member_row..dart';
import 'matrix_column_header.dart';

class MatrixMemberData {
  final String id;
  final String name;
  final String email;
  final String initials;

  const MatrixMemberData({
    required this.id,
    required this.name,
    required this.email,
    required this.initials,
  });
}

class WebhookMatrixCard extends StatelessWidget {
  final List<MatrixMemberData> members;
  final List<MatrixCategoryData> categories;
  final Map<String, Set<String>> configuredMap; // memberId → Set<categoryId>
  final Set<String> collapsedMemberIds;
  final void Function(String memberId, String categoryId) onCellTap;
  final ValueChanged<String> onToggleCollapse;

  const WebhookMatrixCard({
    super.key,
    required this.members,
    required this.categories,
    required this.configuredMap,
    required this.collapsedMemberIds,
    required this.onCellTap,
    required this.onToggleCollapse,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.active,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.hardEdge,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildColumnHeaders(),
          ...members.map((member) => MatrixMemberRow(
            memberId:              member.id,
            name:                  member.name,
            email:                 member.email,
            initials:              member.initials,
            categories:            categories,
            configuredCategoryIds: configuredMap[member.id] ?? {},
            isCollapsed:           collapsedMemberIds.contains(member.id),
            onToggleCollapse:      () => onToggleCollapse(member.id),
            onCellTap:             (catId) => onCellTap(member.id, catId),
          )),
        ],
      ),
    );
  }

  Widget _buildColumnHeaders() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          // Member column label
          SizedBox(
            width: 280,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                border: Border(right: BorderSide(color: AppColors.border)),
              ),
              child: const SectionLabel('Member'),
            ),
          ),
          // Category headers
          ...categories.map((cat) => Expanded(
            child: Container(
              decoration: const BoxDecoration(
                border: Border(right: BorderSide(color: AppColors.border)),
              ),
              child: MatrixColumnHeader(
                name:  cat.name,
                color: cat.color,
              ),
            ),
          )),
        ],
      ),
    );
  }
}