import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/core/Presentation/navigation/app_section.dart';
import 'package:photography_business_frontend/core/Presentation/widgets/NavBar/TopNavBar/top_nav_bar.dart';
import 'package:photography_business_frontend/core/Presentation/widgets/app_nav_bar.dart';
import 'package:photography_business_frontend/features/addon/presentation/pages/addons_catalog_view.dart';
import 'package:photography_business_frontend/features/appointment/presentation/pages/appointment_calendar_page.dart';
import 'package:photography_business_frontend/features/appointment/presentation/pages/appointments_page.dart';
import 'package:photography_business_frontend/features/appointment/presentation/pages/workflow_page.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/business_providers.dart';
import 'package:photography_business_frontend/features/business/presentation/widgets/create_business_dialog.dart';
import 'package:photography_business_frontend/features/jotform/presentation/pages/jotform_integration_view.dart';
import 'package:photography_business_frontend/features/jotform/presentation/pages/jotform_matrix_view.dart';
import 'package:photography_business_frontend/features/package/presentation/pages/package_pricing_view.dart';
import 'package:photography_business_frontend/features/package/presentation/widgets/team_commission_view.dart';

/// Persistent shell: domain-grouped sidebar + the selected section's content.
class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final section = ref.watch(selectedSectionProvider);
    final subView = ref.watch(sectionSubViewProvider(section));

    return Scaffold(
      body: Row(
        children: [
          const AppNavBar(),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: Column(
              children: [
                if (section.hasTabs)
                  TopNavBar(
                    brandName: section.label,
                    items: [for (final v in section.subViews) TopNavBarItem(id: v.name, label: v.label)],
                    activeId: subView?.name ?? '',
                    onItemSelected: (id) =>
                        ref.read(sectionSubViewProvider(section).notifier).state = SubView.values.byName(id),
                  ),
                Expanded(child: _Content(section: section, subView: subView)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Content extends ConsumerWidget {
  final AppSection section;
  final SubView? subView;
  const _Content({required this.section, required this.subView});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(businessListNotifierProvider);
    final business = ref.watch(selectedBusinessProvider);

    if (state.isLoading && state.businesses.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.error != null) {
      return const Center(child: Icon(Icons.error_outline, color: Colors.red));
    }
    if (business == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Create or select a business to get started'),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: () => showCreateBusinessDialog(context, ref),
              child: const Text('Create business'),
            ),
          ],
        ),
      );
    }

    final id = business.id;
    switch (section) {
      case AppSection.dashboard:
        return Center(child: Text('Dashboard of ${business.name} in progress'));
      case AppSection.appointments:
        switch (subView) {
          case SubView.calendar:
            return AppointmentCalendarPage(businessId: id);
          case SubView.workflow:
            return WorkflowPage(businessId: id);
          default:
            return AppointmentsPage(businessId: id);
        }
      case AppSection.team:
        return TeamCommissionsView(businessId: id);
      case AppSection.catalog:
        return subView == SubView.catalogAddons
            ? AddonsCatalogView(businessId: id)
            : PackagesPricingView(businessId: id);
      case AppSection.analytics:
        return const Center(child: Text('Analytics: coming soon'));
      case AppSection.report:
        return const Center(child: Text('Report: coming soon'));
      case AppSection.settings:
        switch (subView) {
          case SubView.jotform:
            return JotformMatrixView(businessId: id);
          case SubView.jotformIntegration:
            return JotformIntegrationView(businessId: id);
          default:
            return Center(child: Text('Settings of ${business.name} in progress'));
        }
    }
  }
}
