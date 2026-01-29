import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:just_hike/core/error/failures.dart';
import 'package:just_hike/features/auth/domain/entities/user_auth_entity.dart';

abstract interface class IAuthRepository {
  Future<Either<Failure, bool>> register(UserAuthEntity entity);
  Future<Either<Failure, UserAuthEntity>> login(String email, String password);
  Future<Either<Failure, UserAuthEntity>> getCurrentUser();
  Future<Either<Failure, bool>> logout();
  Future<Either<Failure, UserAuthEntity>> updateProfile({
    required String fullName,
    required String email,
    required String phoneNumber,
    File? profileImage,
  });
}
