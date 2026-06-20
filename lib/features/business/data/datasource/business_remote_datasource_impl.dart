
import 'package:dio/dio.dart';
import 'package:photography_business_frontend/features/business/data/datasource/business_remote_datasource.dart';
import 'package:photography_business_frontend/features/business/data/models/business_member_model.dart';
import 'package:photography_business_frontend/features/business/domain/entities/business.dart';
import 'package:photography_business_frontend/features/business/domain/entities/business_member.dart';

import '../models/business_model.dart';

class BusinessRemoteDatasourceImpl implements BusinessRemoteDatasource {
  final Dio client;

  BusinessRemoteDatasourceImpl({required this.client});

  @override
  Future<Business> createBusiness({required String name, String? description}) async {
    final response = await client.post(
      '/business/',
      data: {
        'name': name,
        if (description != null) 'description': description,
      },
    );

    return BusinessModel.fromJson(response.data);
  }

  @override
  Future<Business> updateBusiness({required int businessId, String? name, String? description}) async {
    final response = await client.put(
      '/business/businesses/$businessId',
      data: {
        if (name != null) 'name':name,
        if (description != null) 'description': description,
      },
    );

    return BusinessModel.fromJson(response.data);
  }

  @override
  Future<void> deleteBusiness(int businessId) async {
    await client.delete('/business/$businessId');
  }

  @override
  Future<Business> getBusinessById(int businessId) async {
    final response = await client.get('/business/$businessId');
    return BusinessModel.fromJson(response.data);
  }

  @override
  Future<List<Business>> getMyBusinesses({bool? isActive}) async {
    final queryParams = <String, dynamic>{};
    if (isActive != null){
      queryParams['is_active'] = isActive;
    }

    final response = await client.get(
      '/business/me',
      queryParameters: queryParams,
    );

    final List<dynamic> businessList = response.data;
    print(businessList);
    return businessList
        .map((json) => BusinessModel.fromJson(json))
        .toList();
  }

  @override
  Future<List<BusinessMember>> getBusinessMembers(int businessId) async {
    final response = await client.get(
      '/business/$businessId/members',
    );

    final List<dynamic> memberList = response.data;
    return memberList
        .map((json) => BusinessMemberModel.fromJson(json))
        .toList();
  }



  @override
  Future<BusinessMember> inviteMember({required int businessId, required String userEmail, required String role}) async {
    print('Try to invite member ${userEmail} to $businessId');
    final response = await client.post(
      '/business/$businessId/invite',
      queryParameters: {'business_id': businessId},
      data: {
        'user_email': userEmail,
        'role': role,
      },
    );
    print('Response data ${response.data}');

    return BusinessMemberModel.fromJson(response.data);
  }

  @override

  Future<void> removeMember({required int businessId, required int memberId}) async {
    await client.delete(
      '/business/$businessId/members/$memberId',
    );
  }



  @override
  Future<BusinessMember> updateMemberRole({required int businessId, required int memberId, required String role, required bool isActive}) async {
    print('Update the member for member id : ${memberId}');
    final response = await client.patch(
      '/business/$businessId/members/$memberId',
      data: {
        'role': role,
        'is_active': isActive,
      },
    );

    return BusinessMemberModel.fromJson(response.data);
  }
}