import 'package:flutter_test/flutter_test.dart';
import 'package:photography_business_frontend/features/appointment/domain/workflow/workflow_column.dart';

void main() {
  group('workflowColumnForStatus', () {
    test('maps each open status to its column', () {
      expect(workflowColumnForStatus('needs_assignment'), WorkflowColumn.needsAssignment);
      expect(workflowColumnForStatus('pending'), WorkflowColumn.scheduled);
      expect(workflowColumnForStatus('pending_selection'), WorkflowColumn.pendingSelection);
      expect(workflowColumnForStatus('pending_editing'), WorkflowColumn.pendingEditing);
      expect(workflowColumnForStatus('pending_review'), WorkflowColumn.pendingReview);
    });

    test('new lands in Needs Assignment', () {
      expect(workflowColumnForStatus('new'), WorkflowColumn.needsAssignment);
    });

    test('completed maps to the closed column', () {
      expect(workflowColumnForStatus('completed'), WorkflowColumn.completed);
    });

    test('canceled, refunded and unknown statuses have no column', () {
      expect(workflowColumnForStatus('canceled'), isNull);
      expect(workflowColumnForStatus('refunded'), isNull);
      expect(workflowColumnForStatus('mystery'), isNull);
    });
  });

  test('open columns are ordered left to right and exclude completed', () {
    expect(WorkflowColumn.openColumns, [
      WorkflowColumn.needsAssignment,
      WorkflowColumn.scheduled,
      WorkflowColumn.pendingSelection,
      WorkflowColumn.pendingEditing,
      WorkflowColumn.pendingReview,
    ]);
    expect(WorkflowColumn.needsAssignment.label, 'Needs Assignment');
    expect(WorkflowColumn.scheduled.label, 'Scheduled');
  });
}
