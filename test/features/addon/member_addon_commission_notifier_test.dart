import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import 'package:photography_business_frontend/features/addon/domain/entities/addon.dart';
import 'package:photography_business_frontend/features/addon/domain/entities/addon_commission.dart';
import 'package:photography_business_frontend/features/addon/domain/repositories/addon_repository.dart';
import 'package:photography_business_frontend/features/addon/presentation/providers/notifiers/member_addon_commission_notifier.dart';

class FakeAddonRepository implements AddonRepository {
  final calls = <String>[];
  List<Addon> addons = [];
  // "memberId/addonId" -> commission the backend has in effect
  final Map<String, AddonCommission> commissions = {};
  bool failListing = false;
  bool failRead = false;
  bool failSave = false;

  @override
  Future<Either<Failure, List<Addon>>> getAddons(int businessId) async {
    calls.add('list $businessId');
    return failListing ? const Left(ServerFailure('no access')) : Right(addons);
  }

  @override
  Future<Either<Failure, List<AddonCommission>>> listMemberAddonCommissions({
    required int businessId,
    required int memberId,
  }) async {
    calls.add('list-commissions $businessId/$memberId');
    if (failRead) return const Left(ServerFailure('boom'));
    // The backend answers every active Add-on, a flat 0 (null id) where the
    // member has none.
    return Right([
      for (final a in addons)
        if (a.isActive) commissions['$memberId/${a.id}'] ?? flat0(memberId, a.id),
    ]);
  }

  @override
  Future<Either<Failure, AddonCommission>> updateAddonCommission({
    required int id,
    required int commissionAmount,
    required bool commissionIsPercentage,
  }) async {
    calls.add('update $id $commissionAmount ${commissionIsPercentage ? '%' : 'EUR'}');
    if (failSave) return const Left(ServerFailure('save refused'));
    final key = commissions.keys.firstWhere((k) => commissions[k]!.id == id);
    final old = commissions[key]!;
    final c = AddonCommission(
      id: id,
      businessMemberId: old.businessMemberId,
      addonId: old.addonId,
      commissionAmount: commissionAmount,
      commissionIsPercentage: commissionIsPercentage,
      effectiveFrom: old.effectiveFrom,
    );
    commissions[key] = c;
    return Right(c);
  }

  @override
  Future<Either<Failure, AddonCommission>> createAddonCommission({
    required int memberId,
    required int addonId,
    required int commissionAmount,
    required bool commissionIsPercentage,
    required DateTime effectiveFrom,
  }) async {
    calls.add('create $memberId/$addonId $commissionAmount ${commissionIsPercentage ? '%' : 'EUR'}');
    if (failSave) return const Left(ServerFailure('save refused'));
    final c = AddonCommission(
      id: nextId++,
      businessMemberId: memberId,
      addonId: addonId,
      commissionAmount: commissionAmount,
      commissionIsPercentage: commissionIsPercentage,
      effectiveFrom: effectiveFrom,
    );
    commissions['$memberId/$addonId'] = c;
    lastEffectiveFrom = effectiveFrom;
    return Right(c);
  }

  DateTime? lastEffectiveFrom;
  int nextId = 100;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

AddonCommission flat0(int memberId, int addonId) => AddonCommission(
      businessMemberId: memberId,
      addonId: addonId,
      commissionAmount: 0,
      commissionIsPercentage: false,
      effectiveFrom: DateTime(2020),
    );

Addon addon(int id, {bool active = true}) => Addon(
      id: id,
      businessId: 7,
      name: 'A$id',
      jotformAlias: 'a$id',
      isActive: active,
      hasDuration: false,
      hasQuantity: false,
    );

void main() {
  late FakeAddonRepository repo;
  late MemberAddonCommissionNotifier notifier;

  setUp(() {
    repo = FakeAddonRepository();
    notifier = MemberAddonCommissionNotifier(repository: repo);
  });

  group('load', () {
    test('lists every active Add-on, none inactive, with a missing commission as flat 0', () async {
      repo.addons = [addon(1), addon(2, active: false), addon(3)];
      repo.commissions['5/3'] = AddonCommission(
        id: 4,
        businessMemberId: 5,
        addonId: 3,
        commissionAmount: 20,
        commissionIsPercentage: true,
        effectiveFrom: DateTime(2026),
      );

      await notifier.loadForMember(businessId: 7, memberId: 5);

      expect(notifier.state.addons.map((a) => a.id), [1, 3]);
      final none = notifier.state.commissionFor(5, 1);
      expect(none.commissionAmount, 0);
      expect(none.commissionIsPercentage, isFalse);
      final set = notifier.state.commissionFor(5, 3);
      expect((set.commissionAmount, set.commissionIsPercentage), (20, true));
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.error, isNull);
    });

    test('shows flat 0 for a Member whose commissions are not loaded yet', () {
      final c = notifier.state.commissionFor(9, 1);
      expect((c.commissionAmount, c.commissionIsPercentage), (0, false));
    });

    test('a failing commission read is shown as an error', () async {
      repo.addons = [addon(1)];
      repo.failRead = true;

      await notifier.loadForMember(businessId: 7, memberId: 5);

      expect(notifier.state.error, 'boom');
      expect(notifier.state.isLoading, isFalse);
    });

      test('a failed reload drops the earlier values of that Member instead of showing stale ones', () async {
      repo.addons = [addon(1)];
      repo.commissions['5/1'] = AddonCommission(
        id: 4,
        businessMemberId: 5,
        addonId: 1,
        commissionAmount: 20,
        commissionIsPercentage: true,
        effectiveFrom: DateTime(2026),
      );
      await notifier.loadForMember(businessId: 7, memberId: 5);
      repo.failRead = true;

      await notifier.loadForMember(businessId: 7, memberId: 5);

      expect(notifier.state.error, 'boom');
      expect(notifier.state.commissions[5], isNull);
    });

    test('a failing add-on listing is shown as an error', () async {
      repo.failListing = true;

      await notifier.loadForMember(businessId: 7, memberId: 5);

      expect(notifier.state.error, 'no access');
    });

    test('switching Member reads the new Member commissions in one call', () async {
      repo.addons = [addon(1), addon(2)];
      await notifier.loadForMember(businessId: 7, memberId: 5);
      repo.calls.clear();

      await notifier.loadForMember(businessId: 7, memberId: 6);

      expect(repo.calls.where((c) => c.startsWith('list-commissions')), ['list-commissions 7/6']);
    });
  });

  group('save', () {
    setUp(() async {
      repo.addons = [addon(1)];
      await notifier.loadForMember(businessId: 7, memberId: 5);
    });

    test('with no commission yet, posts a first version effective now and shows it', () async {
      final before = DateTime.now();

      final error = await notifier.save(memberId: 5, addonId: 1, value: '15', isPercentage: true);

      expect(error, isNull);
      expect(repo.calls, contains('create 5/1 15 %'));
      expect(repo.lastEffectiveFrom!.isBefore(before), isFalse);
      final c = notifier.state.commissionFor(5, 1);
      expect((c.commissionAmount, c.commissionIsPercentage), (15, true));
    });

    test('a Member with no commission yet gets a new version; one with a '
        'commission has it corrected in place, never a new version', () async {
      await notifier.save(memberId: 5, addonId: 1, value: '10', isPercentage: false);
      repo.calls.clear();

      final error = await notifier.save(memberId: 5, addonId: 1, value: '12', isPercentage: true);

      expect(error, isNull);
      expect(repo.calls, ['update 100 12 %']);
      final c = notifier.state.commissionFor(5, 1);
      expect((c.commissionAmount, c.commissionIsPercentage), (12, true));
    });

    test('a commission loaded with an id is corrected in place', () async {
      repo.commissions['5/1'] = AddonCommission(
        id: 4,
        businessMemberId: 5,
        addonId: 1,
        commissionAmount: 20,
        commissionIsPercentage: true,
        effectiveFrom: DateTime(2026),
      );
      await notifier.loadForMember(businessId: 7, memberId: 5);
      repo.calls.clear();

      await notifier.save(memberId: 5, addonId: 1, value: '25', isPercentage: true);

      expect(repo.calls, ['update 4 25 %']);
    });

    test('rejects non-numeric and negative values without calling the backend', () async {
      for (final bad in ['abc', '', '-3', '1.5']) {
        final error = await notifier.save(memberId: 5, addonId: 1, value: bad, isPercentage: false);
        expect(error, isNotNull, reason: bad);
      }
      expect(repo.calls.where((c) => c.startsWith('create')), isEmpty);
      expect(notifier.state.commissionFor(5, 1).commissionAmount, 0);
    });

    test('on failure shows the error and keeps the previous value', () async {
      await notifier.save(memberId: 5, addonId: 1, value: '10', isPercentage: false);
      repo.failSave = true;

      final error = await notifier.save(memberId: 5, addonId: 1, value: '99', isPercentage: false);

      expect(error, 'save refused');
      expect(notifier.state.error, 'save refused');
      expect(notifier.state.commissionFor(5, 1).commissionAmount, 10);
    });
  });
}
