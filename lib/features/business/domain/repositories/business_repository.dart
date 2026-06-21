import 'package:dartz/dartz.dart';

import '../../../../core/error/failure.dart';
import '../entities/business.dart';
import '../entities/business_member.dart';

import 'package:dartz/dartz.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import '../entities/business.dart';

abstract class BusinessRepository {
  Future<Either<Failure, List<Business>>> getMyBusinesses({bool? isActive});

  Future<Either<Failure, Business>> getBusinessById(int businessId);

  Future<Either<Failure, Business>> createBusiness({
    required String name,
    String? description,
  });

  Future<Either<Failure, Business>> updateBusiness({
    required int businessId,
    String? name,
    String? description,
  });

  Future<Either<Failure, void>> deleteBusiness(int businessId);
}
/*
abstract class BusinessRepository {

  Future<Either<Failure, List<Business>>> getMyBusinesses({bool? isActive});

  Future<Either<Failure, Business>> getBusinessById(int businessId);

  Future<Either<Failure, Business>> createBusiness({
    required String name,
    String? description,
  });

  Future<Either<Failure, Business>> updateBusiness({
    required int businessId,
    String? name,
    String? description,
  });

  Future<Either<Failure, void>> deleteBusiness(int businessId);

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
*/