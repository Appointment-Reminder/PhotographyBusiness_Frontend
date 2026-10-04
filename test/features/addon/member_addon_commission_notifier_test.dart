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
  Future<Either<Failure, AddonCommission>> getMemberAddonCommission({
    required int addonId,
    required int memberId,
  }) async {
    calls.add('get $memberId/$addonId');
    if (failRead) return const Left(ServerFailure('boom'));
    // The backend answers a flat 0 when the member has none.
    return Right(commissions['$memberId/$addonId'] ?? flat0(memberId, addonId));
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
      id: 1,
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

    test('a failing add-on listing is shown as an error', () async {
      repo.failListing = true;

      await notifier.loadForMember(businessId: 7, memberId: 5);

      expect(notifier.state.error, 'no access');
    });

    test('switching Member reads that Member\'s commissions', () async {
      repo.addons = [addon(1)];
      await notifier.loadForMember(businessId: 7, memberId: 5);
      repo.calls.clear();

      await notifier.loadForMember(businessId: 7, memberId: 6);

      expect(repo.calls, contains('get 6/1'));
    });
  });

  group('save', () {
    setUp(() async {
      repo.addons = [addon(1)];
      await notifier.loadForMember(businessId: 7, memberId: 5);
    });

    test('posts a new version effective now and shows it', () async {
      final before = DateTime.now();

      final error = await notifier.save(memberId: 5, addonId: 1, value: '15', isPercentage: true);

      expect(error, isNull);
      expect(repo.calls, contains('create 5/1 15 %'));
      expect(repo.lastEffectiveFrom!.isBefore(before), isFalse);
      final c = notifier.state.commissionFor(5, 1);
      expect((c.commissionAmount, c.commissionIsPercentage), (15, true));
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
