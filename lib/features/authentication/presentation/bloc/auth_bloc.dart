import 'package:account_ledger/features/authentication/domain/usecases/google_auth_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:account_ledger/core/usecase/usecase.dart';
import 'package:account_ledger/features/authentication/domain/entities/user_entity.dart';
import 'package:account_ledger/features/authentication/domain/usecases/login_usecase.dart';
import 'package:account_ledger/features/authentication/domain/usecases/logout_usecase.dart';
import 'package:account_ledger/features/authentication/domain/usecases/register_usecase.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final GoogleAuthUsecase googleAuthUsecase;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.googleAuthUsecase,
  }) : super(const AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthUnauthorizedDetected>(_onUnauthorizedDetected);
    on<AuthUserLoaded>(_onUserLoaded);
    on<GoogleAuthRequested>(_onGooleAuthRequested);
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await loginUseCase(
      LoginParams(email: event.email, password: event.password),
    );
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await registerUseCase(
      RegisterParams(
        name: event.name,
        email: event.email,
        phone: event.phone,
        defaultCurrency: event.defaultCurrency,
        dateOfBirth: event.dateOfBirth,
        password: event.password,
      ),
    );
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await logoutUseCase(const NoParams());
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }

  Future<void> _onUnauthorizedDetected(
    AuthUnauthorizedDetected event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthUnauthenticated());
  }

  Future<void> _onUserLoaded(
    AuthUserLoaded event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthAuthenticated(event.user));
  }

  Future<void> _onGooleAuthRequested(
    GoogleAuthRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await googleAuthUsecase(const NoParams());
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }
}
