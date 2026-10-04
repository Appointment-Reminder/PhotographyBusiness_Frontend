import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/core/Presentation/navigation/app_section.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_colors.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_text_styles.dart';
import 'package:photography_business_frontend/core/Presentation/widgets/NavBar/NavBarButton.dart';
import 'package:photography_business_frontend/core/Presentation/widgets/NavBar/NavBarUserCard.dart';
import 'package:photography_business_frontend/features/business/domain/entities/business_role.dart';
import 'package:photography_business_frontend/features/business/presentation/widgets/business_selector.dart';
import 'package:photography_business_frontend/features/user_create/presentation/providers/auth_provders.dart';
import 'package:photography_business_frontend/features/user_create/presentation/providers/state/auth_state.dart';

class AppNavBar extends ConsumerWidget {
  const AppNavBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final selected = ref.watch(selectedSectionProvider);

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
          children: [
            SizedBox(
              height: 50,
              width: double.infinity,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Workspace", style: AppTextStyles.heading16),
              ),
            ),
            const Divider(),
            Expanded(
              child: ListView(
                children: [
                  for (final section in AppSection.values)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: NavBarButton(
                        label: section.label,
                        routes: '/',
                        isSelected: section == selected,
                        onTap: () => ref.read(selectedSectionProvider.notifier).state = section,
                      ),
                    ),
                ],
              ),
            ),
            const Divider(),
            const BusinessSelector(),
            if (authState is AuthAuthenticated)
              NavBarUserCard(FirstName: authState.user.name, LastName: 't', Role: BusinessRole.admin),
          ],
        ),
      ),
    );
  }
}
