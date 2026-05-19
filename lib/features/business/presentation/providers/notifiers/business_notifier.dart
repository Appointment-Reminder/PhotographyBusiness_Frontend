import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/create_business.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/delete_business.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/get_business_by_id.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/get_my_businesses.dart';
import 'package:photography_business_frontend/features/business/domain/usecases/update_business.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/state/business_state.dart';

import '../../../domain/usecases/business_params.dart';

class BusinessNotifier extends StateNotifier<BusinessState>{
  final GetMyBusinessesUser getMyBusinessesUser;
  final GetBusinessByIdUser getBusinessByIdUser;
  final CreateBusinessUser createBusinessUser;
  final UpdateBusinessUser updateBusinessUser;
  final DeleteBusinessUser deleteBusinessUser;

  BusinessNotifier({
    required this.getMyBusinessesUser,
    required this.getBusinessByIdUser,
    required this.createBusinessUser,
    required this.updateBusinessUser,
    required this.deleteBusinessUser,
  }) : super(const BusinessInitial());

  Future<void> loadMyBusinesses({bool? isActive}) async {
    state = const BusinessLoading();

    final result = await getMyBusinessesUser(GetMyBusinessesParams(isActive: isActive));

    result.fold(
        (failure) => state = BusinessError(message: failure.message),
        (businesses) => state = BusinessListLoaded(businesses: businesses),
    );
  }

  Future<void> loadBusinessById(int businessId) async {
    state = const BusinessLoading();

    final result = await getBusinessByIdUser(GetBusinessByIdParams(businessId));

    result.fold(
        (failure) => state = BusinessError(message: failure.message),
        (business) => state = BusinessDetailLoaded(business: business),
    );
  }

  Future<void> createNewBusiness(String name, String? description) async {
    state = const BusinessLoading();

    final result = await createBusinessUser(
      CreateBusinessParams(name: name, description: description),
    );

    result.fold(
        (failure) => state = BusinessError(message: failure.message),
        (business) => state = BusinessDetailLoaded(business: business),
    );
  }

  Future<void> updateExistingBusiness(
      int businessId,
      String? name,
      String? description,
      ) async {
    state = const BusinessLoading();

    final result = await updateBusinessUser(
      UpdateBusinessParams(
        businessId: businessId,
        name: name,
        description: description,
      ),
    );

    result.fold(
          (failure) => state = BusinessError(message: failure.message),
          (business) => state = BusinessDetailLoaded(business: business),
    );
  }

  Future<void> deleteBusiness(int businessId) async {
    state = const BusinessLoading();

    final result = await deleteBusinessUser(DeleteBusinessParams(businessId));

    result.fold(
          (failure) => state = BusinessError(message: failure.message),
          (_) => state = const BusinessInitial(),
    );
  }
}