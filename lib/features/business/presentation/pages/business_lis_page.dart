import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/core/Presentation/layouts/main_layout.dart';
import 'package:photography_business_frontend/features/business/presentation/pages/create_business_page.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/business_providers.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/state/business_state.dart';
import 'package:photography_business_frontend/features/business/presentation/widgets/business_card.dart';

import 'business_detail_page.dart';

class BusinessesListPage extends ConsumerStatefulWidget {
  const BusinessesListPage({super.key});

  @override
  ConsumerState<BusinessesListPage> createState() => _BusinessesListPageState();
}

class _BusinessesListPageState extends ConsumerState<BusinessesListPage> {
  @override
  void initState() {
    super.initState();
    // Load businesses when page loads
    Future.microtask(() {
      ref.read(businessNotifierProvider.notifier).loadMyBusinesses();
    });
  }

  @override
  Widget build(BuildContext context) {
    final businessState = ref.watch(businessNotifierProvider);

    return MainLayout(
      title: 'My Businesses',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('My Businesses'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                ref.read(businessNotifierProvider.notifier).loadMyBusinesses();
              },
            ),
          ],
        ),
        body: _buildBody(businessState),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CreateBusinessPage()),
            );

            // Reload list if business was created
            if (result == true) {
              ref.read(businessNotifierProvider.notifier).loadMyBusinesses();
            }
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildBody(BusinessState state) {
    if (state is BusinessLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is BusinessError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              state.message,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(businessNotifierProvider.notifier).loadMyBusinesses();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (state is BusinessListLoaded) {
      if (state.businesses.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.business, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No businesses yet',
                style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              ),
              const SizedBox(height: 8),
              Text(
                'Create your first business to get started',
                style: TextStyle(color: Colors.grey[500]),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async {
          ref.read(businessNotifierProvider.notifier).loadMyBusinesses();
        },
        child: ListView.builder(
          itemCount: state.businesses.length,
          itemBuilder: (context, index) {
            final business = state.businesses[index];
            return BusinessCard(
              business: business,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BusinessDetailPage(businessId: business.id),
                  ),
                );
              },
            );
          },
        ),
      );
    }

    return const Center(child: Text('Unknown state'));
  }
}