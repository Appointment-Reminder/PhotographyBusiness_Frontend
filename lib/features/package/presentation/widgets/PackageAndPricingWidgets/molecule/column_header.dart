import 'package:flutter/material.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_colors.dart';
import 'package:photography_business_frontend/core/Presentation/widgets/section_label.dart';


class ColumnHeader extends StatelessWidget {
  final String label;
  final VoidCallback? onAdd;

  const ColumnHeader(this.label, {super.key, this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      width: double.infinity,
      child: Row(
        children: [
          Expanded(child: SectionLabel(label)),
          if (onAdd != null)
            GestureDetector(
              onTap: onAdd,
              child: const Icon(Icons.add, size: 14, color: AppColors.mutedText),
            ),
        ],
      ),
    );
  }
}