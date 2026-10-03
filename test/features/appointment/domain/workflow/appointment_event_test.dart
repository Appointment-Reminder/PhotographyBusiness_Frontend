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

  group('eventForMove', () {
    const c = WorkflowColumn.values;
    test('each adjacent forward move fires its event', () {
      expect(eventForMove(WorkflowColumn.needsAssignment, WorkflowColumn.scheduled),
          AppointmentEvent.assign);
      expect(eventForMove(WorkflowColumn.scheduled, WorkflowColumn.pendingSelection),
          AppointmentEvent.photoshoot);
      expect(eventForMove(WorkflowColumn.pendingSelection, WorkflowColumn.pendingEditing),
          AppointmentEvent.selection);
      expect(eventForMove(WorkflowColumn.pendingEditing, WorkflowColumn.pendingReview),
          AppointmentEvent.editing);
      expect(eventForMove(WorkflowColumn.pendingReview, WorkflowColumn.completed),
          AppointmentEvent.review);
    });

    test('Pending Editing back to Pending Selection removes the selection', () {
      expect(eventForMove(WorkflowColumn.pendingEditing, WorkflowColumn.pendingSelection),
          AppointmentEvent.removeSelection);
    });

    test('every other pair is invalid', () {
      const valid = {
        (WorkflowColumn.needsAssignment, WorkflowColumn.scheduled),
        (WorkflowColumn.scheduled, WorkflowColumn.pendingSelection),
        (WorkflowColumn.pendingSelection, WorkflowColumn.pendingEditing),
        (WorkflowColumn.pendingEditing, WorkflowColumn.pendingReview),
        (WorkflowColumn.pendingReview, WorkflowColumn.completed),
        (WorkflowColumn.pendingEditing, WorkflowColumn.pendingSelection),
      };
      for (final from in c) {
        for (final to in c) {
          if (valid.contains((from, to))) continue;
          expect(eventForMove(from, to), isNull, reason: '$from -> $to');
        }
      }
    });

    test('skipping, into Needs Assignment, and Review to Editing are invalid', () {
      expect(eventForMove(WorkflowColumn.scheduled, WorkflowColumn.pendingEditing), isNull);
      expect(eventForMove(WorkflowColumn.scheduled, WorkflowColumn.needsAssignment), isNull);
      expect(eventForMove(WorkflowColumn.pendingReview, WorkflowColumn.pendingEditing), isNull);
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
