import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:photography_business_frontend/core/error/dio_error_handler.dart';
import 'package:photography_business_frontend/core/error/failure.dart';
import 'package:photography_business_frontend/core/network/network_info.dart';
import '../../domain/entities/field_mapping_item.dart';
import '../../domain/entities/jotform_assignment.dart';
import '../../domain/entities/jotform_credential.dart';
import '../../domain/entities/jotform_form.dart';
import '../../domain/entities/submission_field.dart';
import '../../domain/repositories/jotform_repository.dart';
import '../datasources/jotform_remote_datasource.dart';

class JotformRepositoryImpl implements JotformRepository {
  final JotformRemoteDatasource remoteDatasource;
  final NetworkInfo networkInfo;

  JotformRepositoryImpl({required this.remoteDatasource, required this.networkInfo});

  Future<Either<Failure, T>> _execute<T>(Future<T> Function() action) async {
    try {
      if (!await networkInfo.isConnected) {
        return const Left(ServerFailure('No internet connection'));
      }
      return Right(await action());
    } on DioException catch (e) {
      return Left(DioErrorHandler.handleError(e));
    } catch (_) {
      return const Left(ServerFailure('Unexpected error'));
    }
  }

  @override
  Future<Either<Failure, List<JotformCredential>>> getCredentials(int businessId) =>
      _execute(() => remoteDatasource.getCredentials(businessId));

  @override
  Future<Either<Failure, JotformCredential>> createCredential(
          {required int businessId, required String label, required String apiKey}) =>
      _execute(() => remoteDatasource.createCredential(
          businessId: businessId, label: label, apiKey: apiKey));

  @override
  Future<Either<Failure, JotformCredential>> updateCredential(
          {required int id, required String label, required String apiKey}) =>
      _execute(() => remoteDatasource.updateCredential(id: id, label: label, apiKey: apiKey));

  @override
  Future<Either<Failure, void>> deleteCredential(int credentialId) =>
      _execute(() => remoteDatasource.deleteCredential(credentialId));

  @override
  Future<Either<Failure, List<JotformForm>>> getFormsForBusiness(int businessId) =>
      _execute(() => remoteDatasource.getFormsForBusiness(businessId));

  @override
  Future<Either<Failure, List<JotformForm>>> getFormsForCredential(int credentialId) =>
      _execute(() => remoteDatasource.getFormsForCredential(credentialId));

  @override
  Future<Either<Failure, List<JotformForm>>> syncForms(int businessId) =>
      _execute(() => remoteDatasource.syncForms(businessId));

  @override
  Future<Either<Failure, JotformForm>> refreshQuestions(int formId) =>
      _execute(() => remoteDatasource.refreshQuestions(formId));

  @override
  Future<Either<Failure, List<SubmissionField>>> getTargetFields() =>
      _execute(() => remoteDatasource.getTargetFields());

  @override
  Future<Either<Failure, List<FieldMappingItem>>> getFieldMapping(int formId) =>
      _execute(() => remoteDatasource.getFieldMapping(formId));

  @override
  Future<Either<Failure, List<FieldMappingItem>>> updateFieldMapping(
          {required int formId, required List<FieldMappingItem> mapping}) =>
      _execute(() => remoteDatasource.updateFieldMapping(formId: formId, mapping: mapping));

  @override
  Future<Either<Failure, List<JotformAssignment>>> getAssignmentsForBusiness(int businessId) =>
      _execute(() => remoteDatasource.getAssignmentsForBusiness(businessId));

  @override
  Future<Either<Failure, JotformAssignment>> assignForm(
          {required int formId, required int businessMemberId, required int categoryId}) =>
      _execute(() => remoteDatasource.assignForm(
          formId: formId, businessMemberId: businessMemberId, categoryId: categoryId));
}
