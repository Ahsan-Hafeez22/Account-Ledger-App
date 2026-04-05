import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:account_ledger/core/error/failures.dart';
import 'package:account_ledger/core/usecase/usecase.dart';
import 'package:account_ledger/features/authentication/domain/repositories/auth_repository.dart';

class RegisterUseCase extends UseCase<String, RegisterParams> {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(RegisterParams params) {
    return repository.register(
      name: params.name,
      email: params.email,
      phone: params.phone,
      defaultCurrency: params.defaultCurrency,
      dateOfBirth: params.dateOfBirth,
      password: params.password,
    );
  }
}

class RegisterParams extends Equatable {
  final String name;
  final String email;
  final String phone;
  final String defaultCurrency;
  final DateTime dateOfBirth;
  final String password;

  const RegisterParams({
    required this.name,
    required this.email,
    required this.phone,
    required this.defaultCurrency,
    required this.dateOfBirth,
    required this.password,
  });

  @override
  List<Object?> get props => [name, email, phone, defaultCurrency, dateOfBirth, password];
}
