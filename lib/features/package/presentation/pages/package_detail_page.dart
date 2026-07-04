import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/core/Presentation/layouts/main_layout.dart';
import 'package:photography_business_frontend/features/package/presentation/providers/package_providers.dart';
import 'package:photography_business_frontend/features/package/presentation/providers/state/refacto/package_detail_state.dart';

class PackageDetailPage extends ConsumerStatefulWidget {
  final int packageId;

  const PackageDetailPage({super.key, required this.packageId});

  @override
  ConsumerState<PackageDetailPage> createState() => _PackageDetailPageState();
}

class _PackageDetailPageState extends ConsumerState<PackageDetailPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(packageDetailNotifierProvider.notifier).load(widget.packageId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(packageDetailNotifierProvider);

    return MainLayout(
      title: 'Package Details',
      child: Scaffold(
        appBar: AppBar(title: const Text('Package Details')),
        body: _buildBody(state),
      ),
    );
  }

  Widget _buildBody(PackageDetailState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null) return Center(child: Text(state.error!));
    if (state.package == null) return const SizedBox.shrink();

    final package = state.package!;
    final currentPrice = state.currentPrice;



    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(package.name, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(package.description),
          const SizedBox(height: 16),
          Text('Status: ${package.isActive ? 'Active' : 'Inactive'}'),
          const SizedBox(height: 16),
          if (currentPrice != null) ...[
            Text('Current Price', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Text('Total: ${currentPrice.totalPrice}'),
            Text('Deposit: ${currentPrice.depositAmount}'),
            Text('Remaining: ${currentPrice.remainingAmount}'),
          ] else
            const Text('No current price set'),
        ],
      ),
    );
  }
}
