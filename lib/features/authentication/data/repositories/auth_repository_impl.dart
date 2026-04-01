import 'package:account_ledger/features/authentication/data/datasources/social_auth_datasource.dart';
import 'package:dartz/dartz.dart';
import 'package:account_ledger/core/error/exceptions.dart';
import 'package:account_ledger/core/error/failures.dart';
import 'package:account_ledger/features/authentication/data/datasources/auth_local_datasource.dart';
import 'package:account_ledger/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:account_ledger/features/authentication/data/datasources/token_storage_datasource.dart';
import 'package:account_ledger/features/authentication/domain/entities/user_entity.dart';
import 'package:account_ledger/features/authentication/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource _remoteDatasource;
  final AuthLocalDatasource _localDatasource;
  final SocialAuthDataSource _socialAuthDataSource;
  final TokenStorageDataSource _tokenStorageDatasource;

  const AuthRepositoryImpl({
    required AuthRemoteDatasource remoteDatasource,
    required AuthLocalDatasource localDatasource,
    required TokenStorageDataSource tokenStorageDatasource,
    required SocialAuthDataSource socialAuthDataSource,
  }) : _remoteDatasource = remoteDatasource,
       _localDatasource = localDatasource,
       _tokenStorageDatasource = tokenStorageDatasource,
       _socialAuthDataSource = socialAuthDataSource;

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
      await _localDatasource.cacheUser(userModel);
      return Right(userModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final authResponse = await _remoteDatasource.register(
        name: name,
        email: email,
        password: password,
      );
      final userModel = authResponse.user;
      if (authResponse.token.isNotEmpty) {
        await _tokenStorageDatasource.storeAccessToken(authResponse.token);
      }
      await _localDatasource.cacheUser(userModel);
      return Right(userModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
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
      final backendUser = await _remoteDatasource.authenticateWithSocial(
        authData,
      );
      final userModel = backendUser.user;
      if (backendUser.token.isNotEmpty) {
        await _tokenStorageDatasource.storeAccessToken(backendUser.token);
      }
      return Right(userModel);
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
      await _localDatasource.clearCache();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: 'Unexpected error: $e'));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(message: e.message, code: e.code));
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCachedUser() async {
    try {
      final userModel = await _localDatasource.getCachedUser();
      return Right(userModel.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(message: e.message, code: e.code));
    }
  }
}
