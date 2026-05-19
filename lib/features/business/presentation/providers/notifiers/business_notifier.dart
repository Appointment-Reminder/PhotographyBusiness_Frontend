import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photography_business_frontend/features/business/presentation/providers/state/business_state.dart';

import '../../../domain/usecases/business_params.dart';

class BusinessNotifier extends StateNotifier<BusinessState>{
  final GetMyBusiness getMyBusinesses;
  final GetBusinessById getBusinessById;
  final CreateBusiness createBusiness;
  final UpdateBusiness updateBusiness;
  final DeleteBusiness deleteBusiness;

  BusinessNotifier({
    required this.getMyBusinesses,
    required this.getBusinessById,
    required this.createBusiness,
    required this.updateBusiness,
    required this.deleteBusiness,
  }) : super(const BusinessInitial());

  Future<void> loadMyBusinesses({bool? isActive}) async {
    state = const BusinessLoading();

    final result = await getMyBusinesses(GetMyBusinessesParams(isActive: isActive));

    result.fold(
        (failure) => state = BusinessError(message: failure.message),
        (businesses) => state = BusinessListLoaded(businesses),
    );
  }

  Future<void> loadBusinessById(int businessId) async {
    state = const BusinessLoading();

    final result = await getBusinessById(GetBusinessByIdParams(businessId));

    result.fold(
        (failure) => state = BusinessError(message: failure.message),
        (business) => state = BusinessDetailLoaded(business: business),
    );
  }

  Future<void> createNewBusiness(String name, String? description) async {
    state = const BusinessLoading();

    final result = await createBusiness(
      CreateBusinessParams(name: name, description: description),
    );

    result.fold(
        (failure) => state = BusinessError(message: failure.message),
        (business) => state = BusinessDetailLoaded(business: business),
    )
  }

  Future<void> updateExistingBusiness(
      int businessId,
      String? name,
      String? description,
      ) async {
    state = const BusinessLoading();

    final result = await updateBusiness(
      UpdateBusinessParams(
        businessId: businessId,
        name: name,
        description: description,
      ),
    );

    result.fold(
          (failure) => state = BusinessError(failure.message),
          (business) => state = BusinessDetailLoaded(business),
    );
  }

  Future<void> deleteBusiness(int businessId) async {
    state = const BusinessLoading();

    final result = await deleteBusiness(DeleteBusinessParams(businessId));

    result.fold(
          (failure) => state = BusinessError(failure.message),
          (_) => state = const BusinessInitial(), // Return to initial after delete
    );
  }
}