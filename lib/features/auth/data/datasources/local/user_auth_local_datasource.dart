import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_hike/core/services/hive/hive_service.dart';
import 'package:just_hike/core/services/storage/user_session_service.dart';
import 'package:just_hike/features/auth/data/datasources/user_auth_datasource.dart';
import 'package:just_hike/features/auth/data/models/auth_api_model.dart';
import 'package:just_hike/features/auth/data/models/user_auth_hive_model.dart';

final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref) {
  final hiveService = ref.read(hiveServiceProvider);
  final userSessionService = ref.read(UserSessionServiceProvider);
  return AuthLocalDatasource(hiveService: hiveService, userSessionService: userSessionService);
});

class AuthLocalDatasource implements IAuthDataSource {
  final HiveService _hiveService;
  final UserSessionService _userSessionService;

  AuthLocalDatasource({required HiveService hiveService,
  required UserSessionService userSessionService,})
    : _hiveService = hiveService,
    _userSessionService = userSessionService;

  @override
  Future<UserAuthHiveModel?> getCurrentUser() {
    throw UnimplementedError();
  }

  @override
  Future<bool> isEmailExists(String email) {
    try {
      final exists = _hiveService.isEmailExists(email);
      return Future.value(exists);
    } catch (e) {
      return Future.value(false);
    }
  }

  @override
  Future<UserAuthHiveModel?> login(String email, String password) async {
    try {
      final user = await _hiveService.login(email, password);
      if (user != null) {
        await _userSessionService.saveUserSession(
          userId: user.userAuthId ?? '', 
          email: user.email, 
          fullName: user.fullName, 
          phoneNumber: user.phoneNumber ?? '');
      }
      return Future.value(user);
    } catch (e) {
      return Future.value(null);
    }
  }

  @override
  Future<bool> logout() async {
    try {
      await _hiveService.logout();
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  }

  @override
  Future<bool> register(UserAuthHiveModel model) async {
    try {
      await _hiveService.register(model);
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  }

  @override
  Future<bool> deleteUser(String authId) {
    // TODO: implement deleteUser
    throw UnimplementedError();
  }

  @override
  Future<UserAuthHiveModel?> getUserByEmail(String email) {
    // TODO: implement getUserByEmail
    throw UnimplementedError();
  }

  @override
  Future<UserAuthHiveModel?> getuserById(String authId) {
    // TODO: implement getuserById
    throw UnimplementedError();
  }

  @override
  Future<bool> updateuser(AuthApiModel user) {
    // TODO: implement updateuser
    throw UnimplementedError();
  }
}
