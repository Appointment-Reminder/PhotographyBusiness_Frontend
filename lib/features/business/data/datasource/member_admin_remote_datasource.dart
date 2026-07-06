import '../../domain/entities/member_commission.dart';
import '../../domain/entities/business_member_form.dart';

abstract class MemberAdminRemoteDatasource {
  Future<MemberCommission> createMemberCommission({
    required int businessMemberId,
    required int packageId,
    required int commissionPercent,
    required DateTime effectiveFrom,
  });

  Future<MemberCommission> getMemberCommission({
    required int memberId,
    required int packageId,
  });

  Future<MemberCommission> updateMemberCommission({
    required int id,
    required int commissionPercent,
    required int commissionFlat,
  });

  Future<List<MemberCommission>> getBusinessCommissions({
    required int businessId
  });

  Future<BusinessMemberForm> createMemberForm({
    required int businessMemberId,
    required int categoryId,
    required String jotformFieldMap,
  });

  Future<BusinessMemberForm> updateMemberForm({
    required int id,
    required int businessMemberId,
    required int categoryId,
    required String jotformFieldMap,
  });

  Future<List<BusinessMemberForm>> getMemberForms({
    required int businessId,
    required int memberId,
  });

  Future<List<BusinessMemberForm>> getAllMemberForms({
    required int businessId,
  });

  Future<void> deleteMemberForm(int formId);
}