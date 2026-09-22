import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/Presentation/theme/app_text_styles.dart';
import '../providers/package_providers.dart';
import '../providers/notifiers/packages_pricing_map_notifier.dart';
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

  Future<void> _handleAddCategory(String name) =>
      ref.read(packagesPricingMapProvider.notifier).addCategory(name);

  Future<void> _handleAddPackage(String categoryId, String name, String description) =>
      ref.read(packagesPricingMapProvider.notifier).addPackage(
        categoryId: int.parse(categoryId),
        name: name,
        description: description,
      );

  Future<void> _handleAddPrice(String packageId, DateTime effectiveFrom, String amount) {
    final total = int.tryParse(amount) ?? 0;
    return ref.read(packagesPricingMapProvider.notifier).addPrice(
      packageId: int.parse(packageId),
      totalPrice: total,
      depositAmount: 0,
      remainingAmount: total,
      isPersonal: false,
      effectiveFrom: effectiveFrom,
    );
  }

  Future<void> _handleEditPackage(
      PackagesPricingMapState s, String packageId, String name, String description, String? jotformAlias) {
    final pkg = s.packagesByCategory.values
        .expand((l) => l)
        .firstWhere((p) => p.id.toString() == packageId);
    return ref.read(packagesPricingMapProvider.notifier).editPackage(
      id: pkg.id,
      categoryId: pkg.categoryId,
      name: name,
      description: description,
      jotformAlias: jotformAlias,
    );
  }

  Future<void> _handleDeletePackage(String packageId) =>
      ref.read(packagesPricingMapProvider.notifier).removePackage(int.parse(packageId));

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(packagesPricingMapProvider);

    if (s.isLoading && s.categories.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (s.error != null) return Center(child: Text(s.error!));

    return Padding(
      padding: const EdgeInsets.all(50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PHOTOGRAPHY STUDIO', style: AppTextStyles.monoMuted10.copyWith(letterSpacing: 2.8)),
          const SizedBox(height: 8),
          Text('Packages & Pricing', style: AppTextStyles.heading24),
          const SizedBox(height: 32),
          Expanded(
            child: ThreeColumnCard(
              categories: _toCategoryEntries(s),
              isSubmitting: s.isSubmitting,
              onAddCategory: _handleAddCategory,
              onAddPackage: _handleAddPackage,
              onAddPrice: _handleAddPrice,
              onEditPackage: (packageId, name, description, jotformAlias) =>
                  _handleEditPackage(s, packageId, name, description, jotformAlias),
              onDeletePackage: _handleDeletePackage,
            ),
          ),
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
            jotformAlias: pkg.jotformAlias,
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

  String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}