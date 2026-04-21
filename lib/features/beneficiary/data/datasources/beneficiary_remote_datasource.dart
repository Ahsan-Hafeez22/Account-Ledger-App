import 'package:account_ledger/core/error/exceptions.dart';
import 'package:account_ledger/core/network/api_endpoints.dart';
import 'package:account_ledger/features/beneficiary/data/models/beneficiary_model.dart';
import 'package:dio/dio.dart';

abstract class BeneficiaryRemoteDatasource {
  Future<List<BeneficiaryModel>> getBeneficiaries();
  Future<void> addBeneficiary({
    required String accountNumber,
    required String nickname,
  });
  Future<void> deleteBeneficiary(String id);
}

class BeneficiaryRemoteDatasourceImpl implements BeneficiaryRemoteDatasource {
  final Dio dio;

  const BeneficiaryRemoteDatasourceImpl({required this.dio});

  Never _throwTypedDio(DioException e, String scope) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;
    String message = 'Request failed. Please try again.';
    if (data is Map<String, dynamic>) {
      final m = data['message'];
      if (m is String && m.isNotEmpty) {
        message = m;
      }
    }
    throw ServerException(
      message: message,
      code: '$scope-failed-${statusCode ?? 'unknown'}',
      details: data ?? e.toString(),
    );
  }

  @override
  Future<List<BeneficiaryModel>> getBeneficiaries() async {
    try {
      final response = await dio.get(ApiEndpoints.getBeneficiaries);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final list = data['beneficiaries'];
        if (list is List) {
          return list
              .whereType<Map>()
              .map((e) => BeneficiaryModel.fromJson(Map<String, dynamic>.from(e)))
              .toList();
        }
      }
      return const [];
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      _throwTypedDio(e, 'get-beneficiaries');
    }
  }

  @override
  Future<void> addBeneficiary({
    required String accountNumber,
    required String nickname,
  }) async {
    try {
      await dio.post(
        ApiEndpoints.addBeneficiary,
        data: {
          'accountNumber': accountNumber,
          'nickname': nickname,
        },
      );
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      _throwTypedDio(e, 'add-beneficiary');
    }
  }

  @override
  Future<void> deleteBeneficiary(String id) async {
    try {
      await dio.delete(ApiEndpoints.deleteBeneficiary(id));
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      _throwTypedDio(e, 'delete-beneficiary');
    }
  }
}

