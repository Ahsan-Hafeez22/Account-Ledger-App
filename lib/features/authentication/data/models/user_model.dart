import 'package:account_ledger/features/authentication/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.name,
    required super.email,
    super.avatarUrl,
    super.isPremium = false,
    super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // ✅ The login response nests user inside json['user']
    // Pass json['user'] here, or the root json if already unwrapped
    return UserModel(
      id: json['_id'] as String, // ✅ '_id' not 'id'
      name: json['name'] as String,
      email: json['email'] as String,
      avatarUrl: json['avatar_url'] as String?, // null — not in response
      isPremium: json['is_premium'] as bool? ?? false, // ✅ safe default
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null, // ✅ null — not in response
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'avatar_url': avatarUrl,
      'is_premium': isPremium,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      name: name,
      email: email,
      avatarUrl: avatarUrl,
      isPremium: isPremium,
      createdAt: createdAt,
    );
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      avatarUrl: entity.avatarUrl,
      isPremium: entity.isPremium,
      createdAt: entity.createdAt,
    );
  }
}
