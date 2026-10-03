import 'package:flutter_test/flutter_test.dart';
import 'package:photography_business_frontend/features/appointment/domain/workflow/appointment_event.dart';
import 'package:photography_business_frontend/features/appointment/domain/workflow/workflow_column.dart';

void main() {
  group('advanceEventFor', () {
    test('each column maps to the next forward event', () {
      expect(advanceEventFor(WorkflowColumn.scheduled),
          AppointmentEvent.photoshoot);
      expect(advanceEventFor(WorkflowColumn.pendingSelection),
          AppointmentEvent.selection);
      expect(advanceEventFor(WorkflowColumn.pendingEditing),
          AppointmentEvent.editing);
      expect(advanceEventFor(WorkflowColumn.pendingReview),
          AppointmentEvent.review);
    });

    test('Needs Assignment (ticket 04) and Completed have no plain advance',
        () {
      expect(advanceEventFor(WorkflowColumn.needsAssignment), isNull);
      expect(advanceEventFor(WorkflowColumn.completed), isNull);
    });
  });

  group('AppointmentEvent', () {
    test('wire names match the backend path segment', () {
      expect(AppointmentEvent.photoshoot.wireName, 'photoshoot');
      expect(AppointmentEvent.selection.wireName, 'selection');
      expect(AppointmentEvent.editing.wireName, 'editing');
      expect(AppointmentEvent.review.wireName, 'review');
      expect(AppointmentEvent.removeSelection.wireName, 'remove_selection');
    });

    test('resulting status follows the backend transition table', () {
      expect(AppointmentEvent.photoshoot.resultingStatus, 'pending_selection');
      expect(AppointmentEvent.selection.resultingStatus, 'pending_editing');
      expect(AppointmentEvent.editing.resultingStatus, 'pending_review');
      expect(AppointmentEvent.review.resultingStatus, 'completed');
      expect(AppointmentEvent.assign.resultingStatus, 'pending');
      expect(
          AppointmentEvent.removeSelection.resultingStatus, 'pending_selection');
    });
  });
}
