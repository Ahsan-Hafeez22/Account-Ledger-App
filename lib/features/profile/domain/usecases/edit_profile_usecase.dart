import 'dart:typed_data';

import 'package:account_ledger/features/authentication/domain/entities/user_entity.dart';
import 'package:account_ledger/features/profile/domain/repositories/profile_repository.dart';

class EditProfileUseCase {
  final ProfileRepository _repo;
  const EditProfileUseCase(this._repo);

  Future<UserEntity> call({
    required UserEntity currentUser,
    String? name,
    String? phone,
    DateTime? dateOfBirth,
    Uint8List? avatarBytes,
    String? avatarFilename,
  }) {
    return _repo.editProfile(
      currentUser: currentUser,
      name: name,
      phone: phone,
      dateOfBirth: dateOfBirth,
      avatarBytes: avatarBytes,
      avatarFilename: avatarFilename,
    );
  }
}

