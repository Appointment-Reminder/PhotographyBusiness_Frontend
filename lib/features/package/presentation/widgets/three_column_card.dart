import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'package:photography_business_frontend/core/presentation/theme/app_colors.dart';
import 'package:photography_business_frontend/core/presentation/theme/app_text_styles.dart';
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
  final double height;
  final bool isSubmitting;

  /// name
  final Future<void> Function(String name)? onAddCategory;
  /// categoryId, name, description
  final Future<void> Function(String categoryId, String name, String description)? onAddPackage;
  /// packageId, effectiveFrom (MM/YYYY), amount
  final Future<void> Function(String packageId, DateTime effectiveFrom, String amount)? onAddPrice;

  const ThreeColumnCard({
    super.key,
    required this.categories,
    this.height = 420,
    this.isSubmitting = false,
    this.onAddCategory,
    this.onAddPackage,
    this.onAddPrice,
  });

  @override
  State<ThreeColumnCard> createState() => _ThreeColumnCardState();
}

class _ThreeColumnCardState extends State<ThreeColumnCard> {
  String? _selectedCategoryId;
  String? _selectedPackageId;

  bool _addingCategory = false;
  final _newCatNameCtrl = TextEditingController();

  bool _addingPackage = false;
  final _newPkgNameCtrl = TextEditingController();
  final _newPkgDescCtrl = TextEditingController();

  bool _addingPrice = false;
  DateTime? _newPriceDate;
  final _newPriceAmountCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.categories.firstOrNull?.id;
    _selectedPackageId = widget.categories.firstOrNull?.packages.firstOrNull?.id;
  }

  @override
  void didUpdateWidget(covariant ThreeColumnCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Keep selection valid if the underlying lists changed (e.g. after a create).
    if (_selectedCategoryId == null ||
        widget.categories.none((c) => c.id == _selectedCategoryId)) {
      _selectedCategoryId = widget.categories.firstOrNull?.id;
      _selectedPackageId = _selectedCategory?.packages.firstOrNull?.id;
    } else if (_selectedPackageId == null ||
        (_selectedCategory?.packages.none((p) => p.id == _selectedPackageId) ?? true)) {
      _selectedPackageId = _selectedCategory?.packages.firstOrNull?.id;
    }
  }

  @override
  void dispose() {
    _newCatNameCtrl.dispose();
    _newPkgNameCtrl.dispose();
    _newPkgDescCtrl.dispose();
    _newPriceAmountCtrl.dispose();
    super.dispose();
  }

  CategoryEntry? get _selectedCategory =>
      widget.categories.firstWhereOrNull((c) => c.id == _selectedCategoryId);

  PackageEntry? get _selectedPackage =>
      _selectedCategory?.packages.firstWhereOrNull((p) => p.id == _selectedPackageId);

  void _selectCategory(String categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
      _selectedPackageId = widget.categories
          .firstWhereOrNull((c) => c.id == categoryId)
          ?.packages
          .firstOrNull
          ?.id;
      _addingPackage = false;
      _addingPrice = false;
    });
  }

  Future<void> _submitCategory() async {
    final name = _newCatNameCtrl.text.trim();
    if (name.isEmpty || widget.onAddCategory == null) return;
    await widget.onAddCategory!(name);
    _newCatNameCtrl.clear();
    setState(() => _addingCategory = false);
  }

  Future<void> _submitPackage() async {
    final name = _newPkgNameCtrl.text.trim();
    final categoryId = _selectedCategoryId;
    if (name.isEmpty || categoryId == null || widget.onAddPackage == null) return;
    await widget.onAddPackage!(categoryId, name, _newPkgDescCtrl.text.trim());
    _newPkgNameCtrl.clear();
    _newPkgDescCtrl.clear();
    setState(() => _addingPackage = false);
  }

  // _submitPrice becomes:
  Future<void> _submitPrice() async {
    final amount = _newPriceAmountCtrl.text.trim();
    final packageId = _selectedPackageId;
    if (_newPriceDate == null || amount.isEmpty || packageId == null || widget.onAddPrice == null) return;
    await widget.onAddPrice!(packageId, _newPriceDate!, amount);
    _newPriceDate = null;
    _newPriceAmountCtrl.clear();
    setState(() => _addingPrice = false);
  }

  @override
  Widget build(BuildContext context) {
    final selectedCategory = _selectedCategory;
    final selectedPackage = _selectedPackage;

    return Container(
      height: widget.height,
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
              width: 220,
              child: _Column(
                header: 'Category',
                onAdd: widget.onAddCategory == null ? null : () => setState(() => _addingCategory = !_addingCategory),
                itemCount: widget.categories.length,
                itemBuilder: (context, i) {
                  final cat = widget.categories[i];
                  return CategoryRow(
                    name: cat.name,
                    isSelected: cat.id == _selectedCategoryId,
                    onTap: () => _selectCategory(cat.id),
                  );
                },
                emptyLabel: widget.categories.isEmpty ? 'No categories yet' : null,
                footer: _addingCategory
                    ? _InlineCreateForm(
                  fields: [
                    _InlineField(label: 'Category name', controller: _newCatNameCtrl, autofocus: true),
                  ],
                  isSubmitting: widget.isSubmitting,
                  onSubmit: _submitCategory,
                  onCancel: () => setState(() {
                    _addingCategory = false;
                    _newCatNameCtrl.clear();
                  }),
                )
                    : null,
              ),
            ),

            const _VerticalDivider(),

            // Col 2 — Packages
            Expanded(
              child: _Column(
                header: 'Package',
                onAdd: (widget.onAddPackage == null || selectedCategory == null)
                    ? null
                    : () => setState(() => _addingPackage = !_addingPackage),
                itemCount: selectedCategory?.packages.length ?? 0,
                itemBuilder: (context, i) {
                  final pkg = selectedCategory!.packages[i];
                  return PackageRow(
                    name: pkg.name,
                    description: pkg.description,
                    currentPrice: pkg.currentPrice,
                    isSelected: pkg.id == _selectedPackageId,
                    onTap: () => setState(() {
                      _selectedPackageId = pkg.id;
                      _addingPrice = false;
                    }),
                  );
                },
                emptyLabel: (selectedCategory?.packages.isEmpty ?? true) ? 'No packages yet' : null,
                footer: _addingPackage
                    ? _InlineCreateForm(
                  fields: [
                    _InlineField(label: 'Package name', controller: _newPkgNameCtrl, autofocus: true),
                    _InlineField(label: 'Description', controller: _newPkgDescCtrl),
                  ],
                  isSubmitting: widget.isSubmitting,
                  onSubmit: _submitPackage,
                  onCancel: () => setState(() {
                    _addingPackage = false;
                    _newPkgNameCtrl.clear();
                    _newPkgDescCtrl.clear();
                  }),
                )
                    : null,
              ),
            ),

            const _VerticalDivider(),

            // Col 3 — Price history
            Expanded(
              child: _Column(
                header: 'Pricing',
                onAdd: (widget.onAddPrice == null || selectedPackage == null)
                    ? null
                    : () => setState(() => _addingPrice = !_addingPrice),
                itemCount: selectedPackage?.prices.length ?? 0,
                itemBuilder: (context, i) {
                  final price = selectedPackage!.prices[i];
                  return PriceHistoryRow(
                    from: price.from,
                    to: price.to,
                    amount: price.amount,
                    currency: price.currency,
                    isCurrent: price.isCurrent,
                  );
                },
                emptyLabel: (selectedPackage?.prices.isEmpty ?? true) ? 'No prices yet' : null,
                footer: _addingPrice
                    ? _InlineCreateForm(
                  fields: [
                    _DatePickerField(
                      label: 'Effective from',
                      value: _newPriceDate,
                      onPick: (d) => setState(() => _newPriceDate = d),
                    ),
                    _InlineField(label: 'Price (EUR)', controller: _newPriceAmountCtrl, keyboardType: TextInputType.number),
                  ],
                  isSubmitting: widget.isSubmitting,
                  onSubmit: _submitPrice,
                  onCancel: () => setState(() {
                    _addingPrice = false;
                    _newPriceDate = null;
                    _newPriceAmountCtrl.clear();
                  }),
                )
                    : null,
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
  final VoidCallback? onAdd;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final String? emptyLabel;
  final Widget? footer;

  const _Column({
    required this.header,
    required this.itemCount,
    required this.itemBuilder,
    this.onAdd,
    this.emptyLabel,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ColumnHeader(header, onAdd: onAdd),
        Expanded(
          child: itemCount == 0 && emptyLabel != null
              ? Center(child: Text(emptyLabel!, style: AppTextStyles.muted12))
              : ListView.builder(itemCount: itemCount, itemBuilder: itemBuilder),
        ),
        if (footer != null) footer!,
      ],
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return const VerticalDivider(width: 1, thickness: 1, color: AppColors.border);
  }
}

class _InlineCreateForm extends StatelessWidget {
  final List<Widget> fields;
  final bool isSubmitting;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  const _InlineCreateForm({
    required this.fields,
    required this.isSubmitting,
    required this.onSubmit,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: const BoxDecoration(
        color: AppColors.sidebarBg,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ...fields,
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: isSubmitting ? null : onSubmit,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryText.withOpacity(isSubmitting ? 0.5 : 1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        isSubmitting ? 'Saving…' : 'Add',
                        style: AppTextStyles.mono12.copyWith(color: AppColors.active, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onCancel,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.close, size: 14, color: AppColors.mutedText),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime? value;
  final ValueChanged<DateTime> onPick;

  const _DatePickerField({required this.label, required this.value, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: AppTextStyles.monoMuted10.copyWith(letterSpacing: 1.2)),
        const SizedBox(height: 4),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: value ?? DateTime.now(),
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
            );
            if (picked != null) onPick(picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.active,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today, size: 12, color: AppColors.mutedText),
                const SizedBox(width: 8),
                Text(
                  value == null
                      ? 'Select date'
                      : '${value!.day.toString().padLeft(2, '0')}/${value!.month.toString().padLeft(2, '0')}/${value!.year}',
                  style: AppTextStyles.mono12,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _InlineField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool autofocus;
  final TextInputType keyboardType;

  const _InlineField({
    required this.label,
    required this.controller,
    this.autofocus = false,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label.toUpperCase(), style: AppTextStyles.monoMuted10.copyWith(letterSpacing: 1.2)),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          autofocus: autofocus,
          keyboardType: keyboardType,
          style: AppTextStyles.mono12,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            filled: true,
            fillColor: AppColors.active,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: AppColors.primaryText, width: 1.5),
            ),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}