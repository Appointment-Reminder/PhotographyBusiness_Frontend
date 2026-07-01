import 'package:flutter/material.dart';

import 'package:photography_business_frontend/core/presentation/theme/app_colors.dart';
import 'package:photography_business_frontend/features/package/presentation/widgets/PackageAndPricingWidgets/molecule/category_row.dart';
import 'package:photography_business_frontend/features/package/presentation/widgets/PackageAndPricingWidgets/molecule/column_header.dart';
import 'package:photography_business_frontend/features/package/presentation/widgets/PackageAndPricingWidgets/molecule/package_row.dart';
import 'package:photography_business_frontend/features/package/presentation/widgets/PackageAndPricingWidgets/molecule/price_history_row.dart';


// ─── Data models (local to this widget, no domain dependency) ────────────────

class PriceEntry {
  final String amount;
  final String currency;
  final String from;
  final String? to;
  final bool isCurrent;

  const PriceEntry({
    required this.amount,
    required this.currency,
    required this.from,
    required this.to,
    required this.isCurrent,
  });
}

class PackageEntry {
  final String id;
  final String name;
  final String description;
  final List<PriceEntry> prices;

  const PackageEntry({
    required this.id,
    required this.name,
    required this.description,
    required this.prices,
  });

  String? get currentPrice {
    final current = prices.where((p) => p.isCurrent).firstOrNull;
    if (current == null) return null;
    return '${current.amount} ${current.currency}';
  }
}

class CategoryEntry {
  final String id;
  final String name;
  final List<PackageEntry> packages;

  const CategoryEntry({
    required this.id,
    required this.name,
    required this.packages,
  });
}

// ─── Widget ──────────────────────────────────────────────────────────────────

class ThreeColumnCard extends StatefulWidget {
  final List<CategoryEntry> categories;

  const ThreeColumnCard({
    super.key,
    required this.categories,
  });

  @override
  State<ThreeColumnCard> createState() => _ThreeColumnCardState();
}

class _ThreeColumnCardState extends State<ThreeColumnCard> {
  late String _selectedCategoryId;
  late String _selectedPackageId;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.categories.first.id;
    _selectedPackageId  = widget.categories.first.packages.first.id;
  }

  CategoryEntry get _selectedCategory =>
      widget.categories.firstWhere((c) => c.id == _selectedCategoryId);

  PackageEntry get _selectedPackage =>
      _selectedCategory.packages.firstWhere((p) => p.id == _selectedPackageId);

  void _selectCategory(String categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
      _selectedPackageId  =
          widget.categories.firstWhere((c) => c.id == categoryId).packages.first.id;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.active,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      clipBehavior: Clip.hardEdge,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Col 1 — Categories
            SizedBox(
              width: 200,
              child: _Column(
                header: 'Category',
                children: widget.categories.map((cat) => CategoryRow(
                  name: cat.name,
                  isSelected: cat.id == _selectedCategoryId,
                  onTap: () => _selectCategory(cat.id),
                )).toList(),
              ),
            ),

            const _VerticalDivider(),

            // Col 2 — Packages
            Expanded(
              child: _Column(
                header: 'Package',
                children: _selectedCategory.packages.map((pkg) => PackageRow(
                  name: pkg.name,
                  description: pkg.description,
                  currentPrice: pkg.currentPrice,
                  isSelected: pkg.id == _selectedPackageId,
                  onTap: () => setState(() => _selectedPackageId = pkg.id),
                )).toList(),
              ),
            ),

            const _VerticalDivider(),

            // Col 3 — Price history
            Expanded(
              child: _Column(
                header: 'Pricing',
                children: _selectedPackage.prices.map((price) => PriceHistoryRow(
                  from: price.from,
                  to: price.to,
                  amount: price.amount,
                  currency: price.currency,
                  isCurrent: price.isCurrent,
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Internal helpers ─────────────────────────────────────────────────────────

class _Column extends StatelessWidget {
  final String header;
  final List<Widget> children;

  const _Column({required this.header, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ColumnHeader(header),
        ...children,
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return const VerticalDivider(
      width: 1,
      thickness: 1,
      color: AppColors.border,
    );
  }
}