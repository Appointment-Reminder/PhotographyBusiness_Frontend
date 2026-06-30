import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_colors.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_text_styles.dart';

class NavBarButton extends StatefulWidget {
  const NavBarButton({
    super.key,
    required this.label,
    required this.routes,
    required this.isSelected,
    required this.onTap,
});

  final String label;
  final String routes;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<StatefulWidget> createState() => _NavBarButtonState();

}

class _NavBarButtonState extends State<NavBarButton> {
  bool _isHovered = false;

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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: style.backgroundColor,
            borderRadius: BorderRadius.circular(8),
            boxShadow: widget.isSelected
                ? [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ]
                : null,
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

  _NavButtonStyle _getStyle() {
    if (widget.isSelected) {
      return const _NavButtonStyle(
        backgroundColor: AppColors.selectedButtonBg,
        textColor: AppColors.blackText,
        fontWeight: FontWeight.w600,
      );
    }

    if (_isHovered) {
      return const _NavButtonStyle(
        backgroundColor: AppColors.hoveredButtonBg,
        textColor: AppColors.blackText,
        fontWeight: FontWeight.w500,
      );
    }

    return const _NavButtonStyle(
      backgroundColor: AppColors.sidebarBg,
      textColor: AppColors.greyText,
      fontWeight: FontWeight.w400,
    );
  }
}

class _NavButtonStyle {
  const _NavButtonStyle({
    required this.backgroundColor,
    required this.textColor,
    required this.fontWeight,
  });

  final Color backgroundColor;
  final Color textColor;
  final FontWeight fontWeight;
}