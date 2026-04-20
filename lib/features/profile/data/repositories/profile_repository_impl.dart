import 'dart:typed_data';

import 'package:account_ledger/features/authentication/domain/entities/user_entity.dart';
import 'package:account_ledger/features/profile/data/datasources/profile_remote_datasource.dart';
import 'package:account_ledger/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDatasource _remote;

  const ProfileRepositoryImpl({required ProfileRemoteDatasource remote})
      : _remote = remote;

  @override
  Future<UserEntity> editProfile({
    required UserEntity currentUser,
    String? name,
    String? phone,
    DateTime? dateOfBirth,
    Uint8List? avatarBytes,
    String? avatarFilename,
  }) async {
    final patch = await _remote.editProfile(
      name: name,
      phone: phone,
      dateOfBirth: dateOfBirth,
      avatarBytes: avatarBytes,
      avatarFilename: avatarFilename,
    );
    return UserEntity(
      id: currentUser.id,
      name: patch.name ?? currentUser.name,
      email: currentUser.email,
      phone: patch.phone ?? currentUser.phone,
      avatarUrl: patch.avatarUrl ?? currentUser.avatarUrl,
      dateOfBirth: patch.dateOfBirth ?? currentUser.dateOfBirth,
      country: patch.country ?? currentUser.country,
      verified: currentUser.verified,
      emailVerifiedAt: currentUser.emailVerifiedAt,
      isActive: currentUser.isActive,
      authProvider: currentUser.authProvider,
      defaultCurrency: patch.defaultCurrency ?? currentUser.defaultCurrency,
      role: currentUser.role,
      createdAt: currentUser.createdAt,
      updatedAt: DateTime.now(),
      googleId: currentUser.googleId,
    );
  }
}

