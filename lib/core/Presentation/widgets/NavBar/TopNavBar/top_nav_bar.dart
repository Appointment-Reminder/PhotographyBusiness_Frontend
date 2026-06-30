import 'package:flutter/material.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_colors.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_text_styles.dart';
import 'package:photography_business_frontend/core/Presentation/widgets/NavBar/TopNavBar/NavBarIten.dart';


class TopNavBarItem {
  final String id;
  final String label;
  const TopNavBarItem({required this.id, required this.label});
}

class TopNavBar extends StatelessWidget implements PreferredSizeWidget {
  final String brandName;
  final List<TopNavBarItem> items;
  final String activeId;
  final ValueChanged<String> onItemSelected;

  const TopNavBar({
    super.key,
    required this.brandName,
    required this.items,
    required this.activeId,
    required this.onItemSelected,
  });

  @override
  Size get preferredSize => const Size.fromHeight(48);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      color: AppColors.active,
      child: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Row(
                children: [
                  // Brand
                  Text(
                    brandName,
                    style: AppTextStyles.heading16,
                  ),
                  const SizedBox(width: 24),
                  // Nav items
                  Row(
                    children: items.map((item) => Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: NavTabItem(
                        label: item.label,
                        isSelected: item.id == activeId,
                        onTap: () => onItemSelected(item.id),
                      ),
                    )).toList(),
                  ),
                ],
              ),
            ),
          ),
          // Bottom border
          const Divider(height: 1, thickness: 1, color: AppColors.border),
        ],
      ),
    );
  }
}