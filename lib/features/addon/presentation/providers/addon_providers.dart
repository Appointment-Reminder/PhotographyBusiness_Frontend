import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/core/network/dio_provider.dart';
import '../../data/datasources/addon_remote_datasource.dart';
import '../../data/repositories/addon_repository_impl.dart';
import '../../domain/repositories/addon_repository.dart';
import 'notifiers/addon_catalog_notifier.dart';
import 'notifiers/member_addon_commission_notifier.dart';
import 'state/addon_catalog_state.dart';

final addonRepositoryProvider = Provider<AddonRepository>((ref) {
  return AddonRepositoryImpl(
    remote: AddonRemoteDatasource(client: ref.read(dioProvider)),
    networkInfo: ref.read(networkInfoProvider),
  );
});

/// The Add-on catalog of the Selected Business. Views call `load` on entry,
/// as the Packages view does.
final addonCatalogProvider =
    StateNotifierProvider<AddonCatalogNotifier, AddonCatalogState>((ref) {
  return AddonCatalogNotifier(repository: ref.read(addonRepositoryProvider));
});

final memberAddonCommissionProvider =
    StateNotifierProvider<MemberAddonCommissionNotifier, MemberAddonCommissionState>((ref) {
  return MemberAddonCommissionNotifier(repository: ref.read(addonRepositoryProvider));
});
