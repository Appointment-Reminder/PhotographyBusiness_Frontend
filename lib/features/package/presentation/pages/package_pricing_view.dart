import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/features/package/presentation/providers/notifiers/packages_pricing_map_notifier.dart';

import '../../../../core/Presentation/theme/app_text_styles.dart';
import '../providers/package_providers.dart';
import '../widgets/three_column_card.dart';

class PackagesPricingView extends ConsumerStatefulWidget {
  final int businessId;
  const PackagesPricingView({super.key, required this.businessId});
  @override
  ConsumerState<PackagesPricingView> createState() => _PackagesPricingViewState();
}

class _PackagesPricingViewState extends ConsumerState<PackagesPricingView> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        ref.read(packagesPricingMapProvider.notifier).loadForBusiness(widget.businessId));
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(packagesPricingMapProvider);
    if (s.isLoading && s.categories.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (s.error != null) return Center(child: Text(s.error!));
    if (s.categories.isEmpty) return const Center(child: Text('No packages yet'));
    return Padding(
      padding: const EdgeInsets.all(50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Page header
          Text('PHOTOGRAPHY STUDIO', style: AppTextStyles.monoMuted10.copyWith(letterSpacing: 2.8)),
          const SizedBox(height: 8),
          Text('Packages & Pricing', style: AppTextStyles.heading24),
          const SizedBox(height: 32),

          // Cards
          ThreeColumnCard(categories: _toCategoryEntries(s)),
        ],
      ),
    );
  }

  List<CategoryEntry> _toCategoryEntries(PackagesPricingMapState s) {
    return s.categories.map((cat) {
      final pkgs = s.packagesByCategory[cat.id] ?? [];
      return CategoryEntry(
        id: cat.id.toString(),
        name: cat.name,
        packages: pkgs.map((pkg) {
          final prices = [...(s.pricesByPackage[pkg.id] ?? [])]
            ..sort((a, b) => a.effectiveFrom.compareTo(b.effectiveFrom));
          return PackageEntry(
            id: pkg.id.toString(),
            name: pkg.name,
            description: pkg.description,
            prices: [
              for (var i = 0; i < prices.length; i++)
                PriceEntry(
                  amount: prices[i].totalPrice.toString(),
                  currency: 'EUR',
                  from: _fmt(prices[i].effectiveFrom),
                  to: i == prices.length - 1 ? null : _fmt(prices[i + 1].effectiveFrom),
                  isCurrent: i == prices.length - 1,
                ),
            ],
          );
        }).toList(),
      );
    }).toList();
  }

  String _fmt(DateTime d) => '${d.month.toString().padLeft(2, '0')}/${d.year}';
}