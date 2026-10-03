/// Workflow Board columns. The single place where Appointment Status strings
/// are mapped to a column.
enum WorkflowColumn {
  needsAssignment('Needs Assignment', 'Unassigned shoots'),
  scheduled('Scheduled', 'Assigned, awaiting the shoot'),
  pendingSelection('Pending Selection', 'Awaiting client pick'),
  pendingEditing('Pending Editing', 'In post-production'),
  pendingReview('Pending Review', 'Ready for final check'),
  completed('Completed', 'Closed shoots');

  final String label;
  final String description;
  const WorkflowColumn(this.label, this.description);

  /// Columns always shown, left to right.
  static const openColumns = [
    needsAssignment,
    scheduled,
    pendingSelection,
    pendingEditing,
    pendingReview,
  ];

  /// Columns shown when the "Show closed" toggle is on.
  static const allColumns = [...openColumns, completed];
}

/// Returns the column an Appointment Status belongs to, or null when it has
/// none (`canceled`, `refunded`, unknown). `new` is treated like
/// `needs_assignment` defensively.
WorkflowColumn? workflowColumnForStatus(String status) {
  switch (status) {
    case 'new':
    case 'needs_assignment':
      return WorkflowColumn.needsAssignment;
    case 'pending':
      return WorkflowColumn.scheduled;
    case 'pending_selection':
      return WorkflowColumn.pendingSelection;
    case 'pending_editing':
      return WorkflowColumn.pendingEditing;
    case 'pending_review':
      return WorkflowColumn.pendingReview;
    case 'completed':
      return WorkflowColumn.completed;
    default:
      return null;
  }
}
