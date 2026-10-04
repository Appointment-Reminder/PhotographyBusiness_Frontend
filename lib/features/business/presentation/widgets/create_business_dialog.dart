import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/business_params.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/business_providers.dart';

/// Asks for a name/description, creates the Business and reloads the list.
Future<void> showCreateBusinessDialog(BuildContext context, WidgetRef ref) async {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  try {
    final created = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        bool isSubmitting = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Create Business'),
              content: Form(
                key: formKey,
                child: SizedBox(
                  width: 450,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: nameController,
                        autofocus: true,
                        decoration: const InputDecoration(
                          labelText: 'Business name',
                          hintText: 'Enter business name',
                        ),
                        validator: (value) => value == null || value.trim().isEmpty
                            ? 'Business name is required'
                            : null,
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'Optional description',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: isSubmitting ? null : () => Navigator.of(dialogContext).pop(false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          if (!formKey.currentState!.validate()) return;
                          setState(() => isSubmitting = true);
                          try {
                            await ref.read(businessFormNotifierProvider.notifier).createBusiness(
                                  CreateBusinessParams(
                                    name: nameController.text.trim(),
                                    description: descriptionController.text.trim().isEmpty
                                        ? null
                                        : descriptionController.text.trim(),
                                  ),
                                );
                            if (dialogContext.mounted) Navigator.of(dialogContext).pop(true);
                          } catch (e) {
                            if (dialogContext.mounted) {
                              setState(() => isSubmitting = false);
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                SnackBar(content: Text('Failed to create business: $e')),
                              );
                            }
                          }
                        },
                  child: isSubmitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );

    if (created == true) {
      await ref
          .read(businessListNotifierProvider.notifier)
          .getMyBusinesses(GetMyBusinessesParams(isActive: true));
    }
  } finally {
    nameController.dispose();
    descriptionController.dispose();
  }
}
