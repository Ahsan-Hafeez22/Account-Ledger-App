import 'dart:typed_data';

import 'package:account_ledger/features/authentication/domain/entities/user_entity.dart';

abstract class ProfileRepository {
  Future<UserEntity> editProfile({
    required UserEntity currentUser,
    String? name,
    String? phone,
    DateTime? dateOfBirth,
    Uint8List? avatarBytes,
    String? avatarFilename,
  });
}

