import 'dart:typed_data';

import 'package:account_ledger/features/authentication/domain/entities/user_entity.dart';
import 'package:account_ledger/features/profile/domain/usecases/edit_profile_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'profile_event.dart';
part 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final EditProfileUseCase _edit;

  ProfileBloc({required EditProfileUseCase editProfileUseCase})
      : _edit = editProfileUseCase,
        super(const ProfileState.initial()) {
    on<ProfileUpdateRequested>(_onUpdateRequested);
    on<ProfileStateResetRequested>((event, emit) => emit(const ProfileState.initial()));
  }

  Future<void> _onUpdateRequested(
    ProfileUpdateRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(submitting: true, clearError: true));
    try {
      final user = await _edit.call(
        currentUser: event.currentUser,
        name: event.name,
        phone: event.phone,
        dateOfBirth: event.dateOfBirth,
        avatarBytes: event.avatarBytes,
        avatarFilename: event.avatarFilename,
      );
      emit(state.copyWith(submitting: false, updatedUser: user));
    } catch (e) {
      emit(
        state.copyWith(
          submitting: false,
          errorMessage: 'Failed to update profile',
        ),
      );
    }
  }
}

