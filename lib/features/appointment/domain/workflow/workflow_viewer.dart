import 'package:equatable/equatable.dart';
import 'package:photography_business_frontend/features/business/domain/entities/business_member.dart';

/// Who is looking at the Workflow Board, and what their role lets them see.
/// The backend still decides on permission errors; this only hides what the
/// role cannot do.
class WorkflowViewer extends Equatable {
  /// The viewer's BusinessMember id; null when it could not be resolved.
  final int? memberId;
  final bool canSeeAll;

  const WorkflowViewer({required this.memberId, required this.canSeeAll});

  /// Owner/admin view, used where no scoping applies.
  static const manager = WorkflowViewer(memberId: null, canSeeAll: true);

  /// Owner and admin see everything; any other role, or an unresolved member,
  /// gets the restricted view.
  factory WorkflowViewer.fromMember(BusinessMember? member) {
    final role = member?.role.toLowerCase();
    return WorkflowViewer(
      memberId: member?.id,
      canSeeAll: role == 'owner' || role == 'admin',
    );
  }

  bool get canAssign => canSeeAll;
  bool get showsFiltersAndLegend => canSeeAll;

  @override
  List<Object?> get props => [memberId, canSeeAll];
}
