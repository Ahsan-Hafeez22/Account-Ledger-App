part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String phone;
  final String defaultCurrency;
  final DateTime dateOfBirth;
  final String password;

  const AuthRegisterRequested({
    required this.name,
    required this.email,
    required this.phone,
    required this.defaultCurrency,
    required this.dateOfBirth,
    required this.password,
  });

  @override
  List<Object?> get props => [
    name,
    email,
    phone,
    defaultCurrency,
    dateOfBirth,
    password,
  ];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthCheckStatusRequested extends AuthEvent {
  const AuthCheckStatusRequested();
}

class AuthUnauthorizedDetected extends AuthEvent {
  const AuthUnauthorizedDetected();
}

class AuthUserLoaded extends AuthEvent {
  final UserEntity user;

  const AuthUserLoaded(this.user);

  @override
  List<Object?> get props => [user];
}

class GoogleAuthRequested extends AuthEvent {
  const GoogleAuthRequested();
}

class AuthVerifyRegistrationOtpRequested extends AuthEvent {
  final String email;
  final String otp;

  const AuthVerifyRegistrationOtpRequested({
    required this.email,
    required this.otp,
  });

  @override
  List<Object?> get props => [email, otp];
}

class AuthResendRegistrationOtpRequested extends AuthEvent {
  final String email;

  const AuthResendRegistrationOtpRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

class AuthForgotPasswordRequested extends AuthEvent {
  final String email;

  const AuthForgotPasswordRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

class AuthResendForgotPasswordOtpRequested extends AuthEvent {
  final String email;

  const AuthResendForgotPasswordOtpRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

class AuthVerifyResetOtpRequested extends AuthEvent {
  final String email;
  final String otp;

  const AuthVerifyResetOtpRequested({required this.email, required this.otp});

  @override
  List<Object?> get props => [email, otp];
}

class AuthResetPasswordRequested extends AuthEvent {
  final String resetToken;
  final String password;

  const AuthResetPasswordRequested({
    required this.resetToken,
    required this.password,
  });

  @override
  List<Object?> get props => [resetToken, password];
}

class AuthChangePasswordRequested extends AuthEvent {
  final String oldPassword;
  final String newPassword;

  const AuthChangePasswordRequested({
    required this.oldPassword,
    required this.newPassword,
  });

  @override
  List<Object?> get props => [oldPassword, newPassword];
}

class AuthDeleteAccountRequested extends AuthEvent {
  const AuthDeleteAccountRequested();
}
