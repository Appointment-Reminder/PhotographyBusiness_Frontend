import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/member_providers.dart';
import 'package:photography_business_frontend/features/package/presentation/providers/package_providers.dart';
import '../../domain/entities/appointment.dart';
import '../providers/appointment_providers.dart';
import '../widgets/appointment_row.dart';
import '../widgets/appointment_form_sheet.dart';

class AppointmentsPage extends ConsumerStatefulWidget {
  final int businessId;
  const AppointmentsPage({super.key, required this.businessId});

  @override
  ConsumerState<AppointmentsPage> createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends ConsumerState<AppointmentsPage> {
  int? _photographerFilter; // member_id
  String? _monthFilter; // "yyyy-MM"
  int? _expandedId;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(packagesPricingMapProvider.notifier).loadForBusiness(widget.businessId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appointmentListNotifierProvider(widget.businessId));
    final members = ref.watch(businessMembersProvider(widget.businessId)).members;
    final pricingState = ref.watch(packagesPricingMapProvider);

    final packagesById = {
      for (final list in pricingState.packagesByCategory.values)
        for (final p in list) p.id: p,
    };
    final membersById = {for (final m in members) m.id: m};

    final months = {
      for (final a in state.appointments)
        '${a.appointmentDate.year}-${a.appointmentDate.month.toString().padLeft(2, '0')}'
    }.toList()
      ..sort();

    final filtered = state.appointments.where((a) {
      final matchesPhotographer =
          _photographerFilter == null || a.memberId == _photographerFilter;
      final key = '${a.appointmentDate.year}-${a.appointmentDate.month.toString().padLeft(2, '0')}';
      final matchesMonth = _monthFilter == null || key == _monthFilter;
      return matchesPhotographer && matchesMonth;
    }).toList()
      ..sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref
                .read(appointmentListNotifierProvider(widget.businessId).notifier)
                .loadForBusiness(widget.businessId),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final saved = await showAppointmentFormSheet(context, businessId: widget.businessId);
          if (saved == true) {
            ref
                .read(appointmentListNotifierProvider(widget.businessId).notifier)
                .loadForBusiness(widget.businessId);
          }
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                DropdownButton<int?>(
                  value: _photographerFilter,
                  hint: const Text('All photographers'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All photographers')),
                    ...members.map((m) => DropdownMenuItem(
                          value: m.id,
                          child: Text(m.userName ?? 'Unknown'),
                        )),
                  ],
                  onChanged: (v) => setState(() => _photographerFilter = v),
                ),
                const SizedBox(width: 16),
                DropdownButton<String?>(
                  value: _monthFilter,
                  hint: const Text('All months'),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('All months')),
                    ...months.map((m) => DropdownMenuItem(value: m, child: Text(m))),
                  ],
                  onChanged: (v) => setState(() => _monthFilter = v),
                ),
                const Spacer(),
                Text('${filtered.length} appointments'),
              ],
            ),
          ),
          const Divider(height: 1),
          if (state.isLoading && state.appointments.isEmpty)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else if (state.error != null)
            Expanded(child: Center(child: Text(state.error!)))
          else if (filtered.isEmpty)
            const Expanded(child: Center(child: Text('No appointments match your filters.')))
          else
            Expanded(
              child: ListView.separated(
                itemCount: filtered.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, i) {
                  final Appointment a = filtered[i];
                  return AppointmentRow(
                    appointment: a,
                    package: a.packageId == null ? null : packagesById[a.packageId],
                    photographer: a.memberId == null ? null : membersById[a.memberId],
                    isExpanded: _expandedId == a.id,
                    onToggle: () => setState(() => _expandedId = _expandedId == a.id ? null : a.id),
                    onEdit: () async {
                      final saved = await showAppointmentFormSheet(
                        context, businessId: widget.businessId, existing: a,
                      );
                      if (saved == true) {
                        ref
                            .read(appointmentListNotifierProvider(widget.businessId).notifier)
                            .loadForBusiness(widget.businessId);
                      }
                    },
                    onDelete: () => ref
                        .read(appointmentListNotifierProvider(widget.businessId).notifier)
                        .remove(a.id),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
