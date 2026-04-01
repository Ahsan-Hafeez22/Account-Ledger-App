import 'package:account_ledger/features/authentication/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.phone,
    super.avatarUrl,
    super.dateOfBirth,
    super.country,
    super.verified,
    super.emailVerifiedAt,
    super.isActive,
    super.authProvider,
    super.defaultCurrency,
    super.role,
    super.createdAt,
    super.updatedAt,
    super.googleId,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['_id'] ?? json['id']) as String,
      name: (json['name'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      phone: json['phone'] as String?,
      avatarUrl: (json['avatar'] ?? json['avatarUrl'] ?? json['avatar_url'])
          as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'] as String)
          : (json['date_of_birth'] != null
                ? DateTime.tryParse(json['date_of_birth'] as String)
                : null),
      country: (json['country'] ?? json['country_code']) as String?,
      verified: json['verified'] as bool?,
      emailVerifiedAt: json['emailVerifiedAt'] != null
          ? DateTime.tryParse(json['emailVerifiedAt'] as String)
          : (json['emailVerifiedAt'] != null
                ? DateTime.tryParse(json['emailVerifiedAt'] as String)
                : null),
      isActive: json['isActive'] as bool?,
      authProvider: json['authProvider'] as String?,
      defaultCurrency: json['defaultCurrency'] as String?,
      role: json['role'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : (json['created_at'] != null
                ? DateTime.tryParse(json['created_at'] as String)
                : null),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)
          : (json['updated_at'] != null
                ? DateTime.tryParse(json['updated_at'] as String)
                : null),
      googleId: json['googleId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'avatar': avatarUrl,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'country': country,
      'verified': verified,
      'emailVerifiedAt': emailVerifiedAt?.toIso8601String(),
      'isActive': isActive,
      'authProvider': authProvider,
      'defaultCurrency': defaultCurrency,
      'role': role,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'googleId': googleId,
    };
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      email: email,
      phone: phone,
      avatarUrl: avatarUrl,
      dateOfBirth: dateOfBirth,
      country: country,
      verified: verified,
      emailVerifiedAt: emailVerifiedAt,
      isActive: isActive,
      authProvider: authProvider,
      defaultCurrency: defaultCurrency,
      role: role,
      createdAt: createdAt,
      updatedAt: updatedAt,
      googleId: googleId,
    );
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
      avatarUrl: entity.avatarUrl,
      dateOfBirth: entity.dateOfBirth,
      country: entity.country,
      verified: entity.verified,
      emailVerifiedAt: entity.emailVerifiedAt,
      isActive: entity.isActive,
      authProvider: entity.authProvider,
      defaultCurrency: entity.defaultCurrency,
      role: entity.role,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      googleId: entity.googleId,
    );
  }
}
