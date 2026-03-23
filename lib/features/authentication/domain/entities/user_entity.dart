import 'package:equatable/equatable.dart';

class UserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl; // not in login response, fetched later
  final bool isPremium; // defaulted to false from login response
  final DateTime? createdAt; // ✅ nullable — login response omits this

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.isPremium = false, // ✅ default
    this.createdAt, // ✅ nullable
  });

  @override
  List<Object?> get props => [id, name, email, avatarUrl, isPremium, createdAt];
}
