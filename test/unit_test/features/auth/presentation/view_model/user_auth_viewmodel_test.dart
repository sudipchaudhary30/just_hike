import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_hike/core/error/failures.dart';
import 'package:just_hike/features/auth/domain/entities/user_auth_entity.dart';
import 'package:just_hike/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:just_hike/features/auth/domain/usecases/user_login_usecase.dart';
import 'package:just_hike/features/auth/domain/usecases/user_register_usecase.dart';
import 'package:just_hike/features/auth/presentation/state/user_auth_state.dart';
import 'package:just_hike/features/auth/presentation/view_model/user_auth_viewmodel.dart';
import 'package:mocktail/mocktail.dart';

class MockRegisterUsecase extends Mock implements RegisterUsecase {}

class MockLoginUsecase extends Mock implements LoginUsecase {}

class MockUpdateProfileUsecase extends Mock implements UpdateProfileUsecase {}

void main() {
  group('AuthViewmodel unit tests', () {
    late ProviderContainer container;
    late MockRegisterUsecase mockRegisterUsecase;
    late MockLoginUsecase mockLoginUsecase;
    late MockUpdateProfileUsecase mockUpdateProfileUsecase;

    const tEmail = 'sudip@test.com';
    const tPassword = 'password123';
    const tFullName = 'Sudip';
    const tPhoneNumber = '9841854622';

    const tUser = UserAuthEntity(
      userAuthId: 'user-1',
      fullName: tFullName,
      email: tEmail,
      password: tPassword,
      phoneNumber: tPhoneNumber,
    );

    setUpAll(() {
      registerFallbackValue(
        const RegisterUsecaseParams(
          fullName: tFullName,
          email: tEmail,
          password: tPassword,
        ),
      );
      registerFallbackValue(
        const LoginUsecaseParams(email: tEmail, password: tPassword),
      );
      registerFallbackValue(
        const UpdateProfileUsecaseParams(
          fullName: tFullName,
          email: tEmail,
          phoneNumber: tPhoneNumber,
        ),
      );
    });

    setUp(() {
      mockRegisterUsecase = MockRegisterUsecase();
      mockLoginUsecase = MockLoginUsecase();
      mockUpdateProfileUsecase = MockUpdateProfileUsecase();

      container = ProviderContainer(
        overrides: [
          registerUsecaseProvider.overrideWithValue(mockRegisterUsecase),
          loginUsecaseProvider.overrideWithValue(mockLoginUsecase),
          updateProfileUsecaseProvider.overrideWithValue(
            mockUpdateProfileUsecase,
          ),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state should be AuthStatus.initial', () {
      final state = container.read(authViewmodelProvider);

      expect(state.status, AuthStatus.initial);
      expect(state.authEntity, isNull);
      expect(state.errorMessage, isNull);
    });

    test('register success should set state to registered', () async {
      when(
        () => mockRegisterUsecase(any()),
      ).thenAnswer((_) async => const Right(true));

      final notifier = container.read(authViewmodelProvider.notifier);
      await notifier.register(
        fullName: tFullName,
        email: tEmail,
        password: tPassword,
      );

      final state = container.read(authViewmodelProvider);
      expect(state.status, AuthStatus.registered);
      verify(() => mockRegisterUsecase(any())).called(1);
    });

    test('register failure should set error status and message', () async {
      const failure = ApiFailure(message: 'Register failed');
      when(
        () => mockRegisterUsecase(any()),
      ).thenAnswer((_) async => const Left(failure));

      final notifier = container.read(authViewmodelProvider.notifier);
      await notifier.register(
        fullName: tFullName,
        email: tEmail,
        password: tPassword,
      );

      final state = container.read(authViewmodelProvider);
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, 'Register failed');
    });

    test('register should set loading state immediately', () async {
      when(
        () => mockRegisterUsecase(any()),
      ).thenAnswer((_) async => const Right(true));

      final notifier = container.read(authViewmodelProvider.notifier);
      final future = notifier.register(
        fullName: tFullName,
        email: tEmail,
        password: tPassword,
      );

      expect(container.read(authViewmodelProvider).status, AuthStatus.loading);
      await future;
    });

    test('login success should set authenticated state with user', () async {
      when(
        () => mockLoginUsecase(any()),
      ).thenAnswer((_) async => const Right(tUser));

      final notifier = container.read(authViewmodelProvider.notifier);
      await notifier.login(email: tEmail, password: tPassword);

      final state = container.read(authViewmodelProvider);
      expect(state.status, AuthStatus.authenticated);
      expect(state.authEntity, tUser);
      verify(() => mockLoginUsecase(any())).called(1);
    });

    test('login failure should set error status and message', () async {
      const failure = ApiFailure(message: 'Invalid credentials');
      when(
        () => mockLoginUsecase(any()),
      ).thenAnswer((_) async => const Left(failure));

      final notifier = container.read(authViewmodelProvider.notifier);
      await notifier.login(email: tEmail, password: tPassword);

      final state = container.read(authViewmodelProvider);
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, 'Invalid credentials');
    });

    test('login should set loading state immediately', () async {
      when(
        () => mockLoginUsecase(any()),
      ).thenAnswer((_) async => const Right(tUser));

      final notifier = container.read(authViewmodelProvider.notifier);
      final future = notifier.login(email: tEmail, password: tPassword);

      expect(container.read(authViewmodelProvider).status, AuthStatus.loading);
      await future;
    });

    test(
      'updateProfile success should set authenticated state with user',
      () async {
        when(
          () => mockUpdateProfileUsecase(any()),
        ).thenAnswer((_) async => const Right(tUser));

        final notifier = container.read(authViewmodelProvider.notifier);
        await notifier.updateProfile(
          fullName: tFullName,
          email: tEmail,
          phoneNumber: tPhoneNumber,
        );

        final state = container.read(authViewmodelProvider);
        expect(state.status, AuthStatus.authenticated);
        expect(state.authEntity, tUser);
        verify(() => mockUpdateProfileUsecase(any())).called(1);
      },
    );

    test('updateProfile failure should set error status and message', () async {
      const failure = ApiFailure(message: 'Update failed');
      when(
        () => mockUpdateProfileUsecase(any()),
      ).thenAnswer((_) async => const Left(failure));

      final notifier = container.read(authViewmodelProvider.notifier);
      await notifier.updateProfile(
        fullName: tFullName,
        email: tEmail,
        phoneNumber: tPhoneNumber,
      );

      final state = container.read(authViewmodelProvider);
      expect(state.status, AuthStatus.error);
      expect(state.errorMessage, 'Update failed');
    });

    test('updateProfile should set loading state immediately', () async {
      when(
        () => mockUpdateProfileUsecase(any()),
      ).thenAnswer((_) async => const Right(tUser));

      final notifier = container.read(authViewmodelProvider.notifier);
      final future = notifier.updateProfile(
        fullName: tFullName,
        email: tEmail,
        phoneNumber: tPhoneNumber,
      );

      expect(container.read(authViewmodelProvider).status, AuthStatus.loading);
      await future;
    });
  });
}
