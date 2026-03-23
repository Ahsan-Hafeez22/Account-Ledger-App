import 'package:account_ledger/features/authentication/data/models/user_model.dart';

class AuthResponseModel {
  final int? statusCode;
  final String? status;
  final String? message;
  final String token;
  final String? refreshToken;
  final UserModel user;

  const AuthResponseModel({
    this.statusCode,
    this.status,
    this.message,
    required this.token,
    this.refreshToken,
    required this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      statusCode: json['statusCode'] as int?,
      status: json['status'] as String?,
      message: json['message'] as String?,
      token: (json['accessToken'] ?? json['token'] ?? '') as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
