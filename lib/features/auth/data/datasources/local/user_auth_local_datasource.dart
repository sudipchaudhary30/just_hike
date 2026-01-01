import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_hike/core/services/hive/hive_service.dart';
import 'package:just_hike/features/auth/data/datasources/user_auth_datasource.dart';
import 'package:just_hike/features/auth/data/models/user_auth_hive_model.dart';

final authLocalDatasourceProvider = Provider<AuthLocalDatasource>((ref) {
  final hiveService = ref.watch(hiveServiceProvider);
  return AuthLocalDatasource(hiveService: hiveService);
});

class AuthLocalDatasource implements IAuthDataSource {
  final HiveService _hiveService;

  AuthLocalDatasource({required HiveService hiveService})
    : _hiveService = hiveService;

  @override
  Future<UserAuthHiveModel?> getCurrentUser() {
    throw UnimplementedError();
  }

  @override
  Future<bool> isEmailExists(String email) {
    try{
      final exists=  _hiveService.isEmailExists(email);
      return Future.value(exists);
    }catch(e){
      return Future.value(false);
    }
  }

  @override
  Future<UserAuthHiveModel?> login(String email, String password) async {
    try {
      final user = await _hiveService.login(email, password);
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
}
