import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:photography_business_frontend/features/business/domain/usecases/member_params.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/commission_providers.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/member_providers.dart';
import 'package:photography_business_frontend/features/package/domain/entities/package.dart';
import 'package:photography_business_frontend/features/package/domain/entities/package_price.dart';
import 'package:photography_business_frontend/features/package/presentation/providers/notifiers/packages_pricing_map_notifier.dart';
import 'package:photography_business_frontend/features/package/presentation/providers/package_providers.dart';

import '../../domain/entities/appointment.dart';
import '../../domain/usecases/appointment_params.dart';
import '../providers/appointment_providers.dart';

/// Returns true if something was saved, so the caller can refresh its list.
Future<bool?> showAppointmentFormSheet(
  BuildContext context, {
  required int businessId,
  Appointment? existing,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    builder: (_) => AppointmentFormSheet(businessId: businessId, existing: existing),
  );
}

class AppointmentFormSheet extends ConsumerStatefulWidget {
  final int businessId;
  final Appointment? existing;

  const AppointmentFormSheet({super.key, required this.businessId, this.existing});

  @override
  ConsumerState<AppointmentFormSheet> createState() => _AppointmentFormSheetState();
}

class _AppointmentFormSheetState extends ConsumerState<AppointmentFormSheet> {
  late final _firstNameCtrl = TextEditingController(text: widget.existing?.clientFirstName ?? '');
  late final _lastNameCtrl = TextEditingController(text: widget.existing?.clientLastName ?? '');
  late final _emailCtrl = TextEditingController(text: widget.existing?.clientEmail ?? '');
  late final _phoneCtrl = TextEditingController(text: widget.existing?.clientPhone ?? '');
  late final _locationCtrl = TextEditingController(text: widget.existing?.appointmentLocation ?? '');
  late final _durationCtrl = TextEditingController(text: widget.existing?.appointmentDuration.toString() ?? '');
  late final _noteCtrl = TextEditingController(text: widget.existing?.appointmentNote ?? '');
  late final _personsCtrl =
      TextEditingController(text: widget.existing?.numberOfPersons?.toString() ?? '');
  late final _priceCtrl =
      TextEditingController(text: widget.existing?.priceAtBooking?.toStringAsFixed(0) ?? '');
  late final _depositCtrl =
      TextEditingController(text: widget.existing?.depositAmount?.toStringAsFixed(0) ?? '');
  late final _remainingCtrl =
      TextEditingController(text: widget.existing?.remainingAmount?.toStringAsFixed(0) ?? '');
  late final _commissionPercentCtrl = TextEditingController(
      text: widget.existing?.commissionPercentAtBooking?.toStringAsFixed(0) ?? '');
  late final _commissionAmountCtrl = TextEditingController(
      text: widget.existing?.commissionAmountAtBooking?.toStringAsFixed(0) ?? '');

  late DateTime _date = widget.existing?.appointmentDate ?? DateTime.now();
  int? _memberId;
  int? _packageId;
  int? _packagePriceId;
  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    _memberId = widget.existing?.memberId;
    _packageId = widget.existing?.packageId;
    _packagePriceId = widget.existing?.packagePriceId;
    // packagesPricingMapProvider is a single global instance (not keyed by
    // business, unlike businessMembersProvider) — reloading it here for this
    // businessId is the only way to guarantee it has data, but it will
    // clobber another business's already-loaded pricing if one was showing.
    // Worth making it StateNotifierProvider.family like businessMembersProvider.
    Future.microtask(
      () => ref.read(packagesPricingMapProvider.notifier).loadForBusiness(widget.businessId),
    );
  }

  @override
  void dispose() {
    for (final c in [
      _firstNameCtrl, _lastNameCtrl, _emailCtrl, _phoneCtrl, _locationCtrl,
      _durationCtrl, _noteCtrl, _personsCtrl, _priceCtrl, _depositCtrl,
      _remainingCtrl, _commissionPercentCtrl, _commissionAmountCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null) return;
    final time = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_date));
    setState(() => _date = DateTime(
          picked.year, picked.month, picked.day,
          time?.hour ?? _date.hour, time?.minute ?? _date.minute,
        ));
  }

  /// Fill price/commission fields from the package's current price + this
  /// member's commission on it. Only overwrites fields the user hasn't
  /// already typed something into, so re-picking a package doesn't blow away
  /// manual edits.
  Future<void> _onPackageChanged(int? packageId, PackagesPricingMapState pricingState) async {
    setState(() => _packageId = packageId);
    if (packageId == null) return;

    final prices = [...(pricingState.pricesByPackage[packageId] ?? const <PackagePrice>[])]
      ..sort((a, b) => a.effectiveFrom.compareTo(b.effectiveFrom));
    final current = prices.isEmpty ? null : prices.last;

    setState(() {
      _packagePriceId = current?.id;
      if (current != null) {
        if (_priceCtrl.text.isEmpty) _priceCtrl.text = current.totalPrice.toString();
        if (_depositCtrl.text.isEmpty) _depositCtrl.text = current.depositAmount.toString();
        if (_remainingCtrl.text.isEmpty) _remainingCtrl.text = current.remainingAmount.toString();
      }
    });

    await _refreshCommission();
  }

  Future<void> _refreshCommission() async {
    if (_memberId == null || _packageId == null) return;
    final result = await ref.read(getMemberCommissionUserProvider)(
      GetMemberCommissionParams(memberId: _memberId!, packageId: _packageId!),
    );
    result.fold(
      // No commission configured for this member/package yet — leave at 0,
      // it's a legitimate state, not an error worth surfacing here.
      (_) {},
      (commission) => setState(() {
        if (commission.commissionIsPercentage) {
          _commissionPercentCtrl.text = commission.commissionAmount.toString();
          _commissionAmountCtrl.text = '0';
        } else {
          _commissionAmountCtrl.text = commission.commissionAmount.toString();
          _commissionPercentCtrl.text = '0';
        }
      }),
    );
  }

  bool get _canSubmit =>
      _firstNameCtrl.text.trim().isNotEmpty &&
      _lastNameCtrl.text.trim().isNotEmpty &&
      (_isEdit || (_packageId != null && _packagePriceId != null));

  Future<void> _submit() async {
    final notifier = ref.read(appointmentFormNotifierProvider.notifier);
    final ok = _isEdit
        ? await notifier.update(
            businessId: widget.businessId,
            appointmentId: widget.existing!.id,
            clientName: '${_firstNameCtrl.text.trim()} ${_lastNameCtrl.text.trim()}',
            clientEmail: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
            clientPhone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
            appointmentDate: _date,
            appointmentLocation: _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
            appointmentDuration: _durationCtrl.text.trim().isEmpty ? null : _durationCtrl.text.trim(),
            appointmentNote: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
            numberOfPersons: int.tryParse(_personsCtrl.text.trim()),
            memberId: _memberId,
          )
        : await notifier.create(CreateAppointmentParams(
            memberId: _memberId,
            businessId: widget.businessId,
            packageId: _packageId!,
            packagePriceId: _packagePriceId!,
            clientFirstName: _firstNameCtrl.text.trim(),
            clientLastName: _lastNameCtrl.text.trim(),
            clientEmail: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
            clientPhone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
            appointmentDate: _date,
            priceAtBooking: double.tryParse(_priceCtrl.text.trim()) ?? 0,
            depositAmount: double.tryParse(_depositCtrl.text.trim()) ?? 0,
            remainingAmount: double.tryParse(_remainingCtrl.text.trim()) ?? 0,
            commissionPercentAtBooking: double.tryParse(_commissionPercentCtrl.text.trim()) ?? 0,
            commissionAmountAtBooking: double.tryParse(_commissionAmountCtrl.text.trim()) ?? 0,
            appointmentLocation: _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
            appointmentDuration: _durationCtrl.text.trim().isEmpty ? null : _durationCtrl.text.trim(),
            appointmentNote: _noteCtrl.text.trim().isEmpty ? null : _noteCtrl.text.trim(),
            numberOfPersons: int.tryParse(_personsCtrl.text.trim()),
          ));
    if (ok && mounted) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(appointmentFormNotifierProvider);
    final membersState = ref.watch(businessMembersProvider(widget.businessId));
    final pricingState = ref.watch(packagesPricingMapProvider);

    final allPackages = <MapEntry<PackageCategoryLabel, Package>>[
      for (final entry in pricingState.packagesByCategory.entries)
        for (final pkg in entry.value)
          MapEntry(
            PackageCategoryLabel(
              pricingState.categories
                      .where((c) => c.id == entry.key)
                      .map((c) => c.name)
                      .firstOrNull ??
                  '',
            ),
            pkg,
          ),
    ];

    return Padding(
      padding: EdgeInsets.only(
        left: 20, right: 20, top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              _isEdit ? 'Edit appointment' : 'New appointment',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _firstNameCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(labelText: 'Client first name'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _lastNameCtrl,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(labelText: 'Client last name'),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Client email (optional)',
                helperText: 'Saved via a follow-up PATCH — see README',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(labelText: 'Client phone (optional)'),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _pickDate,
              child: InputDecorator(
                decoration: const InputDecoration(labelText: 'Date & time'),
                child: Text(
                  '${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}/${_date.year}'
                  '  ${_date.hour.toString().padLeft(2, '0')}:${_date.minute.toString().padLeft(2, '0')}',
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (!_isEdit) ...[
              DropdownButtonFormField<int>(
                value: _packageId,
                decoration: const InputDecoration(labelText: 'Package'),
                isExpanded: true,
                items: allPackages
                    .map((e) => DropdownMenuItem(
                          value: e.value.id,
                          child: Text('${e.key.name.isEmpty ? '' : '${e.key.name} · '}${e.value.name}'),
                        ))
                    .toList(),
                onChanged: (id) => _onPackageChanged(id, pricingState),
              ),
              if (_packageId != null && _packagePriceId == null)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text('This package has no price set yet — add one under Packages & Pricing first.',
                      style: TextStyle(color: Colors.red, fontSize: 12)),
                ),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Price at booking'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _depositCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Deposit'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _remainingCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Remaining'),
                  ),
                ),
              ]),
              const SizedBox(height: 16),
            ],
            DropdownButtonFormField<int?>(
              value: _memberId,
              decoration: const InputDecoration(labelText: 'Photographer (optional)'),
              items: [
                const DropdownMenuItem(value: null, child: Text('Unassigned')),
                ...membersState.members.map((m) => DropdownMenuItem(
                      value: m.id, // BusinessMember.id — see photographer_colors.dart note
                      child: Text(m.userName ?? 'Unknown'),
                    )),
              ],
              onChanged: (id) {
                setState(() => _memberId = id);
                _refreshCommission();
              },
            ),
            if (!_isEdit) ...[
              const SizedBox(height: 12),
              Row(children: [
                Expanded(
                  child: TextField(
                    controller: _commissionPercentCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Commission %'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _commissionAmountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Commission (flat)'),
                  ),
                ),
              ]),
            ],
            const SizedBox(height: 16),
            TextField(
              controller: _locationCtrl,
              decoration: const InputDecoration(labelText: 'Location (optional)'),
            ),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: TextField(
                  controller: _durationCtrl,
                  decoration: const InputDecoration(labelText: 'Duration (optional, e.g. "2h")'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _personsCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Persons (optional)'),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            TextField(
              controller: _noteCtrl,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Notes (optional)'),
            ),
            if (formState.error != null) ...[
              const SizedBox(height: 12),
              Text(formState.error!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: (formState.isSubmitting || !_canSubmit) ? null : _submit,
              child: formState.isSubmitting
                  ? const SizedBox(
                      width: 18, height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(_isEdit ? 'Save' : 'Create'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Tiny wrapper so the dropdown's key carries a category label without
/// pulling in equatable for a one-off.
class PackageCategoryLabel {
  final String name;
  const PackageCategoryLabel(this.name);
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
