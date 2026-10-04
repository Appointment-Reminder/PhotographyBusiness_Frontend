import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/core/Presentation/theme/app_colors.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/member_providers.dart';
import 'package:photography_business_frontend/features/package/presentation/providers/package_providers.dart';
import '../../../../core/Presentation/theme/app_text_styles.dart';
import '../../domain/entities/appointment.dart';
import 'package:photography_business_frontend/features/addon/presentation/providers/addon_providers.dart';
import '../providers/appointment_providers.dart';
import '../widgets/appointment_addons_section.dart';
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
  String? _statusFilter;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(packagesPricingMapProvider.notifier).loadForBusiness(widget.businessId);
      // Every member can read the active Add-ons, so names resolve for all.
      ref.read(addonCatalogProvider.notifier).load(widget.businessId);
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

    final months = {
      for (final a in state.appointments)
        '${a.appointmentDate.year}-${a.appointmentDate.month.toString().padLeft(2, '0')}'
    }.toList()
      ..sort();

    final statuses = {for (final a in state.appointments) a.status}.toList()..sort();

    final filtered = state.appointments.where((a) {
      final matchesPhotographer =
          _photographerFilter == null || a.memberId == _photographerFilter;
      final key = '${a.appointmentDate.year}-${a.appointmentDate.month.toString().padLeft(2, '0')}';
      final matchesMonth = _monthFilter == null || key == _monthFilter;
      final matchesStatus = _statusFilter == null || a.status == _statusFilter;
      return matchesPhotographer && matchesMonth && matchesStatus;
    }).toList()
      ..sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));

    Widget _buildContent(){
      return Column(
        children: [
          Row(
            children: [
              SizedBox(
                width: 250,
                child: DropdownMenu<int?>(
                  expandedInsets: EdgeInsets.zero,
                  initialSelection: _photographerFilter,
                  hintText: 'All photographers',
                  dropdownMenuEntries: [
                    const DropdownMenuEntry<int?>(
                      value: null,
                      label: 'All photographers',
                    ),
                    ...members.map(
                          (m) => DropdownMenuEntry<int?>(
                        value: m.id,
                        label: m.userName ?? 'Unknown',
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    setState(() {
                      _photographerFilter = value;
                    });
                  },
                  inputDecorationTheme: InputDecorationTheme(
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 40,),
              SizedBox(
                width: 180,
                child: DropdownMenu<String?>(
                  initialSelection: _monthFilter,
                  expandedInsets: EdgeInsets.zero,
                  hintText: 'All months',
                  dropdownMenuEntries: [
                    const DropdownMenuEntry<String?>(
                      value: null,
                      label: 'All months',
                    ),
                    ...months.map(
                          (m) => DropdownMenuEntry<String?>(
                        value: m,
                        label: m,
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    setState(() {
                      _monthFilter = value;
                    });
                  },
                  inputDecorationTheme: InputDecorationTheme(
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 40,),
              SizedBox(
                width: 180,
                child: DropdownMenu<String?>(
                  initialSelection: _statusFilter,
                  expandedInsets: EdgeInsets.zero,
                  hintText: 'All statuses',
                  dropdownMenuEntries: [
                    const DropdownMenuEntry<String?>(value: null, label: 'All statuses'),
                    ...statuses.map((s) => DropdownMenuEntry<String?>(value: s, label: s)),
                  ],
                  onSelected: (value) => setState(() => _statusFilter = value),
                  inputDecorationTheme: InputDecorationTheme(
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Text('${filtered.length} appointments'),
            ],
          ), //FILTER BUTTON
          const SizedBox(height: 12,),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.active,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.border,
                ),
              ),
              clipBehavior: Clip.hardEdge,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // TABLE HEADER
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.appointmentListHeaderBG,
                      border: const Border(
                        bottom: BorderSide(
                          color: AppColors.border,
                        ),
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 180,
                          child: Text(
                            textAlign: TextAlign.left,
                            'DATE & TIME',
                            style: AppTextStyles.monoMuted10.copyWith(
                              letterSpacing: 1.5,
                            ),
                          ),
                        ),

                        const Expanded(
                          child: Text(
                            'CLIENT',
                            style: TextStyle(
                              fontSize: 10,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: 160,
                          child: Text(
                            textAlign: TextAlign.left,
                            'PACKAGE',
                            style: TextStyle(
                              fontSize: 10,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),


                        const SizedBox(
                          width: 160,
                          child: Text(
                            'PHOTOGRAPHER',
                            style: TextStyle(
                              fontSize: 10,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),

                        const SizedBox(
                          width: 90,
                          child: Text(
                            'STATUS',
                            style: TextStyle(
                              fontSize: 10,
                              letterSpacing: 1.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // APPOINTMENT ROWS
                  Expanded(
                    child: ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const Divider(
                        height: 1,
                      ),
                      itemBuilder: (context, i) {
                        final Appointment a = filtered[i];

                        return AppointmentRow(
                          appointment: a,
                          package: a.packageId == null
                              ? null
                              : packagesById[a.packageId],
                          photographer: a.memberId == null
                              ? null
                              : membersById[a.memberId],
                          isExpanded: _expandedId == a.id,
                          addonsSection: AppointmentAddonsSection(
                            appointment: a,
                            businessId: widget.businessId,
                          ),
                          onToggle: () {
                            setState(() {
                              _expandedId =
                              _expandedId == a.id ? null : a.id;
                            });
                          },
                          onEdit: () async {
                            final saved = await showAppointmentFormSheet(
                              context,
                              businessId: widget.businessId,
                              existing: a,
                            );

                            if (saved == true) {
                              ref
                                  .read(
                                appointmentListNotifierProvider(
                                  widget.businessId,
                                ).notifier,
                              )
                                  .loadForBusiness(widget.businessId);
                            }
                          },
                          onDelete: () {
                            ref
                                .read(
                              appointmentListNotifierProvider(
                                widget.businessId,
                              ).notifier,
                            )
                                .remove(a.id);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('PHOTOGRAPHY STUDIO', style: AppTextStyles.monoMuted10.copyWith(letterSpacing: 2.8)),
          const SizedBox(height: 8),
          Text('Appointments', style: AppTextStyles.heading24),
          const SizedBox(height: 32),
          Expanded(
            child: _buildContent(),
          ),
        ],
      ),
    );



  }
}
