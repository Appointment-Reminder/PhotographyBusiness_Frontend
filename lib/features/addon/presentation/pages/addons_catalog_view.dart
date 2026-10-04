import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_colors.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_text_styles.dart';
import 'package:photography_business_frontend/core/Presentation/widgets/current_badge.dart';
import 'package:photography_business_frontend/core/Presentation/widgets/section_label.dart';
import '../../domain/entities/addon.dart';
import '../providers/addon_providers.dart';
import '../providers/state/addon_catalog_state.dart';

/// Catalog > Add-ons: the Add-on list on the left, the selected Add-on (or the
/// create form) with its Add-on Price history on the right.
class AddonsCatalogView extends ConsumerStatefulWidget {
  final int businessId;
  const AddonsCatalogView({super.key, required this.businessId});

  @override
  ConsumerState<AddonsCatalogView> createState() => _AddonsCatalogViewState();
}

class _AddonsCatalogViewState extends ConsumerState<AddonsCatalogView> {
  bool _creating = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(addonCatalogProvider.notifier).load(widget.businessId));
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(addonCatalogProvider);

    if (s.isLoading && s.addons.isEmpty) return const Center(child: CircularProgressIndicator());
    if (s.error != null && s.addons.isEmpty && !s.hasPendingPrice) {
      return Center(child: Text(s.error!));
    }

    return Padding(
      padding: const EdgeInsets.all(50),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PHOTOGRAPHY STUDIO', style: AppTextStyles.monoMuted10.copyWith(letterSpacing: 2.8)),
          const SizedBox(height: 8),
          Text('Add-ons & Pricing', style: AppTextStyles.heading24),
          const SizedBox(height: 32),
          if (s.error != null) ...[
            _ErrorBanner(
              message: s.error!,
              onRetry: s.hasPendingPrice
                  ? () => ref.read(addonCatalogProvider.notifier).retryPrice()
                  : null,
            ),
            const SizedBox(height: 12),
          ],
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  width: 340,
                  child: _AddonList(
                    state: s,
                    onSelect: (id) {
                      setState(() => _creating = false);
                      ref.read(addonCatalogProvider.notifier).select(id);
                    },
                    onAdd: () => setState(() => _creating = true),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _creating
                      ? _CreateAddonPanel(
                          businessId: widget.businessId,
                          onCancel: () => setState(() => _creating = false),
                          onCreated: () => setState(() => _creating = false),
                        )
                      : (s.selected == null
                          ? const _EmptyPanel()
                          : _AddonDetailPanel(key: ValueKey(s.selected!.id), state: s, addon: s.selected!)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const _ErrorBanner({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: Row(children: [
        const Icon(Icons.error_outline, size: 16, color: Colors.red),
        const SizedBox(width: 8),
        Expanded(child: Text(message, style: AppTextStyles.body14)),
        if (onRetry != null) TextButton(onPressed: onRetry, child: const Text('Retry price')),
      ]),
    );
  }
}

BoxDecoration _cardDecoration() => BoxDecoration(
      color: AppColors.active,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.border),
    );

class _AddonList extends StatelessWidget {
  final AddonCatalogState state;
  final ValueChanged<int> onSelect;
  final VoidCallback onAdd;
  const _AddonList({required this.state, required this.onSelect, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: _cardDecoration(),
      clipBehavior: Clip.hardEdge,
      child: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
          child: Row(children: [
            const Expanded(child: SectionLabel('Add-ons')),
            IconButton(
              tooltip: 'New add-on',
              onPressed: onAdd,
              icon: const Icon(Icons.add, size: 18),
            ),
          ]),
        ),
        Expanded(
          child: state.addons.isEmpty
              ? Center(child: Text('No add-ons yet', style: AppTextStyles.muted12))
              : ListView(children: [
                  for (final a in state.addons)
                    _AddonRow(
                      addon: a,
                      price: state.currentPrices[a.id],
                      selected: a.id == state.selectedId,
                      onTap: () => onSelect(a.id),
                    ),
                ]),
        ),
      ]),
    );
  }
}

class _AddonRow extends StatelessWidget {
  final Addon addon;
  final int? price;
  final bool selected;
  final VoidCallback onTap;
  const _AddonRow({required this.addon, required this.price, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final inactive = !addon.isActive;
    final textColor = inactive ? AppColors.mutedText : AppColors.primaryText;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryText.withOpacity(0.05) : Colors.transparent,
          border: const Border(bottom: BorderSide(color: AppColors.border)),
        ),
        child: Row(children: [
          Expanded(
            child: Text(addon.name,
                style: AppTextStyles.body14.copyWith(color: textColor, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis),
          ),
          Text(price == null ? 'no price' : '$price EUR',
              style: AppTextStyles.mono12.copyWith(color: price == null ? AppColors.mutedText : textColor)),
          const SizedBox(width: 10),
          _ActiveBadge(active: addon.isActive),
        ]),
      ),
    );
  }
}

class _ActiveBadge extends StatelessWidget {
  final bool active;
  const _ActiveBadge({required this.active});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: active ? Colors.green.withOpacity(0.12) : AppColors.sidebarBg,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(active ? 'active' : 'inactive',
          style: AppTextStyles.mono10.copyWith(color: active ? Colors.green.shade800 : AppColors.mutedText)),
    );
  }
}

class _EmptyPanel extends StatelessWidget {
  const _EmptyPanel();

  @override
  Widget build(BuildContext context) => Container(
        decoration: _cardDecoration(),
        child: Center(child: Text('Select an add-on, or press + to create one', style: AppTextStyles.muted12)),
      );
}

/// Name, alias, duration and quantity fields shared by create and edit.
class _AddonFields {
  final TextEditingController name;
  final TextEditingController alias;
  final TextEditingController minutes;
  bool hasDuration;
  bool hasQuantity;

  _AddonFields([Addon? a])
      : name = TextEditingController(text: a?.name ?? ''),
        alias = TextEditingController(text: a?.jotformAlias ?? ''),
        minutes = TextEditingController(text: a?.durationMinutes?.toString() ?? ''),
        hasDuration = a?.hasDuration ?? false,
        hasQuantity = a?.hasQuantity ?? false;

  void dispose() {
    name.dispose();
    alias.dispose();
    minutes.dispose();
  }

  int? get durationMinutes => hasDuration ? int.tryParse(minutes.text.trim()) : null;

  /// Null when valid, else the message to show.
  String? validate() {
    if (name.text.trim().isEmpty) return 'Name is required';
    if (alias.text.trim().isEmpty) return 'Jotform alias is required';
    if (hasDuration && (durationMinutes == null || durationMinutes! <= 0)) {
      return 'Enter the duration in minutes';
    }
    return null;
  }
}

InputDecoration _decoration(String label) => InputDecoration(
      labelText: label,
      isDense: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
    );

class _FieldsForm extends StatelessWidget {
  final _AddonFields f;
  final VoidCallback onChanged;
  const _FieldsForm({required this.f, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      TextField(controller: f.name, decoration: _decoration('Name')),
      const SizedBox(height: 12),
      TextField(controller: f.alias, decoration: _decoration('Jotform alias')),
      const SizedBox(height: 8),
      Row(children: [
        Switch(
          value: f.hasDuration,
          onChanged: (v) {
            f.hasDuration = v;
            onChanged();
          },
        ),
        const Text('Has a duration'),
        const SizedBox(width: 16),
        SizedBox(
          width: 120,
          child: TextField(
            controller: f.minutes,
            enabled: f.hasDuration,
            keyboardType: TextInputType.number,
            decoration: _decoration('Minutes'),
          ),
        ),
      ]),
      Row(children: [
        Switch(
          value: f.hasQuantity,
          onChanged: (v) {
            f.hasQuantity = v;
            onChanged();
          },
        ),
        const Text('Has a quantity'),
      ]),
    ]);
  }
}

Future<DateTime?> _pickDate(BuildContext context, DateTime initial) async {
  final d = await showDatePicker(
    context: context,
    initialDate: initial,
    firstDate: DateTime(2000),
    lastDate: DateTime(2100),
  );
  return d == null ? null : DateTime(d.year, d.month, d.day);
}

DateTime _today() {
  final n = DateTime.now();
  return DateTime(n.year, n.month, n.day);
}

class _CreateAddonPanel extends ConsumerStatefulWidget {
  final int businessId;
  final VoidCallback onCancel;
  final VoidCallback onCreated;
  const _CreateAddonPanel({required this.businessId, required this.onCancel, required this.onCreated});

  @override
  ConsumerState<_CreateAddonPanel> createState() => _CreateAddonPanelState();
}

class _CreateAddonPanelState extends ConsumerState<_CreateAddonPanel> {
  final _fields = _AddonFields();
  final _price = TextEditingController();
  DateTime _from = _today();
  String? _error;

  @override
  void dispose() {
    _fields.dispose();
    _price.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final price = int.tryParse(_price.text.trim());
    final error = _fields.validate() ?? (price == null || price < 0 ? 'Enter the first price in euros' : null);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    setState(() => _error = null);
    await ref.read(addonCatalogProvider.notifier).create(
          businessId: widget.businessId,
          name: _fields.name.text.trim(),
          jotformAlias: _fields.alias.text.trim(),
          hasDuration: _fields.hasDuration,
          durationMinutes: _fields.durationMinutes,
          hasQuantity: _fields.hasQuantity,
          price: price!,
          effectiveFrom: _from,
        );
    // The Add-on exists even if its price failed; leave the form so the
    // banner above can retry the price.
    if (mounted) widget.onCreated();
  }

  @override
  Widget build(BuildContext context) {
    final submitting = ref.watch(addonCatalogProvider).isSubmitting;
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const SectionLabel('New add-on'),
          const SizedBox(height: 16),
          _FieldsForm(f: _fields, onChanged: () => setState(() {})),
          const SizedBox(height: 12),
          const SectionLabel('First price'),
          const SizedBox(height: 8),
          Row(children: [
            SizedBox(
              width: 140,
              child: TextField(
                controller: _price,
                keyboardType: TextInputType.number,
                decoration: _decoration('Price (EUR)'),
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.calendar_today, size: 14),
              label: Text('From ${DateFormat('dd/MM/yyyy').format(_from)}'),
              onPressed: () async {
                final d = await _pickDate(context, _from);
                if (d != null) setState(() => _from = d);
              },
            ),
          ]),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: AppTextStyles.body14.copyWith(color: Colors.red)),
          ],
          const SizedBox(height: 16),
          Row(children: [
            FilledButton(onPressed: submitting ? null : _submit, child: const Text('Create')),
            const SizedBox(width: 8),
            TextButton(onPressed: widget.onCancel, child: const Text('Cancel')),
          ]),
        ]),
      ),
    );
  }
}

class _AddonDetailPanel extends ConsumerStatefulWidget {
  final AddonCatalogState state;
  final Addon addon;
  const _AddonDetailPanel({super.key, required this.state, required this.addon});

  @override
  ConsumerState<_AddonDetailPanel> createState() => _AddonDetailPanelState();
}

class _AddonDetailPanelState extends ConsumerState<_AddonDetailPanel> {
  late _AddonFields _fields;
  final _newPrice = TextEditingController();
  DateTime _newFrom = _today();
  bool _addingPrice = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fields = _AddonFields(widget.addon);
  }

  @override
  void dispose() {
    _fields.dispose();
    _newPrice.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final error = _fields.validate();
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    setState(() => _error = null);
    final ok = await ref.read(addonCatalogProvider.notifier).update(
          addonId: widget.addon.id,
          name: _fields.name.text.trim(),
          jotformAlias: _fields.alias.text.trim(),
          hasDuration: _fields.hasDuration,
          durationMinutes: _fields.durationMinutes,
          hasQuantity: _fields.hasQuantity,
        );
    if (!ok && mounted) {
      // Keep the previous values on failure.
      setState(() {
        _fields.dispose();
        _fields = _AddonFields(widget.addon);
      });
    }
  }

  Future<void> _addPrice() async {
    final price = int.tryParse(_newPrice.text.trim());
    if (price == null || price < 0) {
      setState(() => _error = 'Enter the price in euros');
      return;
    }
    setState(() => _error = null);
    final ok = await ref
        .read(addonCatalogProvider.notifier)
        .addPrice(addonId: widget.addon.id, price: price, effectiveFrom: _newFrom);
    if (ok && mounted) {
      setState(() {
        _addingPrice = false;
        _newPrice.clear();
        _newFrom = _today();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.addon;
    final s = widget.state;
    final df = DateFormat('dd/MM/yyyy');
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(a.name, style: AppTextStyles.heading18)),
            _ActiveBadge(active: a.isActive),
          ]),
          const SizedBox(height: 16),
          _FieldsForm(f: _fields, onChanged: () => setState(() {})),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: AppTextStyles.body14.copyWith(color: Colors.red)),
          ],
          const SizedBox(height: 12),
          // No delete: Add-ons are deactivated, never deleted.
          Row(children: [
            FilledButton(onPressed: s.isSubmitting ? null : _save, child: const Text('Save')),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: s.isSubmitting
                  ? null
                  : () => ref.read(addonCatalogProvider.notifier).setActive(a.id, !a.isActive),
              child: Text(a.isActive ? 'Deactivate' : 'Reactivate'),
            ),
          ]),
          const SizedBox(height: 24),
          Row(children: [
            const Expanded(child: SectionLabel('Price history')),
            IconButton(
              tooltip: 'New price',
              onPressed: () => setState(() => _addingPrice = !_addingPrice),
              icon: const Icon(Icons.add, size: 18),
            ),
          ]),
          if (_addingPrice)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(children: [
                SizedBox(
                  width: 140,
                  child: TextField(
                    controller: _newPrice,
                    keyboardType: TextInputType.number,
                    decoration: _decoration('Price (EUR)'),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.calendar_today, size: 14),
                  label: Text('From ${df.format(_newFrom)}'),
                  onPressed: () async {
                    final d = await _pickDate(context, _newFrom);
                    if (d != null) setState(() => _newFrom = d);
                  },
                ),
                const SizedBox(width: 12),
                FilledButton(onPressed: s.isSubmitting ? null : _addPrice, child: const Text('Add')),
              ]),
            ),
          if (s.history.isEmpty)
            Text('No price yet', style: AppTextStyles.muted12)
          else
            for (final p in s.history)
              Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
                child: Row(children: [
                  Expanded(child: Text('from ${df.format(p.effectiveFrom)}', style: AppTextStyles.mono12)),
                  if (p.id == s.currentHistoryPriceId) ...[const CurrentBadge(), const SizedBox(width: 10)],
                  Text('${p.price} EUR', style: AppTextStyles.mono12.copyWith(fontWeight: FontWeight.w500)),
                ]),
              ),
        ]),
      ),
    );
  }
}
