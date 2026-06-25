
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_text_styles.dart' show AppTextStyles;
import 'package:photography_business_frontend/core/extension/StringExtension.dart';
import 'package:photography_business_frontend/features/business/domain/entities/business_role.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_colors.dart';

class NavBarUserCard extends StatefulWidget {

  final String FirstName;
  final String LastName;
  final BusinessRole Role;

  const NavBarUserCard({super.key, required this.FirstName, required this.LastName, required this.Role});

  @override
  State<StatefulWidget> createState() => _NavBarUserCardState();
}


class _NavBarUserCardState extends State<NavBarUserCard> {

  @override
  Widget build(BuildContext) {
    final style = _getStyle();
    final initials = '${widget.FirstName[0]}${widget.LastName[0]}'.toUpperCase();
    final roleLabel = widget.Role == BusinessRole.admin ? 'Admin' : 'User';

    return Container(
      height: 80,
      width: double.infinity,
      child:
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
          children: [
            CircleAvatar(
              radius: 17,
              backgroundColor: AppColors.border,
              child: Text(
                initials,
                style: TextStyle(
                  color: AppColors.greyText,
                  fontWeight: FontWeight.w600,
                  fontSize: 12
                ),
              ),
            ),

            const SizedBox(width: 10),

            Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.FirstName.capitalize()} ${widget.LastName.capitalize()}',
                      style: TextStyle(
                        fontWeight: style.headerWeight,
                        color: style.roleTextColor,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      roleLabel,
                      style: TextStyle(
                        fontWeight: style.roleWeight,
                        color: style.headerColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
            ),
            // Logout icon
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  // logout logic
                },
                borderRadius: BorderRadius.circular(8),
                hoverColor: AppColors.greyText.withOpacity(0.15),
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.logout,
                    size: 18,
                    color: AppColors.greyText,
                  ),
                ),
              ),
            ),
          ],
                ),
        ),
    );
  }



  _NavBarUserCardStyle _getStyle(){
    return const _NavBarUserCardStyle(
        backgroundColor: AppColors.navBarBg,
        headerColor: AppColors.greyText,
        roleTextColor: AppColors.blackText,
        headerWeight: FontWeight.w600,
        roleWeight: FontWeight.w500,
    );
  }
}

class _NavBarUserCardStyle {

  final Color backgroundColor;
  final Color headerColor;
  final Color roleTextColor;
  final FontWeight headerWeight;
  final FontWeight roleWeight;

  const _NavBarUserCardStyle({
    required this.backgroundColor,
    required this.headerColor,
    required this.roleTextColor,
    required this.headerWeight,
    required this.roleWeight,
  });
}