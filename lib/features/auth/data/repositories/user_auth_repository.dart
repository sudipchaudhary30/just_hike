import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_hike/core/error/failures.dart';
import 'package:just_hike/features/auth/data/datasources/local/user_auth_local_datasource.dart';
import 'package:just_hike/features/auth/data/datasources/user_auth_datasource.dart';
import 'package:just_hike/features/auth/data/models/user_auth_hive_model.dart';
import 'package:just_hike/features/auth/domain/entities/user_auth_entity.dart';
import 'package:just_hike/features/auth/domain/repositories/user_auth_repository.dart';

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  return AuthRepository(authDataSource: ref.read(authLocalDatasourceProvider));
});

class AuthRepository implements IAuthRepository {
  final IAuthDataSource _authDataSource;

  AuthRepository({required IAuthDataSource authDataSource})
    : _authDataSource = authDataSource;
  @override
  Future<Either<Failure, UserAuthEntity>> getCurrentUser() async {
    try {
      final user = await _authDataSource.getCurrentUser();
      if (user != null) {
        final entity = user.toEntity();
        return Right(entity);
      }
      return Left(LocalDatabaseFailure(message: 'No user logged in'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserAuthEntity>> login(
    String email,
    String password,
  ) async {
    try {
      final user = await _authDataSource.login(email, password);
      if (user != null) {
        final entity = user.toEntity();
        return Right(entity);
      }
      return Left(LocalDatabaseFailure(message: 'Invalid email or password'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> logout() async {
    try {
      final result = await _authDataSource.logout();
      if (result) {
        return Right(true);
      }
      return Left(LocalDatabaseFailure(message: 'Failed to logout user'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> register(UserAuthEntity entity) async {
    try {
      //model ma convert gara
      final model = UserAuthHiveModel.fromEntity(entity);
      final result = await _authDataSource.register(model);
      if (result) {
        return Right(true);
      }
      return Left(LocalDatabaseFailure(message: 'Failed to register User'));
    } catch (e) {
      return Left(LocalDatabaseFailure(message: e.toString()));
    }
  }
}
