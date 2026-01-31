import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:just_hike/core/error/failures.dart';
import 'package:just_hike/features/auth/domain/entities/user_auth_entity.dart';
import 'package:just_hike/features/auth/domain/repositories/user_auth_repository.dart';
import 'package:just_hike/features/auth/domain/usecases/update_profile_usecase.dart';
import 'package:just_hike/features/auth/domain/usecases/user_login_usecase.dart';
import 'package:just_hike/features/auth/domain/usecases/user_register_usecase.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  group('unit testing', () {
    late MockAuthRepository mockRepository;
    late LoginUsecase loginUsecase;
    late RegisterUsecase registerUsecase;
    late UpdateProfileUsecase updateProfileUsecase;

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
      registerFallbackValue(const UserAuthEntity(
        userAuthId: 'fallback',
        fullName: 'Fallback User',
        email: 'fallback@example.com',
        password: 'fallbackPass',
        phoneNumber: '0000000000',
      ));
    });

    setUp(() {
      mockRepository = MockAuthRepository();
      loginUsecase = LoginUsecase(authRepository: mockRepository);
      registerUsecase = RegisterUsecase(authRepository: mockRepository);
      updateProfileUsecase = UpdateProfileUsecase(authRepository: mockRepository);
    });

    test('LoginUsecase should return user on success', () async {
      // Arrange
      when(() => mockRepository.login(tEmail, tPassword)).thenAnswer(
        (_) async => const Right(tUser),
      );

      // Act
      final result = await loginUsecase(
        const LoginUsecaseParams(email: tEmail, password: tPassword),
      );

      // Assert
      expect(result, const Right(tUser));
      verify(() => mockRepository.login(tEmail, tPassword)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('LoginUsecase should return failure on error', () async {
      // Arrange
      const failure = ApiFailure(message: 'Invalid credentials');
      when(() => mockRepository.login(tEmail, tPassword)).thenAnswer(
        (_) async => const Left(failure),
      );

      // Act
      final result = await loginUsecase(
        const LoginUsecaseParams(email: tEmail, password: tPassword),
      );

      // Assert
      expect(result, const Left(failure));
      verify(() => mockRepository.login(tEmail, tPassword)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('RegisterUsecase should pass entity to repository', () async {
      // Arrange
      UserAuthEntity? capturedEntity;
      when(() => mockRepository.register(any())).thenAnswer((invocation) async {
        capturedEntity = invocation.positionalArguments[0] as UserAuthEntity;
        return const Right(true);
      });

      // Act
      await registerUsecase(
        const RegisterUsecaseParams(
          fullName: tFullName,
          email: tEmail,
          password: tPassword,
        ),
      );

      // Assert
      expect(capturedEntity?.fullName, tFullName);
      expect(capturedEntity?.email, tEmail);
      expect(capturedEntity?.password, tPassword);
      expect(capturedEntity?.userAuthId, isNull);
    });

    test('UpdateProfileUsecase should forward params to repository', () async {
      // Arrange
      when(
        () => mockRepository.updateProfile(
          fullName: tFullName,
          email: tEmail,
          phoneNumber: tPhoneNumber,
          profileImage: null,
        ),
      ).thenAnswer((_) async => const Right(tUser));

      // Act
      final result = await updateProfileUsecase(
        const UpdateProfileUsecaseParams(
          fullName: tFullName,
          email: tEmail,
          phoneNumber: tPhoneNumber,
        ),
      );

      // Assert
      expect(result, const Right(tUser));
      verify(
        () => mockRepository.updateProfile(
          fullName: tFullName,
          email: tEmail,
          phoneNumber: tPhoneNumber,
          profileImage: null,
        ),
      ).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('RegisterUsecaseParams with same data should be equal', () {
      // Arrange
      const params1 = RegisterUsecaseParams(
        fullName: tFullName,
        email: tEmail,
        password: tPassword,
      );
      const params2 = RegisterUsecaseParams(
        fullName: tFullName,
        email: tEmail,
        password: tPassword,
      );

      // Act
      final isEqual = params1 == params2;

      // Assert
      expect(isEqual, true);
      expect(params1, params2);
      expect(params1.props, [tFullName, tEmail, tPassword]);
    });
  });
}