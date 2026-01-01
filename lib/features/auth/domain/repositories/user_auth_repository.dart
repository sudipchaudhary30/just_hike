import 'package:dartz/dartz.dart';
import 'package:just_hike/core/error/failures.dart';

abstract interface class IAuthRepository {
  Future<Either<Failure, bool>> register(UserAuthEntity entity);
  Future<Either<Failure, UserAuthEntity>> login(
    String email,
    String password,
  );
  Future<Either<Failure, UserAuthEntity>> getCurrentUser();
  Future<Either<Failure, bool>> logout();
}
