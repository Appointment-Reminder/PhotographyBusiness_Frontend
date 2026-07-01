import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:photography_business_frontend/core/Presentation/widgets/category/category_badge.dart';
import 'package:photography_business_frontend/core/Presentation/widgets/category/commission_type_toggle.dart';
import 'package:photography_business_frontend/core/presentation/theme/app_colors.dart';
import 'package:photography_business_frontend/core/presentation/theme/app_text_styles.dart';

class CommissionRow extends StatefulWidget {
  final String packageName;
  final String categoryName;
  final int categoryId;
  final String value;
  final bool isPercent;
  final ValueChanged<String> onValueChanged;
  final ValueChanged<bool> onTypeChanged;
  final VoidCallback onRemove;

  const CommissionRow({
    super.key,
    required this.packageName,
    required this.categoryName,
    required this.value,
    required this.isPercent,
    required this.onValueChanged,
    required this.onTypeChanged,
    required this.onRemove, required this.categoryId,
  });

  @override
  State<CommissionRow> createState() => _CommissionRowState();
}

class _CommissionRowState extends State<CommissionRow> {
  bool _isHovered = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(CommissionRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit:  (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: _isHovered
              ? AppColors.primaryText.withOpacity(0.05)
              : Colors.transparent,
          border: const Border(
            bottom: BorderSide(color: AppColors.border),
          ),
        ),
        child: Row(
          children: [
            // Package name
            Expanded(
              child: Text(
                widget.packageName,
                style: AppTextStyles.body14.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Category badge
            SizedBox(
              width: 70,
              child: CategoryBadge(categoryName: widget.categoryName, categoryId: widget.categoryId,),
            ),
            SizedBox(width: 50,),

            // Value input + toggle
            SizedBox(
              width: 140,
              child: Row(
                children: [
                  SizedBox(
                    width: 56,
                    child: TextField(
                      controller: _controller,
                      textAlign: TextAlign.right,
                      keyboardType: TextInputType.number,
                      style: AppTextStyles.mono12,
                      onChanged: widget.onValueChanged,
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 6,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: const BorderSide(
                            color: AppColors.primaryText,
                            width: 1.5,
                          ),
                        ),
                        filled: true,
                        fillColor: AppColors.mainBg,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CommissionTypeToggle(
                    isPercent: widget.isPercent,
                    onChanged: widget.onTypeChanged,
                  ),
                ],
              ),
            ),

            // Delete button
            const SizedBox(width: 8),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 150),
              opacity: _isHovered ? 1.0 : 0.0,
              child: GestureDetector(
                onTap: widget.onRemove,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 14,
                    color: AppColors.mutedText,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}