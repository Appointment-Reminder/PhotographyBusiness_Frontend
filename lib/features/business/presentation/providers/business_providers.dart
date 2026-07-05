import 'package:flutter_riverpod/flutter_riverpod.dart';
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


final selectedBusinessProvider = StateProvider<Business?>((ref) => null);

final businessTabProvider = StateProvider<String>((ref) => 'overview');


final businessListNotifierProvider =
StateNotifierProvider<BusinessListNotifier, BusinessListState>((ref) {
  return BusinessListNotifier(getMyBusinesses: ref.read(getMyBusinessUserProvider));
});

final businessDetailNotifierProvider =
StateNotifierProvider<BusinessDetailNotifier, BusinessDetailState>((ref) {
  return BusinessDetailNotifier(getBusinessById: ref.read(getBusinessByIdUserProvider));
});

final businessFormNotifierProvider =
StateNotifierProvider<BusinessFormNotifier, BusinessFormState>((ref) {
  return BusinessFormNotifier(
    createBusiness: ref.read(createBusinessUserProvider),
  );
});



