import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String? avatarUrl;
  final DateTime? dateOfBirth;
  final String? country;
  final bool? verified;
  final DateTime? emailVerifiedAt;
  final bool? isActive;
  final String? authProvider;
  final String? defaultCurrency;
  final String? role;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? googleId;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatarUrl,
    this.dateOfBirth,
    this.country,
    this.verified,
    this.emailVerifiedAt,
    this.isActive,
    this.authProvider,
    this.defaultCurrency,
    this.role,
    this.createdAt,
    this.updatedAt,
    this.googleId,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    phone,
    avatarUrl,
    dateOfBirth,
    country,
    verified,
    emailVerifiedAt,
    isActive,
    authProvider,
    defaultCurrency,
    role,
    createdAt,
    updatedAt,
    googleId,
  ];
}
