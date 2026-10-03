import 'package:flutter_test/flutter_test.dart';
import 'package:photography_business_frontend/features/appointment/domain/workflow/workflow_board.dart';
import 'package:photography_business_frontend/features/appointment/domain/workflow/workflow_column.dart';
import 'package:photography_business_frontend/features/appointment/domain/workflow/workflow_viewer.dart';
import 'package:photography_business_frontend/features/business/domain/entities/business_member.dart';

import 'workflow_board_test.dart' show appt;

BusinessMember memberWithRole(int id, String role) => BusinessMember(
      id: id,
      businessId: 1,
      userId: id + 100,
      role: role,
      invitedAt: DateTime(2026, 1, 1),
      isActive: true,
      createdAt: DateTime(2026, 1, 1),
    );

WorkflowBoard boardFor(WorkflowViewer viewer, {bool showClosed = false}) =>
    WorkflowBoard.build(
      appointments: [
        appt(id: 1, status: 'needs_assignment'),
        appt(id: 2, status: 'pending', memberId: 5),
        appt(id: 3, status: 'pending_editing', memberId: 6),
        appt(id: 4, status: 'pending_review', memberId: 5),
        appt(id: 5, status: 'completed', memberId: 5),
        appt(id: 6, status: 'completed', memberId: 6),
      ],
      packagesById: const {},
      membersById: const {},
      viewer: viewer,
      showClosed: showClosed,
    );

Iterable<int> allIds(WorkflowBoard b) =>
    b.columns.expand((c) => b.cardsIn(c)).map((c) => c.appointmentId);

void main() {
  group('viewer from member', () {
    test('owner and admin manage the whole board', () {
      for (final role in ['owner', 'admin']) {
        final v = WorkflowViewer.fromMember(memberWithRole(5, role));
        expect(v.canSeeAll, isTrue, reason: role);
        expect(v.canAssign, isTrue, reason: role);
        expect(v.showsFiltersAndLegend, isTrue, reason: role);
      }
    });

    test('photographer and assistant are scoped to their own member id', () {
      for (final role in ['photographer', 'assistant']) {
        final v = WorkflowViewer.fromMember(memberWithRole(5, role));
        expect(v.canSeeAll, isFalse, reason: role);
        expect(v.canAssign, isFalse, reason: role);
        expect(v.showsFiltersAndLegend, isFalse, reason: role);
        expect(v.memberId, 5, reason: role);
      }
    });

    test('an unresolved member gets the restricted, nothing-owned view', () {
      final v = WorkflowViewer.fromMember(null);
      expect(v.canSeeAll, isFalse);
      expect(v.canAssign, isFalse);
      expect(allIds(boardFor(v)), isEmpty);
    });
  });

  group('resolve', () {
    final members = [memberWithRole(5, 'photographer')]; // userId 105

    test('the business owner is a manager even without a member row', () {
      final v = WorkflowViewer.resolve(
          userId: 1, businessOwnerId: 1, members: const []);
      expect(v.canSeeAll, isTrue);
    });

    test('other users resolve through their member row', () {
      final v = WorkflowViewer.resolve(
          userId: 105, businessOwnerId: 1, members: members);
      expect(v.memberId, 5);
      expect(v.canSeeAll, isFalse);
    });

    test('no signed-in user or no member row is unresolved', () {
      expect(
          WorkflowViewer.resolve(
                  userId: null, businessOwnerId: 1, members: members)
              .isUnresolved,
          isTrue);
      expect(
          WorkflowViewer.resolve(
                  userId: 999, businessOwnerId: 1, members: members)
              .isUnresolved,
          isTrue);
    });
  });

  group('board scoping', () {
    test('owner/admin see every appointment and the Needs Assignment column', () {
      final board = boardFor(WorkflowViewer.fromMember(memberWithRole(9, 'admin')));
      expect(board.columns, WorkflowColumn.openColumns);
      expect(allIds(board).toSet(), {1, 2, 3, 4});
    });

    test('photographer sees only their own appointments', () {
      final board = boardFor(WorkflowViewer.fromMember(memberWithRole(5, 'photographer')));
      expect(allIds(board).toSet(), {2, 4});
    });

    test('photographer has no Needs Assignment column', () {
      final board = boardFor(WorkflowViewer.fromMember(memberWithRole(5, 'assistant')));
      expect(board.columns, isNot(contains(WorkflowColumn.needsAssignment)));
      expect(board.columns.first, WorkflowColumn.scheduled);
    });

    test('scoping also applies to the completed column when shown', () {
      final board = boardFor(
        WorkflowViewer.fromMember(memberWithRole(5, 'photographer')),
        showClosed: true,
      );
      expect(board.cardsIn(WorkflowColumn.completed).map((c) => c.appointmentId), [5]);
    });

    test('totals only count visible cards', () {
      final board = boardFor(WorkflowViewer.fromMember(memberWithRole(5, 'photographer')));
      expect(board.totalCount, 2);
    });

    test("manager filter by member shows only that member's cards", () {
      final board = WorkflowBoard.build(
        appointments: [
          appt(id: 1, status: 'needs_assignment'),
          appt(id: 2, status: 'pending', memberId: 5),
          appt(id: 3, status: 'pending_editing', memberId: 6),
        ],
        packagesById: const {},
        membersById: const {},
        viewer: WorkflowViewer.manager,
        filterMemberId: 5,
      );
      expect(allIds(board).toSet(), {2});
    });

    test('a restricted viewer cannot widen their board with a filter', () {
      final board = WorkflowBoard.build(
        appointments: [
          appt(id: 2, status: 'pending', memberId: 5),
          appt(id: 3, status: 'pending_editing', memberId: 6),
        ],
        packagesById: const {},
        membersById: const {},
        viewer: WorkflowViewer.fromMember(memberWithRole(5, 'photographer')),
        filterMemberId: 6,
      );
      expect(allIds(board).toSet(), {2});
    });

    test('unresolved restricted viewer is flagged', () {
      expect(WorkflowViewer.fromMember(null).isUnresolved, isTrue);
      expect(WorkflowViewer.manager.isUnresolved, isFalse);
      expect(
          WorkflowViewer.fromMember(memberWithRole(5, 'photographer'))
              .isUnresolved,
          isFalse);
    });
  });
}
