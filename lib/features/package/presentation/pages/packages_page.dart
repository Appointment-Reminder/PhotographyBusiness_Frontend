import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/core/Presentation/layouts/main_layout.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/business_providers.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/state/business_state.dart';
import 'package:photography_business_frontend/features/package/presentation/pages/package_detail_page.dart';
import 'package:photography_business_frontend/features/package/presentation/providers/package_providers.dart';
import 'package:photography_business_frontend/features/package/presentation/providers/state/package_state.dart';
import 'package:photography_business_frontend/features/package/presentation/widgets/package_card.dart';

class PackagesPage extends ConsumerStatefulWidget {
  const PackagesPage({super.key});

  @override
  ConsumerState<PackagesPage> createState() => _PackagesPageState();
}

class _PackagesPageState extends ConsumerState<PackagesPage> {
  int? _selectedBusinessId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(businessNotifierProvider.notifier).loadMyBusinesses();
    });
  }

  void _loadPackages() {
    if (_selectedBusinessId != null) {
      ref.read(packageNotifierProvider.notifier).loadPackagesForBusiness(_selectedBusinessId!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final packageState = ref.watch(packageNotifierProvider);
    final businessState = ref.watch(businessNotifierProvider);

    ref.listen<PackageState>(packageNotifierProvider, (previous, next) {
      if (next is PackageError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message)),
        );
      }
    });

    return MainLayout(
      title: 'Packages',
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Packages'),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _selectedBusinessId != null ? _loadPackages : null,
            ),
          ],
        ),
        body: Column(
          children: [
            if (businessState is BusinessListLoaded)
              Padding(
                padding: const EdgeInsets.all(16),
                child: DropdownButtonFormField<int>(
                  decoration: const InputDecoration(
                    labelText: 'Select Business',
                    border: OutlineInputBorder(),
                  ),
                  value: _selectedBusinessId,
                  items: businessState.businesses
                      .map((b) => DropdownMenuItem(
                            value: b.id,
                            child: Text(b.name),
                          ))
                      .toList(),
                  onChanged: (businessId) {
                    setState(() => _selectedBusinessId = businessId);
                    if (businessId != null) {
                      ref.read(packageNotifierProvider.notifier).loadPackagesForBusiness(businessId);
                    }
                  },
                ),
              ),
            Expanded(child: _buildBody(packageState)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(PackageState state) {
    if (_selectedBusinessId == null) {
      return const Center(child: Text('Select a business to view packages'));
    }

    if (state is PackageLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is PackageListLoaded) {
      if (state.packages.isEmpty) {
        return const Center(child: Text('No packages found'));
      }

      return ListView.builder(
        itemCount: state.packages.length,
        itemBuilder: (context, index) {
          final package = state.packages[index];
          return PackageCard(
            package: package,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PackageDetailPage(packageId: package.id),
                ),
              );
            },
          );
        },
      );
    }

    if (state is PackageError) {
      return Center(child: Text(state.message));
    }

    return const Center(child: Text('Select a business to view packages'));
  }
}
