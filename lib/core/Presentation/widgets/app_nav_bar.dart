import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_colors.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_text_styles.dart';
import 'package:photography_business_frontend/core/Presentation/widgets/NavBar/NavBarButton.dart';
import 'package:photography_business_frontend/core/Presentation/widgets/NavBar/NavBarUserCard.dart';
import 'package:photography_business_frontend/features/business/domain/entities/business_role.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/business_providers.dart';
import 'package:photography_business_frontend/features/user_create/presentation/providers/auth_provders.dart';
import 'package:photography_business_frontend/features/user_create/presentation/providers/state/auth_state.dart';

class AppNavBar extends ConsumerWidget{
  const AppNavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref){
    final authState = ref.watch(authNotifierProvider);

    return Container(
      width: 250,
      decoration: BoxDecoration(
        color: AppColors.navBarBg,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            if(authState is AuthAuthenticated)
              SizedBox(
                height: 50,
                width: double.infinity,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Workspace",
                    textAlign: TextAlign.left,
                    style: AppTextStyles.heading16,
                  ),
                ),
              ),
              Divider(),
              SizedBox(
                height: 40,
                width: double.infinity,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "MENU",
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      color: AppColors.greyText,
                    )
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  NavBarButton(
                      label: 'Business',
                      routes: '/',
                      isSelected: false,
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/businesses');
                      },
                  ),
                  NavBarButton(
                    label: 'Users',
                    routes: '/',
                    isSelected: true,
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/Appointment');
                    },
                  ),
                  NavBarButton(
                    label: 'Packages',
                    routes: '/',
                    isSelected: false,
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/Packages');
                    },
                  ),
                  NavBarButton(
                    label: 'home',
                    routes: '/',
                    isSelected: false,
                    onTap: () {
                      Navigator.pushReplacementNamed(context, '/home');
                    },
                  ),
                ],
              ),
              Spacer(),
              Divider(),
              NavBarUserCard(FirstName: 'gael', LastName: 'Courmont', Role: BusinessRole.admin)
          ],
        ),
      ),
    );
  }
}