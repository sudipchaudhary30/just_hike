import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_hike/core/error/failures.dart';
import 'package:just_hike/core/services/connectivity/networkinfo.dart';
import 'package:just_hike/features/auth/data/datasources/local/user_auth_local_datasource.dart';
import 'package:just_hike/features/auth/data/datasources/remote/auth_remote_datasource.dart';
import 'package:just_hike/features/auth/data/datasources/user_auth_datasource.dart';
import 'package:just_hike/features/auth/data/models/auth_api_model.dart';
import 'package:just_hike/features/auth/data/models/user_auth_hive_model.dart';
import 'package:just_hike/features/auth/domain/entities/user_auth_entity.dart';
import 'package:just_hike/features/auth/domain/repositories/user_auth_repository.dart';

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final authDataSource = ref.read(authLocalDatasourceProvider);
  final authRemoteDatasource = ref.read(authRemoteProvider);
  final networkInfo = ref.read(networkInfoProvider);

  return AuthRepository(
    authDataSource: authDataSource,
    authRemoteDataSource: authRemoteDatasource,
    networkInfo: networkInfo,
  );
});

class AuthRepository implements IAuthRepository {
  final IAuthDataSource _authDataSource;
  final IAuthRemoteDataSource _authRemoteDataSource;
  final NetworkInfo _networkInfo;

  AuthRepository({
    required IAuthDataSource authDataSource,
    required authRemoteDataSource,
    required networkInfo,
  }) : _authDataSource = authDataSource,
       _authRemoteDataSource = authRemoteDataSource,
       _networkInfo = networkInfo;
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
    if (await _networkInfo.isConnected) {
      try {
        final apiModel = await _authRemoteDataSource.login(email, password);
        if (apiModel != null) {
          final entity = apiModel.toEntity();
          return Right(entity);
        }
        return const Left(ApiFailure(message: 'Invalid credentials'));
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Login Failed',
            statuscode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final model = await _authDataSource.login(email, password);
        if (model != null) {
          final entity = model.toEntity();
          return Right(entity);
        }
        return const Left(
          LocalDatabaseFailure(message: 'Invalid email or password'),
        );
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
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
  Future<Either<Failure, bool>> register(UserAuthEntity user) async {
   if (await _networkInfo.isConnected) {
      // go to remote
      try {
        final apiModel = AuthApiModel.fromEntity(user);
        await _authRemoteDataSource.register(apiModel);
        return const Right(true);
      } on DioException catch (e) {
        return Left(
          ApiFailure(
            message: e.response?.data['message'] ?? 'Registration Failed',
            statuscode: e.response?.statusCode,
          ),
        );
      } catch (e) {
        return Left(ApiFailure(message: e.toString()));
      }
    } else {
      try {
        final exisitingUser = await _authDataSource.getUserByEmail(user.email);
        if (exisitingUser != null) {
          return const Left(
            LocalDatabaseFailure(message: "Email already registered"),
          );
        }
 
        final authModel = UserAuthHiveModel(
          fullName: user.fullName,
          email: user.email,
          phoneNumber: user.phoneNumber,
          password: user.password,
          profilePicture: user.profilePicture,
        );
        await _authDataSource.register(authModel);
        return const Right(true);
      } catch (e) {
        return Left(LocalDatabaseFailure(message: e.toString()));
      }
    }
  }
  }

