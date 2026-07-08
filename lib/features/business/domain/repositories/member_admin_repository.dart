import 'package:dartz/dartz.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import '../entities/member_commission.dart';
import '../entities/business_member_form.dart';

abstract class MemberAdminRepository {
  Future<Either<Failure, MemberCommission>> createMemberCommission({
    required int businessMemberId,
    required int packageId,
    required int commissionAmount,
    required bool commissionIsPercent,
    required DateTime effectiveFrom,
  });

  Future<Either<Failure, MemberCommission>> getMemberCommission({
    required int memberId,
    required int packageId,
  });

  Future<Either<Failure, MemberCommission>> updateMemberCommission({
    required int id,
    required int commissionAmount,
    required bool commissionIsPercent,
  });

  Future<Either<Failure, List<MemberCommission>>> getBusinessCommissions({
    required int businessId,
  });

  Future<Either<Failure, BusinessMemberForm>> createMemberForm({
    required int businessMemberId,
    required int categoryId,
    required String jotformFieldMap,
  });

  Future<Either<Failure, BusinessMemberForm>> updateMemberForm({
    required int id,
    required int businessMemberId,
    required int categoryId,
    required String jotformFieldMap,
  });

  Future<Either<Failure, List<BusinessMemberForm>>> getMemberForms({
    required int businessId,
    required int memberId,
  });

  Future<Either<Failure, List<BusinessMemberForm>>> getAllMemberForms({
    required int businessId,
});

  Future<Either<Failure, void>> deleteMemberForm(int formId);
}