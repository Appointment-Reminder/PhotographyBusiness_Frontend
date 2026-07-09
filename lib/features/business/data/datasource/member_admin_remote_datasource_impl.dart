import 'package:dio/dio.dart';
import 'package:photography_business_frontend/features/business/data/datasource/member_admin_remote_datasource.dart';
import 'package:photography_business_frontend/features/business/data/models/member_commission_model.dart';
import 'package:photography_business_frontend/features/business/data/models/business_member_form_model.dart';
import '../../domain/entities/member_commission.dart';
import '../../domain/entities/business_member_form.dart';

class MemberAdminRemoteDatasourceImpl implements MemberAdminRemoteDatasource {
  final Dio client;

  MemberAdminRemoteDatasourceImpl({required this.client});

  @override
  Future<MemberCommission> createMemberCommission({
    required int businessMemberId,
    required int packageId,
    required int commissionAmount,
    required bool commissionIsPercent,
    required DateTime effectiveFrom,
  }) async {
    final response = await client.post(
      '/business/members/commissions',
      data: {
        'business_member_id': businessMemberId,
        'package_id': packageId,
        'commission_amount': commissionAmount,
        'commission_isPercent': commissionIsPercent,
        'effective_from': effectiveFrom.toIso8601String(),
      },
    );
    return MemberCommissionModel.fromJson(response.data);
  }

  @override
  Future<MemberCommission> getMemberCommission({
    required int memberId,
    required int packageId,
  }) async {
    final response = await client.get('/business/members/$memberId/$packageId/commissions');
    return MemberCommissionModel.fromJson(response.data);
  }

  @override
  Future<List<MemberCommission>> getBusinessCommissions({required int businessId}) async {
    final response = await client.get('/business/$businessId/commissions');
    final List<dynamic> list = response.data;
    return list.map((json) => MemberCommissionModel.fromJson(json)).toList();
  }

  @override
  Future<MemberCommission> updateMemberCommission({
    required int id,
    required int commissionAmount,
    required bool commissionIsPercent}) async {
    final response = await client.patch('/business/members/commissions',
        data: {'id': id, 'commission_amount': commissionAmount ,'commission_IsPercent': commissionIsPercent});
    return MemberCommissionModel.fromJson(response.data);
  }

  @override
  Future<BusinessMemberForm> createMemberForm({
    required int businessMemberId,
    required int categoryId,
    required String jotformFieldMap,
  }) async {
    final response = await client.post(
      '/business/members/forms',
      data: {
        'business_member_id': businessMemberId,
        'category_id': categoryId,
        'jotform_field_map': jotformFieldMap,
      },
    );
    return BusinessMemberFormModel.fromJson(response.data);
  }

  @override
  Future<BusinessMemberForm> updateMemberForm({
    required int id,
    required int businessMemberId,
    required int categoryId,
    required String jotformFieldMap,
  }) async {
    final response = await client.patch(
      '/business/members/forms',
      data: {
        'id': id,
        'business_member_id': businessMemberId,
        'category_id': categoryId,
        'jotform_field_map': jotformFieldMap,
      },
    );
    return BusinessMemberFormModel.fromJson(response.data);
  }

  @override
  Future<List<BusinessMemberForm>> getMemberForms({
    required int businessId,
    required int memberId,
  }) async {
    final response = await client.get('/business/$businessId/members/$memberId/forms');
    final List<dynamic> list = response.data;
    return list.map((json) => BusinessMemberFormModel.fromJson(json)).toList();
  }

  @override
  Future<List<BusinessMemberForm>> getAllMemberForms({required int businessId}) async {
    final response = await client.get('/business/$businessId/members/forms');
    final List<dynamic> list = response.data;
    return list.map((json) => BusinessMemberFormModel.fromJson(json)).toList();
  }

  @override
  Future<void> deleteMemberForm(int formId) async {
    await client.delete('/business/members/forms/$formId');
  }

}