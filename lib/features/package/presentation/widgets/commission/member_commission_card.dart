import 'package:flutter/material.dart';
import 'package:photography_business_frontend/core/presentation/theme/app_colors.dart';
import 'package:photography_business_frontend/core/presentation/theme/app_text_styles.dart';
import 'package:photography_business_frontend/core/presentation/widgets/section_label.dart';
import 'commission_row.dart';

class CommissionData {
  final String packageId;
  final String packageName;
  final String categoryName;
  final int categoryId;
  String value;
  bool isPercent;

  CommissionData({
    required this.packageId,
    required this.packageName,
    required this.categoryName,
    required this.value,
    required this.isPercent, required this.categoryId,
  });

  CommissionData copyWithCategoryName(String name) => CommissionData(
    packageId: packageId,
    packageName: packageName,
    categoryName: name,
    categoryId: categoryId,
    value: value,
    isPercent: isPercent,
  );
}

class MemberCommissionsCard extends StatelessWidget {
  final String memberName;
  final String memberRole;
  final String memberEmail;
  final List<CommissionData> commissions;
  final ValueChanged<String> onValueChanged; // packageId
  final void Function(String packageId, bool isPercent) onTypeChanged;
  final ValueChanged<String> onRemove;       // packageId

  const MemberCommissionsCard({
    super.key,
    required this.memberName,
    required this.memberRole,
    required this.memberEmail,
    required this.commissions,
    required this.onValueChanged,
    required this.onTypeChanged,
    required this.onRemove,
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
          // Member header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        memberName,
                        style: AppTextStyles.body14.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '$memberRole · $memberEmail',
                        style: AppTextStyles.muted12,
                      ),
                    ],
                  ),
                ),
                SectionLabel('${commissions.length} packages'),
              ],
            ),
          ),

          // Column headers
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.sidebarBg,
              border: const Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              children: [
                Expanded(child: SectionLabel('Package')),
                SizedBox(width: 100, child: SectionLabel('Category')),
                SizedBox(width: 26,),
                SizedBox(width: 140, child: SectionLabel('Commission')),
                const SizedBox(width: 30),
              ],
            ),
          ),

          // Rows
          ...commissions.map((c) => CommissionRow(
            packageName:   c.packageName,
            categoryName:  c.categoryName,
            categoryId:    c.categoryId,
            value:         c.value,
            isPercent:     c.isPercent,
            onValueChanged: (v) => onValueChanged(c.packageId),
            onTypeChanged:  (p) => onTypeChanged(c.packageId, p),
            onRemove:       ()  => onRemove(c.packageId),
          )),
        ],
      ),
    );
  }
}