import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:photography_business_frontend/features/user_create/presentation/providers/auth_provders.dart';
import 'package:photography_business_frontend/features/user_create/presentation/providers/state/auth_state.dart';
import 'package:photography_business_frontend/core/network/dio_provider.dart';
import 'package:photography_business_frontend/features/business/data/datasource/business_remote_datasource.dart';
import 'package:photography_business_frontend/features/business/data/datasource/business_remote_datasource_impl.dart';
import 'package:photography_business_frontend/features/business/data/datasource/member_admin_remote_datasource.dart';
import 'package:photography_business_frontend/features/business/data/datasource/member_admin_remote_datasource_impl.dart';
import 'package:photography_business_frontend/features/business/data/repositories/business_repository_impl.dart';
import 'package:photography_business_frontend/features/business/data/repositories/member_admin_repository_impl.dart';
import 'package:photography_business_frontend/features/business/domain/entities/business.dart';
import 'package:photography_business_frontend/features/business/domain/repositories/business_repository.dart';
import 'package:photography_business_frontend/features/business/domain/repositories/member_admin_repository.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/delete_business.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/get_business_by_id.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/get_my_businesses.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/update_business.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/notifiers/business/business_detail_notifier.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/notifiers/business/business_form_notifier.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/notifiers/business/business_list_notifier.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/state/business/business_list_state.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/state/business/business_form_state.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/state/business/business_detail_state.dart';

import '../../domain/usecases/create_business.dart';

final businessRemoteDataSourceProvider = Provider<BusinessRemoteDatasource>((ref) {
  return BusinessRemoteDatasourceImpl(client: ref.read(dioProvider));
});

final memberAdminRemoteDataSourceProvider = Provider<MemberAdminRemoteDatasource>((ref){
  return MemberAdminRemoteDatasourceImpl(client: ref.read(dioProvider));
});

final businessRepositoryProvider = Provider<BusinessRepository>((ref) {
  return BusinessRepositoryImpl(
    remoteDatasource: ref.read(businessRemoteDataSourceProvider),
    networkInfo: ref.read(networkInfoProvider)
  );
});



final memberAdminRepositoryProvider = Provider<MemberAdminRepository>((ref){
  return MemberAdminRepositoryImpl(
      remoteDatasource: ref.read(memberAdminRemoteDataSourceProvider),
      networkInfo: ref.read(networkInfoProvider)
  );
});

final createBusinessUserProvider = Provider<CreateBusinessUser>((ref){
  return CreateBusinessUser(repository: ref.read(businessRepositoryProvider));
});

final deleteBusinessUserProvider = Provider<DeleteBusinessUser>((ref){
  return DeleteBusinessUser(repository: ref.read(businessRepositoryProvider));
});

final getBusinessByIdUserProvider = Provider<GetBusinessByIdUser>((ref){
  return GetBusinessByIdUser(repository: ref.read(businessRepositoryProvider));
});



final getMyBusinessUserProvider = Provider<GetMyBusinessesUser>((ref){
  return GetMyBusinessesUser(repository: ref.read(businessRepositoryProvider));
});



final updateBusinessProvider = Provider<UpdateBusinessUser>((ref){
  return UpdateBusinessUser(repository: ref.read(businessRepositoryProvider));
});


final _currentUserIdProvider = Provider<int?>((ref) {
  final auth = ref.watch(authNotifierProvider);
  return auth is AuthAuthenticated ? auth.user.id : null;
});

/// Persisted per user, so one user's choice never leaks to another.
class SelectedBusinessIdNotifier extends StateNotifier<int?> {
  final SharedPreferences _prefs;
  final String? _key;

  SelectedBusinessIdNotifier(this._prefs, this._key)
      : super(_key == null ? null : _prefs.getInt(_key));

  void select(int id) {
    state = id;
    final key = _key;
    if (key != null) _prefs.setInt(key, id);
  }
}

final selectedBusinessIdProvider =
StateNotifierProvider<SelectedBusinessIdNotifier, int?>((ref) {
  final userId = ref.watch(_currentUserIdProvider);
  return SelectedBusinessIdNotifier(
    ref.read(sharedPreferencesProvider),
    userId == null ? null : 'selected_business_id_$userId',
  );
});

/// Derived from the list: the stored id if it still exists, else the first business.
final selectedBusinessProvider = Provider<Business?>((ref) {
  // The runtime list is List<BusinessModel>; widen it so orElse can return a plain Business.
  final List<Business> businesses = List<Business>.of(ref.watch(businessListNotifierProvider).businesses);
  if (businesses.isEmpty) return null;
  final id = ref.watch(selectedBusinessIdProvider);
  return businesses.firstWhere((b) => b.id == id, orElse: () => businesses.first);
});



final businessListNotifierProvider =
StateNotifierProvider<BusinessListNotifier, BusinessListState>((ref) {
  final userId = ref.watch(_currentUserIdProvider);
  final notifier = BusinessListNotifier(getMyBusinesses: ref.read(getMyBusinessUserProvider));
  if (userId != null) notifier.load();
  return notifier;
});

final businessDetailNotifierProvider =
StateNotifierProvider<BusinessDetailNotifier, BusinessDetailState>((ref) {
  return BusinessDetailNotifier(getBusinessById: ref.read(getBusinessByIdUserProvider));
});

final businessFormNotifierProvider =
StateNotifierProvider<BusinessFormNotifier, BusinessFormState>((ref) {
  return BusinessFormNotifier(
    createBusiness: ref.read(createBusinessUserProvider),
    onCreated: () => ref.read(businessListNotifierProvider.notifier).load(),
  );
});



