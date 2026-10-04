import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A view inside a section, shown as a secondary tab.
enum SubView {
  appointmentList('Appointments'),
  calendar('Calendar'),
  workflow('Workflow'),
  catalogPackages('Packages'),
  catalogAddons('Add-ons'),
  settingsGeneral('General'),
  jotform('Jotform'),
  jotformIntegration('Jotform Integration');

  final String label;
  const SubView(this.label);
}

/// A top-level destination of the sidebar. Sections with several [subViews]
/// show them as a secondary tab bar; single-view sections show none.
enum AppSection {
  dashboard('Dashboard', Icons.dashboard_outlined),
  appointments('Appointments', Icons.event_outlined, [
    SubView.appointmentList,
    SubView.calendar,
    SubView.workflow,
  ]),
  team('Team', Icons.group_outlined),
  catalog('Catalog', Icons.inventory_2_outlined, [
    SubView.catalogPackages,
    SubView.catalogAddons,
  ]),
  analytics('Analytics', Icons.insights_outlined),
  report('Report', Icons.description_outlined),
  settings('Settings', Icons.settings_outlined, [
    SubView.settingsGeneral,
    SubView.jotform,
    SubView.jotformIntegration,
  ]);

  final String label;
  final IconData icon;
  final List<SubView> subViews;

  const AppSection(this.label, this.icon, [this.subViews = const []]);

  bool get hasTabs => subViews.length > 1;

  SubView? get defaultSubView => subViews.isEmpty ? null : subViews.first;
}

final selectedSectionProvider =
    StateProvider<AppSection>((ref) => AppSection.dashboard);

/// The selected sub-view of each section (remembered while switching sections).
final sectionSubViewProvider =
    StateProvider.family<SubView?, AppSection>((ref, section) => section.defaultSubView);

/// Jumps to a sub-view of a section, e.g. from a "configure" link in another view.
void navigateTo(WidgetRef ref, AppSection section, [SubView? subView]) {
  if (subView != null) {
    ref.read(sectionSubViewProvider(section).notifier).state = subView;
  }
  ref.read(selectedSectionProvider.notifier).state = section;
}
