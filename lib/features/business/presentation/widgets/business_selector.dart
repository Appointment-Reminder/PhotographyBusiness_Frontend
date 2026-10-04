import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_colors.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_text_styles.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/business_providers.dart';
import 'package:photography_business_frontend/features/business/presentation/widgets/create_business_dialog.dart';

const _createValue = -1;

/// Sidebar picker for the Selected Business, with "Create business" as the last entry.
class BusinessSelector extends ConsumerWidget {
  const BusinessSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(businessListNotifierProvider);
    final selected = ref.watch(selectedBusinessProvider);

    if (state.isLoading && state.businesses.isEmpty) return const SizedBox.shrink();

    return PopupMenuButton<int>(
      tooltip: 'Switch business',
      position: PopupMenuPosition.over,
      onSelected: (id) {
        if (id == _createValue) {
          showCreateBusinessDialog(context, ref);
        } else {
          ref.read(selectedBusinessIdProvider.notifier).select(id);
        }
      },
      itemBuilder: (_) => [
        for (final b in state.businesses)
          PopupMenuItem(
            value: b.id,
            child: Text(
              b.name,
              style: TextStyle(
                fontWeight: b.id == selected?.id ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        if (state.businesses.isNotEmpty) const PopupMenuDivider(),
        const PopupMenuItem(
          value: _createValue,
          child: Row(children: [Icon(Icons.add, size: 18), SizedBox(width: 8), Text('Create business')]),
        ),
      ],
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.storefront_outlined, size: 18, color: AppColors.greyText),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                selected?.name ?? 'Select a business',
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.body14.copyWith(color: AppColors.blackText),
              ),
            ),
            const Icon(Icons.unfold_more, size: 18, color: AppColors.greyText),
          ],
        ),
      ),
    );
  }
}
