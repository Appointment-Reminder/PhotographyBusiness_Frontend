import 'package:dartz/dartz.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import '../entities/business_member.dart';

abstract class BusinessMemberRepository {
  Future<Either<Failure, List<BusinessMember>>> getBusinessMembers(int businessId);

  Future<Either<Failure, BusinessMember>> inviteMember({
    required int businessId,
    required String userEmail,
    required String role,
  });

  Future<Either<Failure, BusinessMember>> updateMemberRole({
    required int businessId,
    required int memberId,
    required String role,
    required bool isActive,
  });

  Future<Either<Failure, void>> removeMember({
    required int businessId,
    required int memberId,
  });
}