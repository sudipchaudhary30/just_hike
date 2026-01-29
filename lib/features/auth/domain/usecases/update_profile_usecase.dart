import 'dart:io';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_hike/core/error/failures.dart';
import 'package:just_hike/core/usecases/app_usecase.dart';
import 'package:just_hike/features/auth/data/repositories/user_auth_repository.dart';
import 'package:just_hike/features/auth/domain/entities/user_auth_entity.dart';
import 'package:just_hike/features/auth/domain/repositories/user_auth_repository.dart';

class UpdateProfileUsecaseParams extends Equatable {
  final String fullName;
  final String email;
  final String phoneNumber;
  final File? profileImage;

  const UpdateProfileUsecaseParams({
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.profileImage,
  });

  @override
  List<Object?> get props => [fullName, email, phoneNumber, profileImage];
}

// Provider for UpdateProfileUsecase
final updateProfileUsecaseProvider = Provider<UpdateProfileUsecase>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return UpdateProfileUsecase(authRepository: authRepository);
});

class UpdateProfileUsecase
    implements UsecaseWithParams<UserAuthEntity, UpdateProfileUsecaseParams> {
  final IAuthRepository _authRepository;

  UpdateProfileUsecase({required IAuthRepository authRepository})
    : _authRepository = authRepository;

  @override
  Future<Either<Failure, UserAuthEntity>> call(
    UpdateProfileUsecaseParams params,
  ) {
    return _authRepository.updateProfile(
      fullName: params.fullName,
      email: params.email,
      phoneNumber: params.phoneNumber,
      profileImage: params.profileImage,
    );
  }
}
