import 'package:equatable/equatable.dart';
import 'package:photography_business_frontend/features/business/domain/entities/business_member.dart';
import 'package:photography_business_frontend/features/business/domain/entities/business_role.dart';

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
    return WorkflowViewer(
      memberId: member?.id,
      canSeeAll: BusinessRole.isManager(member?.role),
    );
  }

  /// Resolves the viewer from the signed-in user. The business owner always
  /// counts as owner; otherwise the user's BusinessMember decides, and an
  /// unresolved member gets the restricted view.
  factory WorkflowViewer.resolve({
    required int? userId,
    required int? businessOwnerId,
    required List<BusinessMember> members,
  }) {
    if (userId == null) return WorkflowViewer.fromMember(null);
    if (businessOwnerId == userId) return manager;
    final mine = members.where((m) => m.userId == userId);
    return WorkflowViewer.fromMember(mine.isEmpty ? null : mine.first);
  }

  bool get canAssign => canSeeAll;
  bool get showsFiltersAndLegend => canSeeAll;

  /// A restricted viewer whose member id could not be resolved: the board is
  /// empty because we cannot tell which Appointments are theirs.
  bool get isUnresolved => !canSeeAll && memberId == null;

  @override
  List<Object?> get props => [memberId, canSeeAll];
}
