import 'package:account_ledger/features/authentication/domain/usecases/delete_account_usecase.dart';
import 'package:account_ledger/features/authentication/domain/usecases/forgot_password_usecase.dart';
import 'package:account_ledger/features/authentication/domain/usecases/google_auth_usecase.dart';
import 'package:account_ledger/features/authentication/domain/usecases/resend_registration_otp_usecase.dart';
import 'package:account_ledger/features/authentication/domain/usecases/reset_password_usecase.dart';
import 'package:account_ledger/features/authentication/domain/usecases/verify_registration_otp_usecase.dart';
import 'package:account_ledger/features/authentication/domain/usecases/verify_reset_otp_usecase.dart';
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
  final VerifyRegistrationOtpUseCase verifyRegistrationOtpUseCase;
  final ResendRegistrationOtpUseCase resendRegistrationOtpUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final VerifyResetOtpUseCase verifyResetOtpUseCase;
  final ResetPasswordUseCase resetPasswordUseCase;
  final DeleteAccountUseCase deleteAccountUseCase;

  AuthBloc({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.googleAuthUsecase,
    required this.verifyRegistrationOtpUseCase,
    required this.resendRegistrationOtpUseCase,
    required this.forgotPasswordUseCase,
    required this.verifyResetOtpUseCase,
    required this.resetPasswordUseCase,
    required this.deleteAccountUseCase,
  }) : super(const AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthUnauthorizedDetected>(_onUnauthorizedDetected);
    on<AuthUserLoaded>(_onUserLoaded);
    on<GoogleAuthRequested>(_onGooleAuthRequested);
    on<AuthVerifyRegistrationOtpRequested>(_onVerifyRegistrationOtp);
    on<AuthResendRegistrationOtpRequested>(_onResendRegistrationOtp);
    on<AuthForgotPasswordRequested>(_onForgotPassword);
    on<AuthResendForgotPasswordOtpRequested>(_onResendForgotPasswordOtp);
    on<AuthVerifyResetOtpRequested>(_onVerifyResetOtp);
    on<AuthResetPasswordRequested>(_onResetPassword);
    on<AuthDeleteAccountRequested>(_onDeleteAccount);
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
      (message) => emit(
        AuthRegistrationOtpSent(email: event.email, message: message),
      ),
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

  Future<void> _onVerifyRegistrationOtp(
    AuthVerifyRegistrationOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await verifyRegistrationOtpUseCase(
      VerifyRegistrationOtpParams(email: event.email, otp: event.otp),
    );
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onResendRegistrationOtp(
    AuthResendRegistrationOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await resendRegistrationOtpUseCase(
      ResendRegistrationOtpParams(email: event.email),
    );
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) => emit(const AuthOtpResent('OTP resent to your email.')),
    );
  }

  Future<void> _onForgotPassword(
    AuthForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await forgotPasswordUseCase(
      ForgotPasswordParams(email: event.email),
    );
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (message) => emit(
        AuthForgotPasswordOtpSent(email: event.email, message: message),
      ),
    );
  }

  Future<void> _onResendForgotPasswordOtp(
    AuthResendForgotPasswordOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await forgotPasswordUseCase(
      ForgotPasswordParams(email: event.email),
    );
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (message) => emit(AuthOtpResent(message)),
    );
  }

  Future<void> _onVerifyResetOtp(
    AuthVerifyResetOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await verifyResetOtpUseCase(
      VerifyResetOtpParams(email: event.email, otp: event.otp),
    );
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (resetToken) => emit(
        AuthResetOtpVerified(email: event.email, resetToken: resetToken),
      ),
    );
  }

  Future<void> _onResetPassword(
    AuthResetPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await resetPasswordUseCase(
      ResetPasswordParams(
        resetToken: event.resetToken,
        password: event.password,
      ),
    );
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) {
        emit(const AuthPasswordResetSuccess());
        emit(const AuthUnauthenticated());
      },
    );
  }

  Future<void> _onDeleteAccount(
    AuthDeleteAccountRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await deleteAccountUseCase(const NoParams());
    result.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (_) => emit(const AuthUnauthenticated()),
    );
  }
}
