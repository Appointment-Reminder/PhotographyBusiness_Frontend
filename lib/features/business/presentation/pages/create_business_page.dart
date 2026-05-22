import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/core/Presentation/layouts/main_layout.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/business_providers.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/state/business_state.dart';

class CreateBusinessPage extends ConsumerStatefulWidget {
  const CreateBusinessPage({super.key});

  @override
  ConsumerState<CreateBusinessPage> createState() => _CreateBusinessPageState();
}

class _CreateBusinessPageState extends ConsumerState<CreateBusinessPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final businessState = ref.watch(businessNotifierProvider);

    ref.listen<BusinessState>(businessNotifierProvider, (previous, next) {
      if (next is BusinessDetailLoaded) {
        // Business created successfully
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Business created successfully!')),
        );
        Navigator.pop(context, true); // Return true to indicate success
      } else if (next is BusinessError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message)),
        );
      }
    });

    return MainLayout(
      title: 'Create Business',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create Business'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Business Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.business),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a business name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description (Optional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.description),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                if (businessState is BusinessLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  ElevatedButton(
                    onPressed: _createBusiness,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text(
                      'Create Business',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _createBusiness() {
    if (_formKey.currentState!.validate()) {
      ref.read(businessNotifierProvider.notifier).createNewBusiness(
        _nameController.text,
        _descriptionController.text.isEmpty ? null : _descriptionController.text,
      );
    }
  }
}