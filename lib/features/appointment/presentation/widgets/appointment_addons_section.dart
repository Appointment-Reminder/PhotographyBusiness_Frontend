import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_colors.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_text_styles.dart';
import 'package:photography_business_frontend/core/utils/money_format.dart';
import 'package:photography_business_frontend/features/addon/domain/entities/addon.dart';
import 'package:photography_business_frontend/features/addon/presentation/providers/addon_providers.dart';
import '../../domain/addons/appointment_addon_editing.dart';
import '../../domain/entities/appointment.dart';
import '../providers/appointment_addon_providers.dart';
import '../providers/appointment_providers.dart';

/// The Add-ons part of an Appointment's expanded row: its Add-ons with the
/// Add-on total on its own line, Unresolved Add-ons as warning chips, and (for
/// owner and admin, while the Appointment is open) the editor and Resolve.
class AppointmentAddonsSection extends ConsumerStatefulWidget {
  final Appointment appointment;
  final int businessId;

  const AppointmentAddonsSection({super.key, required this.appointment, required this.businessId});

  @override
  ConsumerState<AppointmentAddonsSection> createState() => _AppointmentAddonsSectionState();
}

class _AppointmentAddonsSectionState extends ConsumerState<AppointmentAddonsSection> {
  AddonDraft? _draft; // non-null while the editor is open
  bool _saving = false;

  Appointment get _a => widget.appointment;

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _save() async {
    final draft = _draft;
    if (draft == null) return;
    setState(() => _saving = true);
    final error = await ref.read(appointmentListNotifierProvider(widget.businessId).notifier).setAddons(
          businessId: widget.businessId,
          appointmentId: _a.id,
          desired: draft.quantities,
        );
    if (!mounted) return;
    setState(() {
      _saving = false;
      if (error == null) _draft = null;
    });
    if (error != null) _snack(error);
  }

  Future<void> _resolve(int unresolvedId, List<AddonChoice> choices) async {
    final picked = await showDialog<({Addon addon, int quantity})>(
      context: context,
      builder: (_) => _ResolveDialog(choices: choices, prices: ref.read(addonCatalogProvider).currentPrices),
    );
    if (picked == null) return;
    final error = await ref.read(appointmentListNotifierProvider(widget.businessId).notifier).resolveAddon(
          businessId: widget.businessId,
          appointmentId: _a.id,
          unresolvedId: unresolvedId,
          addonId: picked.addon.id,
          quantity: picked.quantity,
        );
    if (error != null) _snack(error);
  }

  @override
  Widget build(BuildContext context) {
    final names = ref.watch(addonNamesProvider);
    final catalog = ref.watch(addonCatalogProvider);
    final isManager = ref.watch(isBusinessManagerProvider(widget.businessId));
    final canEdit = AppointmentAddonEditing.canEdit(isManager: isManager, status: _a.status);

    if (_a.addons.isEmpty && _a.unresolvedAddons.isEmpty && !canEdit) return const SizedBox.shrink();

    final choices = AddonChoice.build(catalog.addons, _a.addons);
    final draft = _draft;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text('ADD-ONS', style: AppTextStyles.muted12),
          const SizedBox(width: 12),
          Text('${_a.addons.length} selected · ${formatAmount(_a.addonTotal)} EUR',
              style: AppTextStyles.monoMuted11),
          const Spacer(),
          if (canEdit && draft == null)
            TextButton.icon(
              onPressed: () => setState(() => _draft = AddonDraft.from(_a.addons)),
              icon: const Icon(Icons.edit_outlined, size: 14),
              label: const Text('Edit add-ons'),
            ),
        ]),
        const SizedBox(height: 8),
        if (draft != null)
          _Editor(
            choices: choices,
            prices: catalog.currentPrices,
            draft: draft,
            saving: _saving,
            onChanged: (d) => setState(() => _draft = d),
            onSave: _save,
            onCancel: () => setState(() => _draft = null),
          )
        else ...[
          for (final line in _a.addons)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(children: [
                Expanded(child: Text(line.label(names), style: AppTextStyles.mono)),
                Text('x${line.quantity}', style: AppTextStyles.monoMuted11),
                SizedBox(
                  width: 90,
                  child: Text('${formatAmount(line.priceTotal)} EUR',
                      textAlign: TextAlign.right, style: AppTextStyles.mono),
                ),
              ]),
            ),
          if (_a.addons.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(children: [
                Expanded(child: Text('Add-on total', style: AppTextStyles.monoMuted11)),
                SizedBox(
                  width: 90,
                  child: Text('${formatAmount(_a.addonTotal)} EUR',
                      textAlign: TextAlign.right,
                      style: AppTextStyles.mono.copyWith(fontWeight: FontWeight.w600)),
                ),
              ]),
            ),
          if (_a.unresolvedAddons.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Wrap(spacing: 8, runSpacing: 6, children: [
                for (final u in _a.unresolvedAddons)
                  _UnresolvedChip(
                    label: u.rawLabel,
                    onResolve: canEdit ? () => _resolve(u.id, choices) : null,
                  ),
              ]),
            ),
        ],
      ]),
    );
  }
}

class _UnresolvedChip extends StatelessWidget {
  final String label;
  final VoidCallback? onResolve;
  const _UnresolvedChip({required this.label, this.onResolve});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.12),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: Colors.orange.withOpacity(0.5)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.warning_amber_rounded, size: 14, color: Colors.orange),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.mono12),
        if (onResolve != null) ...[
          const SizedBox(width: 6),
          InkWell(
            onTap: onResolve,
            child: Text('Resolve',
                style: AppTextStyles.mono12.copyWith(
                    color: AppColors.primaryText, decoration: TextDecoration.underline)),
          ),
        ],
      ]),
    );
  }
}

String _choiceDetail(Addon a, int? price) {
  final parts = [
    price == null ? 'no price' : '$price EUR',
    if (a.hasDuration && a.durationMinutes != null) '${a.durationMinutes} min',
  ];
  return parts.join(' · ');
}

class _Editor extends StatelessWidget {
  final List<AddonChoice> choices;
  final Map<int, int> prices;
  final AddonDraft draft;
  final bool saving;
  final ValueChanged<AddonDraft> onChanged;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  const _Editor({
    required this.choices,
    required this.prices,
    required this.draft,
    required this.saving,
    required this.onChanged,
    required this.onSave,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (choices.isEmpty) Text('No add-ons in the catalog yet', style: AppTextStyles.muted12),
      Wrap(spacing: 10, runSpacing: 10, children: [
        for (final c in choices)
          _ChoiceTile(
            choice: c,
            price: prices[c.addon.id],
            selected: draft.isSelected(c.addon.id),
            quantity: draft.quantityOf(c.addon.id),
            onToggle: () => onChanged(draft.toggle(c.addon.id)),
            onQuantity: (q) => onChanged(draft.withQuantity(c.addon.id, q)),
          ),
      ]),
      const SizedBox(height: 10),
      Row(children: [
        FilledButton(onPressed: saving ? null : onSave, child: const Text('Save')),
        const SizedBox(width: 8),
        TextButton(onPressed: saving ? null : onCancel, child: const Text('Cancel')),
      ]),
    ]);
  }
}

class _ChoiceTile extends StatelessWidget {
  final AddonChoice choice;
  final int? price;
  final bool selected;
  final int quantity;
  final VoidCallback onToggle;
  final ValueChanged<int> onQuantity;

  const _ChoiceTile({
    required this.choice,
    required this.price,
    required this.selected,
    required this.quantity,
    required this.onToggle,
    required this.onQuantity,
  });

  @override
  Widget build(BuildContext context) {
    final addon = choice.addon;
    // An inactive Add-on already on the Appointment can be removed, not re-added.
    final enabled = choice.canSelectNew || selected;
    return Container(
      width: 240,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.active,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: selected ? AppColors.primaryText : AppColors.border),
      ),
      child: Row(children: [
        Checkbox(value: selected, onChanged: enabled ? (_) => onToggle() : null),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(addon.name + (addon.isActive ? '' : ' (inactive)'),
                style: AppTextStyles.body14.copyWith(
                    color: addon.isActive ? AppColors.primaryText : AppColors.mutedText)),
            Text(_choiceDetail(addon, price), style: AppTextStyles.monoMuted11),
          ]),
        ),
        if (selected && addon.hasQuantity) _Stepper(value: quantity, onChanged: onQuantity),
      ]),
    );
  }
}

class _Stepper extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const _Stepper({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(mainAxisSize: MainAxisSize.min, children: [
      InkWell(
        onTap: value > 1 ? () => onChanged(value - 1) : null,
        child: Icon(Icons.remove_circle_outline, size: 18, color: value > 1 ? null : AppColors.border),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Text('$value', style: AppTextStyles.mono12),
      ),
      InkWell(onTap: () => onChanged(value + 1), child: const Icon(Icons.add_circle_outline, size: 18)),
    ]);
  }
}

/// Picks one Add-on and a quantity to resolve an Unresolved Add-on against.
class _ResolveDialog extends StatefulWidget {
  final List<AddonChoice> choices;
  final Map<int, int> prices;
  const _ResolveDialog({required this.choices, required this.prices});

  @override
  State<_ResolveDialog> createState() => _ResolveDialogState();
}

class _ResolveDialogState extends State<_ResolveDialog> {
  Addon? _picked;
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final options = [for (final c in widget.choices) if (c.canSelectNew) c.addon];
    return AlertDialog(
      title: const Text('Resolve add-on'),
      content: SizedBox(
        width: 320,
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (options.isEmpty) const Text('No active add-ons in the catalog'),
          for (final a in options)
            RadioListTile<int>(
              dense: true,
              value: a.id,
              groupValue: _picked?.id,
              title: Text(a.name),
              subtitle: Text(_choiceDetail(a, widget.prices[a.id])),
              onChanged: (_) => setState(() {
                _picked = a;
                _quantity = 1;
              }),
            ),
          if (_picked?.hasQuantity ?? false)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(children: [
                const Text('Quantity'),
                const SizedBox(width: 12),
                _Stepper(value: _quantity, onChanged: (q) => setState(() => _quantity = q)),
              ]),
            ),
        ]),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: _picked == null ? null : () => Navigator.pop(context, (addon: _picked!, quantity: _quantity)),
          child: const Text('Resolve'),
        ),
      ],
    );
  }
}
