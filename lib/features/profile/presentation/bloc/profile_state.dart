part of 'profile_bloc.dart';

class ProfileState extends Equatable {
  final bool submitting;
  final String? errorMessage;
  final UserEntity? updatedUser;

  const ProfileState({
    required this.submitting,
    required this.errorMessage,
    required this.updatedUser,
  });

  const ProfileState.initial()
      : submitting = false,
        errorMessage = null,
        updatedUser = null;

  ProfileState copyWith({
    bool? submitting,
    String? errorMessage,
    bool clearError = false,
    UserEntity? updatedUser,
  }) {
    return ProfileState(
      submitting: submitting ?? this.submitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      updatedUser: updatedUser ?? this.updatedUser,
    );
  }

  @override
  List<Object?> get props => [submitting, errorMessage, updatedUser];
}

