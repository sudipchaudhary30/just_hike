import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_hike/core/error/failures.dart';
import 'package:just_hike/core/usecases/app_usecase.dart';
import 'package:just_hike/features/auth/data/repositories/user_auth_repository.dart';
import 'package:just_hike/features/auth/domain/entities/user_auth_entity.dart';
import 'package:just_hike/features/auth/domain/repositories/user_auth_repository.dart';

class RegisterUsecaseParams extends Equatable {
  final String fullName;
  final String email;
  final String password;

  const RegisterUsecaseParams({
    required this.fullName,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [
    fullName,
    email,
    password,
  ];
}

//provider
final registerUsecaseProvider = Provider<RegisterUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return RegisterUsecase(authRepository: authRepository);
});

class RegisterUsecase
    implements UsecaseWithParams<bool, RegisterUsecaseParams> {
  final IAuthRepository _authRepository;

  RegisterUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, bool>> call(RegisterUsecaseParams params) {
    final entity = UserAuthEntity(
      fullName: params.fullName,
      email: params.email,
      password: params.password,
    );
    return _authRepository.register(entity);
  }
}
