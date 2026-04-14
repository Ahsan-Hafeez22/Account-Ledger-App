import 'package:account_ledger/core/service/device_info_service.dart';
import 'package:account_ledger/features/authentication/data/datasources/social_auth_datasource.dart';
import 'package:dartz/dartz.dart';
import 'package:account_ledger/core/error/exceptions.dart';
import 'package:account_ledger/core/error/failures.dart';
import 'package:account_ledger/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:account_ledger/features/authentication/data/models/auth_response_model.dart';
import 'package:account_ledger/features/authentication/data/datasources/token_storage_datasource.dart';
import 'package:account_ledger/features/authentication/domain/entities/user_entity.dart';
import 'package:account_ledger/features/authentication/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remoteDatasource;
  final SocialAuthDataSource _socialAuthDataSource;
  final TokenStorageDataSource _tokenStorageDatasource;
  final DeviceInfoService _deviceInfoService;

  const AuthRepositoryImpl({
    required AuthRemoteDatasource remoteDatasource,
    required TokenStorageDataSource tokenStorageDatasource,
    required SocialAuthDataSource socialAuthDataSource,
    required DeviceInfoService deviceInfoService,
  }) : _remoteDatasource = remoteDatasource,
       _tokenStorageDatasource = tokenStorageDatasource,
       _socialAuthDataSource = socialAuthDataSource,
       _deviceInfoService = deviceInfoService;

  /// After access token is stored so the request is authenticated.
  /// Failures are ignored so login/sign-in still completes.
  Future<void> _registerDeviceBestEffort() async {
    try {
      final deviceData = await _deviceInfoService.getDeviceData();
      await _remoteDatasource.registerDevice(deviceData);
    } catch (_) {}
  }

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final authResponse = await _remoteDatasource.login(
        email: email,
        password: password,
      );
      final userModel = authResponse.user;
      if (authResponse.token.isEmpty) {
        throw const ServerException(
          message: 'Invalid login response: missing access token',
          code: 'missing-access-token',
        );
      }
      await _tokenStorageDatasource.storeAccessToken(authResponse.token);
      if (authResponse.refreshToken != null &&
          authResponse.refreshToken!.isNotEmpty) {
        await _tokenStorageDatasource.storeRefreshToken(
          authResponse.refreshToken!,
        );
      }
      await _registerDeviceBestEffort();
      return Right(userModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    }
  }

  @override
  Future<Either<Failure, String>> register({
    required String name,
    required String email,
    required String phone,
    required String defaultCurrency,
    required DateTime dateOfBirth,
    required String password,
  }) async {
    try {
      final message = await _remoteDatasource.register(
        name: name,
        email: email,
        phone: phone,
        defaultCurrency: defaultCurrency,
        dateOfBirth: dateOfBirth,
        password: password,
      );
      return Right(message);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    }
  }

  Future<Either<Failure, UserEntity>> _persistAuthResponse(
    AuthResponseModel authResponse,
  ) async {
    final userModel = authResponse.user;
    if (authResponse.token.isEmpty) {
      return const Left(
        ServerFailure(
          message: 'Invalid response: missing access token',
          code: 'missing-access-token',
        ),
      );
    }
    await _tokenStorageDatasource.storeAccessToken(authResponse.token);
    if (authResponse.refreshToken != null &&
        authResponse.refreshToken!.isNotEmpty) {
      await _tokenStorageDatasource.storeRefreshToken(
        authResponse.refreshToken!,
      );
    }
    return Right(userModel.toEntity());
  }

  @override
  Future<Either<Failure, UserEntity>> verifyRegistrationOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final authResponse = await _remoteDatasource.verifyRegistrationOtp(
        email: email,
        otp: otp,
      );
      final result = await _persistAuthResponse(authResponse);
      if (result.isRight()) {
        await _registerDeviceBestEffort();
      }
      return result;
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    }
  }

  @override
  Future<Either<Failure, void>> resendRegistrationOtp({
    required String email,
  }) async {
    try {
      await _remoteDatasource.resendOtp(email: email);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    }
  }

  @override
  Future<Either<Failure, String>> forgotPassword({
    required String email,
  }) async {
    try {
      final message = await _remoteDatasource.forgotPassword(email: email);
      return Right(message);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    }
  }

  @override
  Future<Either<Failure, String>> verifyResetOtp({
    required String email,
    required String otp,
  }) async {
    try {
      final token = await _remoteDatasource.verifyResetOtp(
        email: email,
        otp: otp,
      );
      return Right(token);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    }
  }

  @override
  Future<Either<Failure, void>> resetPassword({
    required String resetToken,
    required String password,
  }) async {
    try {
      await _remoteDatasource.resetPassword(
        resetToken: resetToken,
        password: password,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    }
  }

  @override
  Future<Either<Failure, void>> deleteAccount() async {
    try {
      await _remoteDatasource.deleteAccount();
      await _tokenStorageDatasource.clearTokens();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> signInWithGoogle() async {
    try {
      final authData = await _socialAuthDataSource.signInWithGoogle();

      // Exchange Google ID token with your API (same tokens/user shape as email login).
      final authResponse = await _remoteDatasource.authenticateWithSocial(
        authData,
      );
      final userModel = authResponse.user;
      if (authResponse.token.isNotEmpty) {
        await _tokenStorageDatasource.storeAccessToken(authResponse.token);
      }
      if (authResponse.refreshToken != null &&
          authResponse.refreshToken!.isNotEmpty) {
        await _tokenStorageDatasource.storeRefreshToken(
          authResponse.refreshToken!,
        );
      }
      await _registerDeviceBestEffort();
      return Right(userModel.toEntity());
    } on CancelledException catch (e) {
      return Left(CancelledFailure(message: e.message, code: e.code));
    } on AuthException catch (e) {
      return Left(AuthFailure(message: e.message, code: e.code));
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } catch (e) {
      return Left(
        ServerFailure(
          message: 'Unexpected error during Google sign-in: ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await _remoteDatasource.logout();
      await _tokenStorageDatasource.clearTokens();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    }
  }

  @override
  Future<Either<Failure, void>> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      await _remoteDatasource.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message, code: e.code));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    }
  }
}
