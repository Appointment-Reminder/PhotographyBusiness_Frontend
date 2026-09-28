import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_text_styles.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/member_providers.dart';
import 'package:photography_business_frontend/features/package/presentation/providers/package_providers.dart';
import '../../domain/entities/appointment.dart';
import '../providers/appointment_providers.dart';
import '../widgets/appointment_form_sheet.dart';
import '../widgets/calendar/appointment_detail_panel.dart';
import '../widgets/calendar/calendar_filters_bar.dart';
import '../widgets/calendar/calendar_grid.dart';

class AppointmentCalendarPage extends ConsumerStatefulWidget {
  final int businessId;
  const AppointmentCalendarPage({super.key, required this.businessId});

  @override
  ConsumerState<AppointmentCalendarPage> createState() => _AppointmentCalendarPageState();
}

class _AppointmentCalendarPageState extends ConsumerState<AppointmentCalendarPage> {
  late DateTime _month = DateTime(DateTime.now().year, DateTime.now().month, 1);
  int? _photographerFilter;
  int? _selectedId;

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        ref.read(packagesPricingMapProvider.notifier).loadForBusiness(widget.businessId));
  }

  void _shiftMonth(int delta) => setState(() {
    _month = DateTime(_month.year, _month.month + delta, 1);
    _selectedId = null;
  });

  Future<void> _create() async {
    final saved = await showAppointmentFormSheet(context, businessId: widget.businessId);
    if (saved == true) {
      ref.read(appointmentListNotifierProvider(widget.businessId).notifier)
          .loadForBusiness(widget.businessId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appointmentListNotifierProvider(widget.businessId));
    final members = ref.watch(businessMembersProvider(widget.businessId)).members;
    final pricing = ref.watch(packagesPricingMapProvider);

    final packagesById = {
      for (final l in pricing.packagesByCategory.values) for (final p in l) p.id: p,
    };
    final membersById = {for (final m in members) m.id: m};

    final byDay = <int, List<Appointment>>{};
    for (final a in state.appointments) {
      final d = a.appointmentDate;
      if (d.year != _month.year || d.month != _month.month) continue;
      if (_photographerFilter != null && a.memberId != _photographerFilter) continue;
      (byDay[d.day] ??= []).add(a);
    }
    for (final l in byDay.values) {
      l.sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
    }

    final selected = state.appointments.where((a) => a.id == _selectedId).firstOrNull;

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PHOTOGRAPHY STUDIO',
              style: AppTextStyles.monoMuted10.copyWith(letterSpacing: 2.8)),
          const SizedBox(height: 8),
          Row(children: [
            Text('Calendar', style: AppTextStyles.heading24),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: _create,
              icon: const Icon(Icons.add, size: 14),
              label: const Text('New appointment'),
            ),
          ]),
          const SizedBox(height: 24),
          CalendarFiltersBar(
            month: _month,
            members: members,
            photographerFilter: _photographerFilter,
            onPrev: () => _shiftMonth(-1),
            onNext: () => _shiftMonth(1),
            onPhotographerChanged: (id) => setState(() => _photographerFilter = id),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: state.isLoading && state.appointments.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: CalendarGrid(
                      month: _month,
                      appointmentsByDay: byDay,
                      selectedId: _selectedId,
                      onSelect: (id) => setState(
                              () => _selectedId = _selectedId == id ? null : id),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                SizedBox(
                  width: 280,
                  child: AppointmentDetailPanel(
                    appointment: selected,
                    package: packagesById[selected?.packageId],
                    photographer: membersById[selected?.memberId],
                    onClose: () => setState(() => _selectedId = null),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}