import 'dart:typed_data';

import 'package:account_ledger/core/error/exceptions.dart';
import 'package:account_ledger/core/network/api_endpoints.dart';
import 'package:account_ledger/features/profile/data/models/profile_update_model.dart';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

abstract class ProfileRemoteDatasource {
  Future<ProfileUpdateModel> editProfile({
    String? name,
    String? phone,
    DateTime? dateOfBirth,
    Uint8List? avatarBytes,
    String? avatarFilename,
  });
}

class ProfileRemoteDatasourceImpl implements ProfileRemoteDatasource {
  final Dio dio;

  const ProfileRemoteDatasourceImpl({required this.dio});

  Never _throwTypedDio(DioException e, String scope) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;
    throw ServerException(
      message: 'Request failed. Please try again.',
      code: '$scope-failed-${statusCode ?? 'unknown'}',
      details: data ?? e.toString(),
    );
  }

  @override
  Future<ProfileUpdateModel> editProfile({
    String? name,
    String? phone,
    DateTime? dateOfBirth,
    Uint8List? avatarBytes,
    String? avatarFilename,
  }) async {
    try {
      final hasAvatar = avatarBytes != null && avatarBytes.isNotEmpty;
      final hasFields = (name != null && name.trim().isNotEmpty) ||
          (phone != null && phone.trim().isNotEmpty) ||
          dateOfBirth != null;

      if (!hasAvatar && !hasFields) {
        throw const ServerException(
          message: 'No valid fields provided to update',
          code: 'no-fields',
        );
      }

      final form = FormData();
      if (name != null && name.trim().isNotEmpty) {
        form.fields.add(MapEntry('name', name.trim()));
      }
      if (phone != null && phone.trim().isNotEmpty) {
        form.fields.add(MapEntry('phone', phone.trim()));
      }
      if (dateOfBirth != null) {
        form.fields.add(MapEntry('dateOfBirth', dateOfBirth.toIso8601String()));
      }
      if (hasAvatar) {
        form.files.add(
          MapEntry(
            'avatar',
            MultipartFile.fromBytes(
              avatarBytes,
              filename: avatarFilename ?? 'avatar.png',
              contentType: MediaType('image', 'png'),
            ),
          ),
        );
      }

      final response = await dio.patch(ApiEndpoints.editProfile, data: form);
      final data = response.data;
      if (data is Map<String, dynamic>) {
        final user = data['user'];
        if (user is Map<String, dynamic>) {
          return ProfileUpdateModel.fromJson(user);
        }
      }
      throw const ServerException(
        message: 'Invalid edit-profile response',
        code: 'edit-profile-invalid-response',
      );
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      _throwTypedDio(e, 'edit-profile');
    }
  }
}

