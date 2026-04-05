part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final UserEntity user;

  const AuthAuthenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthFailure extends AuthState {
  final String message;

  const AuthFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthRegistrationOtpSent extends AuthState {
  final String email;
  final String message;

  const AuthRegistrationOtpSent({required this.email, required this.message});

  @override
  List<Object?> get props => [email, message];
}

class AuthForgotPasswordOtpSent extends AuthState {
  final String email;
  final String message;

  const AuthForgotPasswordOtpSent({required this.email, required this.message});

  @override
  List<Object?> get props => [email, message];
}

class AuthResetOtpVerified extends AuthState {
  final String email;
  final String resetToken;

  const AuthResetOtpVerified({required this.email, required this.resetToken});

  @override
  List<Object?> get props => [email, resetToken];
}

class AuthOtpResent extends AuthState {
  final String message;

  const AuthOtpResent(this.message);

  @override
  List<Object?> get props => [message];
}

class AuthPasswordResetSuccess extends AuthState {
  const AuthPasswordResetSuccess();
}

class AuthChangePasswordSuccess extends AuthState {
  const AuthChangePasswordSuccess();
}
