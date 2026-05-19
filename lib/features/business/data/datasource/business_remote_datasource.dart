
import 'package:photography_business_frontend/features/business/domain/entities/business.dart';

import '../../domain/entities/business_member.dart';

abstract class BusinessRemoteDatasource {
  Future<List<Business>> getMyBusinesses({bool? isActive});

  Future<Business> getBusinessById(int businessId);

  Future<Business> createBusiness({
    required String name,
    String? description,
  });

  Future<Business> updateBusiness({
    required int businessId,
    String? name,
    String? description,
  });

  Future<void> deleteBusiness(int businessId);

  Future<List<BusinessMember>> getBusinessMembers(int businessId);

  Future<BusinessMember> inviteMember({
    required int businessId,
    required String userEmail,
    required String role,
  });

  Future<BusinessMember> updateMemberRole({
    required int businessId,
    required int memberId,
    required String role,
    required bool isActive,
  });

  Future<void> removeMember({
    required int businessId,
    required int memberId,
  });

}