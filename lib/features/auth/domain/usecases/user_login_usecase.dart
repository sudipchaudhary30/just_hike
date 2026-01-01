import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_hike/core/error/failures.dart';
import 'package:just_hike/core/usecases/app_usecase.dart';
import 'package:just_hike/features/auth/data/repositories/user_auth_repository.dart';
import 'package:just_hike/features/auth/domain/entities/user_auth_entity.dart';
import 'package:just_hike/features/auth/domain/repositories/user_auth_repository.dart';

class LoginUsecaseParams extends Equatable {
  final String email;
  final String password;

  const LoginUsecaseParams({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

//provider fpr loginusecase
final loginUsecaseProvider = Provider<LoginUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return LoginUsecase(authRepository: authRepository);
});

class LoginUsecase
    implements UsecaseWithParams<UserAuthEntity, LoginUsecaseParams> {
  final IAuthRepository _authRepository;

  LoginUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, UserAuthEntity>> call(LoginUsecaseParams params) {
    return _authRepository.login(params.email, params.password);
  }
}
