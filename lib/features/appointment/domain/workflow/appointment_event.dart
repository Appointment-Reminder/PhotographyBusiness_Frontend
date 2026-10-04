import 'workflow_column.dart';

/// Appointment Events accepted by
/// `POST /appointments/business/{id}/appointments/{id}/{event}`. The backend
/// owns legality; `resultingStatus` is only used for optimistic UI.
enum AppointmentEvent {
  photoshoot('photoshoot', 'pending_selection'),
  selection('selection', 'pending_editing'),
  editing('editing', 'pending_review'),
  review('review', 'completed'),
  removeSelection('remove_selection', 'pending_selection'),
  canceled('canceled', 'canceled'),
  refund('refund', 'refunded');

  /// Path segment sent to the backend.
  final String wireName;

  /// Appointment Status the backend moves the Appointment to.
  final String resultingStatus;

  const AppointmentEvent(this.wireName, this.resultingStatus);
}

const _closeOutStatuses = {
  'new',
  'needs_assignment',
  'pending',
  'pending_selection',
  'pending_editing',
  'pending_review',
  'completed',
};

/// Whether the Cancel and Refund drop zones accept an Appointment in
/// [status]. Cancel and refund are independent events; neither is legal from
/// `canceled` or `refunded`.
bool canCancelOrRefund(String status) => _closeOutStatuses.contains(status);

/// The forward event fired by a card's Advance button in [column], or null
/// when the button does not fire a plain event (Needs Assignment opens the
/// member picker; Completed has none).
AppointmentEvent? advanceEventFor(WorkflowColumn column) {
  switch (column) {
    case WorkflowColumn.scheduled:
      return AppointmentEvent.photoshoot;
    case WorkflowColumn.pendingSelection:
      return AppointmentEvent.selection;
    case WorkflowColumn.pendingEditing:
      return AppointmentEvent.editing;
    case WorkflowColumn.pendingReview:
      return AppointmentEvent.review;
    case WorkflowColumn.needsAssignment:
    case WorkflowColumn.completed:
      return null;
  }
}

/// True for the Needs Assignment -> Scheduled drop. It fires no Appointment
/// Event: it opens the member picker, and the backend moves the status when
/// the member is saved.
bool isAssignMove(WorkflowColumn from, WorkflowColumn to) =>
    from == WorkflowColumn.needsAssignment && to == WorkflowColumn.scheduled;

/// The Appointment Event fired when a card is dropped from [from] onto [to],
/// or null when the move fires none: invalid moves (skipping columns, into
/// Needs Assignment, Pending Review back to Pending Editing, onto the same
/// column) and the assign move ([isAssignMove]).
AppointmentEvent? eventForMove(WorkflowColumn from, WorkflowColumn to) {
  if (from == WorkflowColumn.pendingEditing &&
      to == WorkflowColumn.pendingSelection) {
    return AppointmentEvent.removeSelection;
  }
  final order = WorkflowColumn.allColumns;
  if (order.indexOf(to) != order.indexOf(from) + 1) return null;
  return advanceEventFor(from);
}

/// Button label for a card's Advance button in [column].
String? advanceLabelFor(WorkflowColumn column) {
  switch (column) {
    case WorkflowColumn.scheduled:
      return 'Mark shot';
    case WorkflowColumn.pendingSelection:
      return 'Mark selected';
    case WorkflowColumn.pendingEditing:
      return 'Mark edited';
    case WorkflowColumn.pendingReview:
      return 'Mark reviewed';
    case WorkflowColumn.needsAssignment:
    case WorkflowColumn.completed:
      return null;
  }
}
