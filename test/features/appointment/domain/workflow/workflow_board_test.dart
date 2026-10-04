import 'package:flutter_test/flutter_test.dart';
import 'package:photography_business_frontend/features/appointment/domain/entities/appointment.dart';
import 'package:photography_business_frontend/features/appointment/domain/workflow/workflow_board.dart';
import 'package:photography_business_frontend/features/appointment/domain/workflow/workflow_column.dart';
import 'package:photography_business_frontend/features/business/domain/entities/business_member.dart';
import 'package:photography_business_frontend/features/package/domain/entities/package.dart';

Appointment appt({
  required int id,
  String status = 'pending',
  int? memberId,
  int? packageId,
  String first = 'Martine',
  String last = 'Dupont',
  DateTime? date,
}) =>
    Appointment(
      id: id,
      businessId: 1,
      memberId: memberId,
      formId: null,
      packageId: packageId,
      clientFirstName: first,
      clientLastName: last,
      appointmentDate: date ?? DateTime(2026, 10, 2),
      status: status,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

BusinessMember member(int id, String? name, {String? email}) => BusinessMember(
      id: id,
      businessId: 1,
      userId: id + 100,
      role: 'photographer',
      invitedAt: DateTime(2026, 1, 1),
      isActive: true,
      createdAt: DateTime(2026, 1, 1),
      userName: name,
      userEmail: email,
    );

Package pkg(int id, String name) => Package(
      id: id,
      businessId: 1,
      categoryId: 1,
      name: name,
      description: '',
      isActive: true,
    );

WorkflowBoard build(
  List<Appointment> list, {
  Map<int, Package> packages = const {},
  Map<int, BusinessMember> members = const {},
  bool showClosed = false,
}) =>
    WorkflowBoard.build(
      appointments: list,
      packagesById: packages,
      membersById: members,
      showClosed: showClosed,
    );

void main() {
  group('columns', () {
    test('lists the five open columns in order by default', () {
      final board = build([]);
      expect(board.columns, WorkflowColumn.openColumns);
    });

    test('Show closed adds the completed column', () {
      final board = build([], showClosed: true);
      expect(board.columns.last, WorkflowColumn.completed);
      expect(board.columns.length, 6);
    });
  });

  group('grouping', () {
    test('places cards by status, with new in Needs Assignment', () {
      final board = build([
        appt(id: 1, status: 'new'),
        appt(id: 2, status: 'needs_assignment'),
        appt(id: 3, status: 'pending'),
        appt(id: 4, status: 'pending_review'),
      ]);
      expect(board.cardsIn(WorkflowColumn.needsAssignment).map((c) => c.appointmentId), [1, 2]);
      expect(board.cardsIn(WorkflowColumn.scheduled).map((c) => c.appointmentId), [3]);
      expect(board.cardsIn(WorkflowColumn.pendingReview).map((c) => c.appointmentId), [4]);
      expect(board.cardsIn(WorkflowColumn.pendingEditing), isEmpty);
    });

    test('never shows canceled or refunded', () {
      final board = build([
        appt(id: 1, status: 'canceled'),
        appt(id: 2, status: 'refunded'),
      ], showClosed: true);
      expect(board.totalCount, 0);
    });

    test('completed cards only appear when showClosed is on', () {
      final list = [appt(id: 1, status: 'completed')];
      expect(build(list).totalCount, 0);
      expect(build(list, showClosed: true).cardsIn(WorkflowColumn.completed).length, 1);
    });

    test('cards in a column are ordered by date ascending', () {
      final board = build([
        appt(id: 1, date: DateTime(2026, 10, 9)),
        appt(id: 2, date: DateTime(2026, 10, 1)),
      ]);
      expect(board.cardsIn(WorkflowColumn.scheduled).map((c) => c.appointmentId), [2, 1]);
    });

    test('count and totalCount reflect visible cards', () {
      final board = build([
        appt(id: 1, status: 'pending'),
        appt(id: 2, status: 'pending'),
        appt(id: 3, status: 'pending_editing'),
      ]);
      expect(board.countIn(WorkflowColumn.scheduled), 2);
      expect(board.totalCount, 3);
    });
  });

  group('card data', () {
    test('client name and date come from the appointment', () {
      final card = build([appt(id: 1, date: DateTime(2026, 10, 2))])
          .cardsIn(WorkflowColumn.scheduled)
          .single;
      expect(card.clientName, 'Martine Dupont');
      expect(card.date, DateTime(2026, 10, 2));
    });

    test('package badge uses the real package name', () {
      final card = build([appt(id: 1, packageId: 7)], packages: {7: pkg(7, 'Family')})
          .cardsIn(WorkflowColumn.scheduled)
          .single;
      expect(card.packageLabel, 'Family');
    });

    test('package badge is a dash without package, or when package is unknown', () {
      final board = build([appt(id: 1), appt(id: 2, packageId: 99)]);
      final labels = board.cardsIn(WorkflowColumn.scheduled).map((c) => c.packageLabel);
      expect(labels, ['—', '—']);
    });

    test('long package names are truncated with an ellipsis', () {
      final card = build(
        [appt(id: 1, packageId: 7)],
        packages: {7: pkg(7, 'Premium Wedding Full Day Coverage')},
      ).cardsIn(WorkflowColumn.scheduled).single;
      expect(card.packageLabel.length, lessThanOrEqualTo(WorkflowCard.maxPackageLabelLength));
      expect(card.packageLabel.endsWith('…'), isTrue);
      expect(card.packageLabel.startsWith('Premium'), isTrue);
    });

    test('photographer initials come from the member name', () {
      final card = build(
        [appt(id: 1, memberId: 3)],
        members: {3: member(3, 'Léa Moreau')},
      ).cardsIn(WorkflowColumn.scheduled).single;
      expect(card.memberId, 3);
      expect(card.photographerInitials, 'LM');
    });

    test('single-word names give one initial; missing names fall back to email then ?', () {
      WorkflowCard cardFor(BusinessMember m) =>
          build([appt(id: 1, memberId: m.id)], members: {m.id: m})
              .cardsIn(WorkflowColumn.scheduled)
              .single;
      expect(cardFor(member(1, 'camille')).photographerInitials, 'C');
      expect(cardFor(member(2, null, email: 'jules@x.com')).photographerInitials, 'J');
      expect(cardFor(member(3, null)).photographerInitials, '?');
    });

    test('unassigned card has no photographer initials', () {
      final card = build([appt(id: 1)]).cardsIn(WorkflowColumn.scheduled).single;
      expect(card.memberId, isNull);
      expect(card.photographerInitials, isNull);
    });

    test('assigned to a member not in the list still keeps the member id', () {
      final card = build([appt(id: 1, memberId: 42)]).cardsIn(WorkflowColumn.scheduled).single;
      expect(card.memberId, 42);
      expect(card.photographerInitials, '?');
    });
  });
}
