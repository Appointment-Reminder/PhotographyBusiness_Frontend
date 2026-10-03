import 'package:equatable/equatable.dart';
import 'package:photography_business_frontend/features/business/domain/entities/business_member.dart';
import 'package:photography_business_frontend/features/package/domain/entities/package.dart';
import '../entities/appointment.dart';
import 'workflow_column.dart';
import 'workflow_viewer.dart';

/// What a Workflow Board card displays. Colour is derived from `memberId`
/// in the presentation layer (see PhotographerColors).
class WorkflowCard extends Equatable {
  static const maxPackageLabelLength = 14;
  static const noPackageLabel = '—';

  final int appointmentId;
  final String clientName;
  final DateTime date;
  final String packageLabel;
  final int? memberId;

  /// Null when unassigned; '?' when assigned to a member we cannot resolve.
  final String? photographerInitials;

  const WorkflowCard({
    required this.appointmentId,
    required this.clientName,
    required this.date,
    required this.packageLabel,
    required this.memberId,
    required this.photographerInitials,
  });

  factory WorkflowCard.from(
    Appointment appointment, {
    Package? package,
    BusinessMember? member,
  }) {
    return WorkflowCard(
      appointmentId: appointment.id,
      clientName: appointment.clientName,
      date: appointment.appointmentDate,
      packageLabel: _packageLabel(package),
      memberId: appointment.memberId,
      photographerInitials:
          appointment.memberId == null ? null : _initials(member),
    );
  }

  static String _packageLabel(Package? package) {
    final name = package?.name.trim();
    if (name == null || name.isEmpty) return noPackageLabel;
    if (name.length <= maxPackageLabelLength) return name;
    return '${name.substring(0, maxPackageLabelLength - 1).trimRight()}…';
  }

  static String _initials(BusinessMember? member) {
    final source = (member?.userName?.trim().isNotEmpty ?? false)
        ? member!.userName!.trim()
        : (member?.userEmail?.trim() ?? '');
    final words =
        source.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.isEmpty) return '?';
    final letters = words.take(2).map((w) => w.substring(0, 1)).join();
    return letters.toUpperCase();
  }

  @override
  List<Object?> get props => [
        appointmentId,
        clientName,
        date,
        packageLabel,
        memberId,
        photographerInitials,
      ];
}

/// The Workflow Board: cards grouped by column.
class WorkflowBoard extends Equatable {
  final List<WorkflowColumn> columns;
  final Map<WorkflowColumn, List<WorkflowCard>> _cards;

  const WorkflowBoard._(this.columns, this._cards);

  factory WorkflowBoard.build({
    required List<Appointment> appointments,
    required Map<int, Package> packagesById,
    required Map<int, BusinessMember> membersById,
    bool showClosed = false,
    WorkflowViewer viewer = WorkflowViewer.manager,
  }) {
    final columns = (showClosed
            ? WorkflowColumn.allColumns
            : WorkflowColumn.openColumns)
        .where((c) => viewer.canAssign || c != WorkflowColumn.needsAssignment)
        .toList();
    final sorted = appointments
        .where((a) => viewer.canSeeAll ||
            (viewer.memberId != null && a.memberId == viewer.memberId))
        .toList()
      ..sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
    final cards = {for (final c in columns) c: <WorkflowCard>[]};
    for (final a in sorted) {
      final column = workflowColumnForStatus(a.status);
      if (column == null || !cards.containsKey(column)) continue;
      cards[column]!.add(WorkflowCard.from(
        a,
        package: a.packageId == null ? null : packagesById[a.packageId],
        member: a.memberId == null ? null : membersById[a.memberId],
      ));
    }
    return WorkflowBoard._(columns, cards);
  }

  List<WorkflowCard> cardsIn(WorkflowColumn column) =>
      _cards[column] ?? const [];

  int countIn(WorkflowColumn column) => cardsIn(column).length;

  int get totalCount => _cards.values.fold(0, (sum, l) => sum + l.length);

  @override
  List<Object?> get props => [columns, _cards];
}
