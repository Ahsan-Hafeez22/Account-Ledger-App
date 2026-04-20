part of 'profile_bloc.dart';

sealed class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

final class ProfileUpdateRequested extends ProfileEvent {
  final UserEntity currentUser;
  final String? name;
  final String? phone;
  final DateTime? dateOfBirth;
  final Uint8List? avatarBytes;
  final String? avatarFilename;

  const ProfileUpdateRequested({
    required this.currentUser,
    this.name,
    this.phone,
    this.dateOfBirth,
    this.avatarBytes,
    this.avatarFilename,
  });

  @override
  List<Object?> get props => [
    currentUser,
    name,
    phone,
    dateOfBirth,
    avatarBytes,
    avatarFilename,
  ];
}

final class ProfileStateResetRequested extends ProfileEvent {
  const ProfileStateResetRequested();
}

