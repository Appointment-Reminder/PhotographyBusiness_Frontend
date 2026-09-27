import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/member_providers.dart';
import 'package:photography_business_frontend/features/package/presentation/providers/package_providers.dart';
import '../../domain/entities/appointment.dart';
import '../providers/appointment_providers.dart';
import '../widgets/photographer_colors.dart';
import '../widgets/appointment_form_sheet.dart';

class AppointmentCalendarPage extends ConsumerStatefulWidget {
  final int businessId;
  const AppointmentCalendarPage({super.key, required this.businessId});

  @override
  ConsumerState<AppointmentCalendarPage> createState() => _AppointmentCalendarPageState();
}

class _AppointmentCalendarPageState extends ConsumerState<AppointmentCalendarPage> {
  late DateTime _month = DateTime(DateTime.now().year, DateTime.now().month, 1);
  int? _photographerFilter; // member_id
  Appointment? _selected;

  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => ref.read(packagesPricingMapProvider.notifier).loadForBusiness(widget.businessId),
    );
  }

  void _shiftMonth(int delta) {
    setState(() {
      _month = DateTime(_month.year, _month.month + delta, 1);
      _selected = null;
    });
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

    final visible = state.appointments.where((a) {
      final sameMonth = a.appointmentDate.year == _month.year && a.appointmentDate.month == _month.month;
      final matchesPhotographer = _photographerFilter == null || a.memberId == _photographerFilter;
      return sameMonth && matchesPhotographer;
    }).toList();

    final byDay = <int, List<Appointment>>{};
    for (final a in visible) {
      (byDay[a.appointmentDate.day] ??= []).add(a);
    }
    for (final list in byDay.values) {
      list.sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
    }

    final firstWeekday = DateTime(_month.year, _month.month, 1).weekday; // 1=Mon
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final leading = firstWeekday - 1;
    final totalCells = ((leading + daysInMonth) / 7).ceil() * 7;

    return Scaffold(
      appBar: AppBar(title: const Text('Calendar')),
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
      body: state.isLoading && state.appointments.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                                onPressed: () => _shiftMonth(-1),
                                icon: const Icon(Icons.chevron_left)),
                            SizedBox(
                              width: 160,
                              child: Text(
                                DateFormat('MMMM yyyy').format(_month),
                                textAlign: TextAlign.center,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            IconButton(
                                onPressed: () => _shiftMonth(1),
                                icon: const Icon(Icons.chevron_right)),
                            const Spacer(),
                            Wrap(
                              spacing: 6,
                              children: [
                                ChoiceChip(
                                  label: const Text('All'),
                                  selected: _photographerFilter == null,
                                  onSelected: (_) => setState(() => _photographerFilter = null),
                                ),
                                ...members.map((m) => ChoiceChip(
                                      avatar: CircleAvatar(
                                        backgroundColor: PhotographerColors.of(m.id),
                                        radius: 6,
                                      ),
                                      label: Text(m.userName ?? 'Unknown'),
                                      selected: _photographerFilter == m.id,
                                      onSelected: (_) =>
                                          setState(() => _photographerFilter = m.id),
                                    )),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun']
                              .map((d) => Expanded(
                                    child: Center(
                                        child: Text(d,
                                            style: const TextStyle(
                                                fontSize: 11, color: Colors.grey))),
                                  ))
                              .toList(),
                        ),
                        Expanded(
                          child: GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 7,
                              childAspectRatio: 0.9,
                            ),
                            itemCount: totalCells,
                            itemBuilder: (context, i) {
                              final day = i - leading + 1;
                              if (day < 1 || day > daysInMonth) return const SizedBox.shrink();
                              final appts = byDay[day] ?? const [];
                              final isToday = DateUtils.isSameDay(
                                  DateTime(_month.year, _month.month, day), DateTime.now());
                              return Container(
                                margin: const EdgeInsets.all(2),
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey.shade300),
                                  borderRadius: BorderRadius.circular(6),
                                  color: isToday ? Colors.blue.withOpacity(0.05) : null,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('$day', style: const TextStyle(fontSize: 11)),
                                    const SizedBox(height: 2),
                                    ...appts.take(3).map((a) => GestureDetector(
                                          onTap: () => setState(() => _selected = a),
                                          child: Container(
                                            margin: const EdgeInsets.only(bottom: 2),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 3, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: PhotographerColors.of(a.memberId)
                                                  .withOpacity(0.15),
                                              borderRadius: BorderRadius.circular(3),
                                            ),
                                            child: Text(
                                              '${DateFormat('HH:mm').format(a.appointmentDate)} ${a.clientName}',
                                              style: const TextStyle(fontSize: 9),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        )),
                                    if (appts.length > 3)
                                      Text('+${appts.length - 3} more',
                                          style: const TextStyle(fontSize: 9, color: Colors.grey)),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 260,
                    child: _DetailPanel(
                      appointment: _selected,
                      packageName: _selected?.packageId == null
                          ? null
                          : packagesById[_selected!.packageId]?.name,
                      photographerName: _selected?.memberId == null
                          ? null
                          : membersById[_selected!.memberId]?.userName,
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _DetailPanel extends StatelessWidget {
  final Appointment? appointment;
  final String? packageName;
  final String? photographerName;
  const _DetailPanel({required this.appointment, this.packageName, this.photographerName});

  @override
  Widget build(BuildContext context) {
    final a = appointment;
    if (a == null) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8)),
        child: const Center(child: Text('Click an appointment\nto see details', textAlign: TextAlign.center)),
      );
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(DateFormat('EEEE, d MMMM yyyy').format(a.appointmentDate),
              style: Theme.of(context).textTheme.titleSmall),
          Text(DateFormat('HH:mm').format(a.appointmentDate)),
          const SizedBox(height: 4),
          Text(a.status, style: const TextStyle(fontSize: 11, color: Colors.grey)),
          const SizedBox(height: 12),
          Text(a.clientName, style: const TextStyle(fontWeight: FontWeight.bold)),
          if (a.clientEmail != null) Text(a.clientEmail!),
          if (a.clientPhone != null) Text(a.clientPhone!),
          const SizedBox(height: 12),
          if (packageName != null) Text('Package: $packageName'),
          if (a.appointmentLocation != null) Text('📍 ${a.appointmentLocation}'),
          if (a.priceAtBooking != null)
            Text('${a.priceAtBooking!.toStringAsFixed(0)} (deposit ${a.depositAmount?.toStringAsFixed(0) ?? '—'})'),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(
                    color: PhotographerColors.of(a.memberId), shape: BoxShape.circle),
              ),
              const SizedBox(width: 6),
              Text(photographerName ?? 'Unassigned'),
            ],
          ),
        ],
      ),
    );
  }
}
