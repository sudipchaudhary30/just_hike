import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_hike/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:just_hike/features/auth/domain/usecases/user_login_usecase.dart';
import 'package:just_hike/features/auth/domain/usecases/user_register_usecase.dart';
import 'package:just_hike/features/auth/presentation/state/user_auth_state.dart';

final authViewmodelProvider = NotifierProvider<AuthViewmodel, AuthState>(
  () => AuthViewmodel(),
);

class AuthViewmodel extends Notifier<AuthState> {
  late final RegisterUsecase _registerUsecase;
  late final LoginUsecase _loginUsecase;
  late final UpdateProfileUsecase _updateProfileUsecase;

  @override
  AuthState build() {
    _registerUsecase = ref.read(registerUsecaseProvider);
    _loginUsecase = ref.read(loginUsecaseProvider);
    _updateProfileUsecase = ref.read(updateProfileUsecaseProvider);
    return AuthState();
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    //wait for 2 sec
    await Future.delayed(const Duration(seconds: 2));
    final params = RegisterUsecaseParams(
      fullName: fullName,
      email: email,
      password: password,
    );
    final result = await _registerUsecase(params);
    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (isRegistered) {
        state = state.copyWith(status: AuthStatus.registered);
      },
    );
  }

  //login
  Future<void> login({required String email, required String password}) async {
    state = state.copyWith(status: AuthStatus.loading);
    final params = LoginUsecaseParams(email: email, password: password);
    await Future.delayed(const Duration(seconds: 2));
    final result = await _loginUsecase(params);
    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (authEntity) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          authEntity: authEntity,
        );
      },
    );
  }

  // Update profile
  Future<void> updateProfile({
    required String fullName,
    required String email,
    required String phoneNumber,
    File? profileImage,
  }) async {
    state = state.copyWith(status: AuthStatus.loading);
    final params = UpdateProfileUsecaseParams(
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      profileImage: profileImage,
    );
    final result = await _updateProfileUsecase(params);
    result.fold(
      (failure) {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: failure.message,
        );
      },
      (authEntity) {
        state = state.copyWith(
          status: AuthStatus.authenticated,
          authEntity: authEntity,
        );
      },
    );
  }
}
