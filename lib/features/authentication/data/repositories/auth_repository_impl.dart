import 'package:dartz/dartz.dart';
import 'package:account_ledger/core/error/exceptions.dart';
import 'package:account_ledger/core/error/failures.dart';
import 'package:account_ledger/features/authentication/data/datasources/auth_local_datasource.dart';
import 'package:account_ledger/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:account_ledger/features/authentication/data/datasources/token_storage_datasource.dart';
import 'package:account_ledger/features/authentication/domain/entities/user_entity.dart';
import 'package:account_ledger/features/authentication/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDatasource;
  final AuthLocalDatasource localDatasource;
  final TokenStorageDataSource tokenStorageDatasource;

  const AuthRepositoryImpl({
    required this.remoteDatasource,
    required this.localDatasource,
    required this.tokenStorageDatasource,
  });

  @override
  Future<Either<Failure, UserEntity>> login({
    required String email,
    required String password,
  }) async {
    try {
      final authResponse = await remoteDatasource.login(
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
      await tokenStorageDatasource.storeAccessToken(authResponse.token);
      await localDatasource.cacheUser(userModel);
      return Right(userModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final authResponse = await remoteDatasource.register(
        name: name,
        email: email,
        password: password,
      );
      final userModel = authResponse.user;
      if (authResponse.token.isNotEmpty) {
        await tokenStorageDatasource.storeAccessToken(authResponse.token);
      }
      await localDatasource.cacheUser(userModel);
      return Right(userModel.toEntity());
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      await remoteDatasource.logout();
      await tokenStorageDatasource.clearTokens();
      await localDatasource.clearCache();
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getCachedUser() async {
    try {
      final userModel = await localDatasource.getCachedUser();
      return Right(userModel.toEntity());
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    }
  }
}
