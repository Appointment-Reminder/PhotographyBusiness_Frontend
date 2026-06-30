import 'package:flutter/material.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_colors.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_text_styles.dart';


class _NavButtonStyle {
  final Color backgroundColor;
  final Color textColor;
  final FontWeight fontWeight;

  const _NavButtonStyle({
    required this.backgroundColor,
    required this.textColor,
    required this.fontWeight,
  });
}

class NavTabItem extends StatefulWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const NavTabItem({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<NavTabItem> createState() => _NavTabItemState();
}

class _NavTabItemState extends State<NavTabItem> {
  bool _isHovered = false;

  _NavButtonStyle _getStyle() {
    if (widget.isSelected) {
      print('is Selected');
      return const _NavButtonStyle(
        backgroundColor: AppColors.TNB_selectedButtonBg,
        textColor: AppColors.TNB_whiteText,
        fontWeight: FontWeight.w600,
      );
    }

    if (_isHovered) {
      print('isHovered');
      return const _NavButtonStyle(
        backgroundColor: AppColors.TNB_hoveredButtonBg,
        textColor: AppColors.TNB_blackText,
        fontWeight: FontWeight.w500,
      );
    }

    print('is alone');
    return const _NavButtonStyle(
      backgroundColor: AppColors.active,
      textColor: AppColors.TNB_greyText,
      fontWeight: FontWeight.w400,
    );
  }

  @override
  Widget build(BuildContext context) {
    final style = _getStyle();

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit:  (_) => setState(() => _isHovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: style.backgroundColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 150),
            style: AppTextStyles.body14.copyWith(
              color: style.textColor,
              fontWeight: style.fontWeight,
            ),
            child: Text(widget.label),
          ),
        ),
      ),
    );
  }
}