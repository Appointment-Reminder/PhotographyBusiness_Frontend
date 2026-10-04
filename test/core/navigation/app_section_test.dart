import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photography_business_frontend/core/Presentation/navigation/app_section.dart';

void main() {
  test('sidebar order is fixed', () {
    expect(AppSection.values.map((s) => s.label), [
      'Dashboard', 'Appointments', 'Team', 'Catalog', 'Analytics', 'Report', 'Settings',
    ]);
  });

  test('only Appointments and Settings show tabs', () {
    expect(AppSection.values.where((s) => s.hasTabs),
        [AppSection.appointments, AppSection.settings]);
  });

  test('each section starts on its first sub-view', () {
    final c = ProviderContainer();
    addTearDown(c.dispose);
    expect(c.read(selectedSectionProvider), AppSection.dashboard);
    expect(c.read(sectionSubViewProvider(AppSection.appointments)), SubView.appointmentList);
    expect(c.read(sectionSubViewProvider(AppSection.team)), isNull);
  });
}
