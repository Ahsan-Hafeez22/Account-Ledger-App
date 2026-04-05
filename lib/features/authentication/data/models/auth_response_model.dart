import 'package:account_ledger/features/authentication/data/models/user_model.dart';

class AuthResponseModel {
  final int? statusCode;
  final String? status;
  final String? message;
  final bool? isNewUser;
  final bool? isGoogleLinked;
  final String token;
  final String? refreshToken;
  final UserModel user;

  const AuthResponseModel({
    this.statusCode,
    this.status,
    this.message,
    this.isNewUser,
    this.isGoogleLinked,
    required this.token,
    this.refreshToken,
    required this.user,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(
      statusCode: json['statusCode'] as int?,
      status: json['status'] as String?,
      message: json['message'] as String?,
      isNewUser: json['isNewUser'] as bool?,
      isGoogleLinked: json['isGoogleLinked'] as bool?,
      token: (json['accessToken'] ?? json['access_token'] ?? json['token'] ?? '') as String,
      refreshToken:
          json['refreshToken'] as String? ?? json['refresh_token'] as String?,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}
