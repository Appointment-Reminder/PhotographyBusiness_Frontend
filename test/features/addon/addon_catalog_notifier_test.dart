import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import 'package:photography_business_frontend/features/addon/domain/entities/addon.dart';
import 'package:photography_business_frontend/features/addon/domain/entities/addon_price.dart';
import 'package:photography_business_frontend/features/addon/domain/repositories/addon_repository.dart';
import 'package:photography_business_frontend/features/addon/presentation/providers/notifiers/addon_catalog_notifier.dart';

const _fail = Left<Failure, Never>(ServerFailure('boom'));

class FakeAddonRepository implements AddonRepository {
  final calls = <String>[];
  List<Addon> addons = [];
  // addonId -> price history (as the server would answer it)
  final Map<int, List<AddonPrice>> prices = {};
  Addon? updated;
  bool failCreatePrice = false;
  bool failUpdate = false;

  @override
  Future<Either<Failure, List<Addon>>> getAddons(int businessId) async {
    calls.add('list $businessId');
    return Right(addons);
  }

  @override
  Future<Either<Failure, Addon>> createAddon({
    required int businessId,
    required String name,
    required String jotformAlias,
    required bool hasDuration,
    required int? durationMinutes,
    required bool hasQuantity,
  }) async {
    calls.add('createAddon $name');
    final a = Addon(
      id: 100,
      businessId: businessId,
      name: name,
      jotformAlias: jotformAlias,
      isActive: true,
      hasDuration: hasDuration,
      hasQuantity: hasQuantity,
      durationMinutes: durationMinutes,
    );
    addons = [...addons, a];
    return Right(a);
  }

  @override
  Future<Either<Failure, Addon>> updateAddon(Addon addon) async {
    calls.add('update ${addon.id} active=${addon.isActive} category=${addon.categoryId}');
    if (failUpdate) return _fail;
    updated = addon;
    addons = [for (final a in addons) a.id == addon.id ? addon : a];
    return Right(addon);
  }

  @override
  Future<Either<Failure, Addon>> deactivateAddon(int addonId) async {
    calls.add('deactivate $addonId');
    final a = addons.firstWhere((a) => a.id == addonId).copyWith(isActive: false);
    addons = [for (final x in addons) x.id == addonId ? a : x];
    return Right(a);
  }

  @override
  Future<Either<Failure, AddonPrice>> createAddonPrice({
    required int addonId,
    required int price,
    required DateTime effectiveFrom,
  }) async {
    calls.add('createPrice $addonId $price');
    if (failCreatePrice) return _fail;
    final p = AddonPrice(id: 1, addonId: addonId, price: price, effectiveFrom: effectiveFrom);
    prices[addonId] = [...?prices[addonId], p];
    return Right(p);
  }

  @override
  Future<Either<Failure, List<AddonPrice>>> getAddonPriceHistory(int addonId) async {
    calls.add('history $addonId');
    return Right(prices[addonId] ?? []);
  }

  @override
  Future<Either<Failure, AddonPrice>> getCurrentAddonPrice(int addonId) async {
    calls.add('current $addonId');
    final current = AddonPrice.currentOf(prices[addonId] ?? [], DateTime.now());
    return current == null ? _fail : Right(current);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Addon addon(int id,
        {String name = 'Drone', bool active = true, int? categoryId, bool hasDuration = false}) =>
    Addon(
      id: id,
      businessId: 7,
      name: name,
      jotformAlias: 'alias$id',
      isActive: active,
      categoryId: categoryId,
      hasDuration: hasDuration,
      hasQuantity: false,
    );

AddonPrice price(int id, int addonId, int amount, DateTime from) =>
    AddonPrice(id: id, addonId: addonId, price: amount, effectiveFrom: from);

void main() {
  late FakeAddonRepository repo;
  late AddonCatalogNotifier notifier;
  final past = DateTime(2020);

  setUp(() {
    repo = FakeAddonRepository();
    notifier = AddonCatalogNotifier(repository: repo);
  });

  group('load', () {
    test('lists add-ons with their current price', () async {
      repo.addons = [addon(1), addon(2, name: 'Extra hour', active: false)];
      repo.prices[1] = [price(1, 1, 80, past)];
      repo.prices[2] = [price(2, 2, 120, past)];

      await notifier.load(7);

      expect(notifier.state.addons.map((a) => a.id), [1, 2]);
      expect(notifier.state.currentPrices, {1: 80, 2: 120});
      expect(notifier.state.isLoading, isFalse);
      expect(notifier.state.error, isNull);
    });

    test('an add-on with no current price is listed without a price', () async {
      repo.addons = [addon(1), addon(2)];
      repo.prices[1] = [price(1, 1, 80, past)];
      // add-on 2: current-price endpoint fails (400)

      await notifier.load(7);

      expect(notifier.state.addons.length, 2);
      expect(notifier.state.currentPrices, {1: 80});
      expect(notifier.state.error, isNull);
    });

    test('a list failure is shown', () async {
      final failing = _FailingListRepository();
      final n = AddonCatalogNotifier(repository: failing);

      await n.load(7);

      expect(n.state.error, 'boom');
      expect(n.state.isLoading, isFalse);
    });

    test('selecting an add-on shows it and loads its price history', () async {
      repo.addons = [addon(1), addon(2)];
      repo.prices[2] = [price(1, 2, 50, past)];
      await notifier.load(7);

      await notifier.select(2);

      expect(notifier.state.selected?.id, 2);
      expect(notifier.state.history.map((p) => p.price), [50]);
    });
  });

  group('create', () {
    test('creates the add-on, then its first price, and lists both', () async {
      await notifier.load(7);

      final ok = await notifier.create(
        businessId: 7,
        name: 'Drone',
        jotformAlias: 'drone',
        hasDuration: true,
        durationMinutes: 30,
        hasQuantity: false,
        price: 90,
        effectiveFrom: past,
      );

      expect(ok, isTrue);
      expect(repo.calls.where((c) => c.startsWith('create')), ['createAddon Drone', 'createPrice 100 90']);
      expect(notifier.state.addons.map((a) => a.id), [100]);
      expect(notifier.state.currentPrices, {100: 90});
      expect(notifier.state.selected?.id, 100);
      expect(notifier.state.error, isNull);
    });

    test('when the price step fails the add-on still exists, the error is '
        'shown and only the price can be retried', () async {
      repo.failCreatePrice = true;
      await notifier.load(7);

      final ok = await notifier.create(
        businessId: 7,
        name: 'Drone',
        jotformAlias: 'drone',
        hasDuration: false,
        durationMinutes: null,
        hasQuantity: false,
        price: 90,
        effectiveFrom: past,
      );

      expect(ok, isFalse);
      expect(notifier.state.addons.map((a) => a.id), [100]);
      expect(notifier.state.error, 'boom');
      expect(notifier.state.hasPendingPrice, isTrue);

      repo.failCreatePrice = false;
      repo.calls.clear();
      await notifier.retryPrice();

      expect(repo.calls.where((c) => c.startsWith('create')), ['createPrice 100 90']);
      expect(notifier.state.hasPendingPrice, isFalse);
      expect(notifier.state.currentPrices, {100: 90});
      expect(notifier.state.error, isNull);
    });
  });

  group('update, deactivate and reactivate', () {
    test('an update sends the existing category back untouched', () async {
      repo.addons = [addon(1, categoryId: 42)];
      await notifier.load(7);

      final ok = await notifier.update(
        addonId: 1,
        name: 'Drone 4K',
        jotformAlias: 'drone4k',
        hasDuration: true,
        durationMinutes: 20,
        hasQuantity: true,
      );

      expect(ok, isTrue);
      expect(repo.calls, contains('update 1 active=true category=42'));
      expect(notifier.state.addons.single.name, 'Drone 4K');
      expect(notifier.state.addons.single.durationMinutes, 20);
    });

    test('a failed update shows the error and keeps the previous values', () async {
      repo.addons = [addon(1)];
      await notifier.load(7);
      repo.failUpdate = true;

      final ok = await notifier.update(
        addonId: 1,
        name: 'Changed',
        jotformAlias: 'x',
        hasDuration: false,
        durationMinutes: null,
        hasQuantity: false,
      );

      expect(ok, isFalse);
      expect(notifier.state.error, 'boom');
      expect(notifier.state.addons.single.name, 'Drone');
    });

    test('deactivate then reactivate follow the active flag', () async {
      repo.addons = [addon(1)];
      await notifier.load(7);

      await notifier.setActive(1, false);
      expect(repo.calls, contains('deactivate 1'));
      expect(notifier.state.addons.single.isActive, isFalse);

      await notifier.setActive(1, true);
      expect(repo.calls, contains('update 1 active=true category=null'));
      expect(notifier.state.addons.single.isActive, isTrue);
    });
  });

  group('price history', () {
    test('is newest first and marks only the price in effect as current', () async {
      repo.addons = [addon(1)];
      final future = DateTime.now().add(const Duration(days: 30));
      repo.prices[1] = [
        price(1, 1, 50, DateTime(2020)),
        price(2, 1, 60, DateTime(2021)),
        price(3, 1, 99, future),
      ];
      await notifier.load(7);

      await notifier.select(1);

      expect(notifier.state.history.map((p) => p.price), [99, 60, 50]);
      expect(notifier.state.currentHistoryPriceId, 2);
    });

    test('adding a price refreshes the history and the list price', () async {
      repo.addons = [addon(1)];
      repo.prices[1] = [price(1, 1, 50, DateTime(2020))];
      await notifier.load(7);
      await notifier.select(1);

      final ok = await notifier.addPrice(addonId: 1, price: 75, effectiveFrom: DateTime(2021));

      expect(ok, isTrue);
      expect(notifier.state.history.map((p) => p.price), [75, 50]);
      expect(notifier.state.currentPrices[1], 75);
    });

    test('a failed new price shows the error', () async {
      repo.addons = [addon(1)];
      await notifier.load(7);
      repo.failCreatePrice = true;

      final ok = await notifier.addPrice(addonId: 1, price: 75, effectiveFrom: past);

      expect(ok, isFalse);
      expect(notifier.state.error, 'boom');
    });
  });
}

class _FailingListRepository implements AddonRepository {
  @override
  Future<Either<Failure, List<Addon>>> getAddons(int businessId) async => _fail;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
