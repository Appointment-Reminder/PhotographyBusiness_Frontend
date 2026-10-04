import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SubView {
  final String id;
  final String label;
  const SubView(this.id, this.label);
}

/// A top-level destination of the sidebar. Sections with several [subViews]
/// show them as a secondary tab bar; single-view sections show none.
enum AppSection {
  dashboard('Dashboard', Icons.dashboard_outlined),
  appointments('Appointments', Icons.event_outlined, [
    SubView('appointments', 'Appointments'),
    SubView('calendar', 'Calendar'),
    SubView('workflow', 'Workflow'),
  ]),
  team('Team', Icons.group_outlined),
  catalog('Catalog', Icons.inventory_2_outlined),
  analytics('Analytics', Icons.insights_outlined),
  report('Report', Icons.description_outlined),
  settings('Settings', Icons.settings_outlined, [
    SubView('general', 'General'),
    SubView('jotform', 'Jotform'),
    SubView('jotform-integration', 'Jotform Integration'),
  ]);

  final String label;
  final IconData icon;
  final List<SubView> subViews;

  const AppSection(this.label, this.icon, [this.subViews = const []]);

  bool get hasTabs => subViews.length > 1;

  String? get defaultSubViewId => subViews.isEmpty ? null : subViews.first.id;
}

final selectedSectionProvider =
    StateProvider<AppSection>((ref) => AppSection.dashboard);

/// The selected sub-view of each section (remembered while switching sections).
final sectionSubViewProvider =
    StateProvider.family<String?, AppSection>((ref, section) => section.defaultSubViewId);

/// Jumps to a sub-view of a section, e.g. from a "configure" link in another view.
void navigateTo(WidgetRef ref, AppSection section, [String? subViewId]) {
  if (subViewId != null) {
    ref.read(sectionSubViewProvider(section).notifier).state = subViewId;
  }
  ref.read(selectedSectionProvider.notifier).state = section;
}
