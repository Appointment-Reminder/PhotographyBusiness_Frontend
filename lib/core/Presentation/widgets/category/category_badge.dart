import 'package:flutter/material.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_text_styles.dart';

class CategoryBadge extends StatelessWidget {
  final String categoryName;
  final int categoryId;

  const CategoryBadge({
    super.key,
    required this.categoryName,
    required this.categoryId,
  });

  static const _palette = [
    _BadgeStyle(bg: Color(0xFFE0F2FE), text: Color(0xFF0369A1)), // sky
    _BadgeStyle(bg: Color(0xFFFFE4E6), text: Color(0xFFBE123C)), // rose
    _BadgeStyle(bg: Color(0xFFFEF3C7), text: Color(0xFFB45309)), // amber
    _BadgeStyle(bg: Color(0xFFDCFCE7), text: Color(0xFF15803D)), // green
    _BadgeStyle(bg: Color(0xFFF3E8FF), text: Color(0xFF7E22CE)), // purple
    _BadgeStyle(bg: Color(0xFFFFEDD5), text: Color(0xFFC2410C)), // orange
    _BadgeStyle(bg: Color(0xFFE0E7FF), text: Color(0xFF4338CA)), // indigo
    _BadgeStyle(bg: Color(0xFFFCE7F3), text: Color(0xFF9D174D)), // pink
    _BadgeStyle(bg: Color(0xFFCCFBF1), text: Color(0xFF0F766E)), // teal
    _BadgeStyle(bg: Color(0xFFFEF9C3), text: Color(0xFFA16207)), // yellow
  ];

  _BadgeStyle get _style => _palette[categoryId % _palette.length];

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: AlignmentGeometry.center,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: _style.bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        categoryName,
        style: AppTextStyles.mono11.copyWith(
          color: _style.text,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _BadgeStyle {
  final Color bg;
  final Color text;
  const _BadgeStyle({required this.bg, required this.text});
}