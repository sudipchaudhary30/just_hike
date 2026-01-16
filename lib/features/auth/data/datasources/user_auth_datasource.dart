import 'package:just_hike/features/auth/data/models/auth_api_model.dart';
import 'package:just_hike/features/auth/data/models/user_auth_hive_model.dart';

abstract interface class IAuthDataSource {
  Future<bool> register(UserAuthHiveModel model);
  Future<UserAuthHiveModel?> login(String email, String password);
  Future<UserAuthHiveModel?> getCurrentUser();
  Future<bool> logout();
  Future<UserAuthHiveModel?> getuserById(String authId);
  Future<UserAuthHiveModel?> getUserByEmail(String email);
  Future<bool> updateuser(AuthApiModel user);
  Future<bool> deleteUser(String authId);
}

abstract interface class IAuthRemoteDataSource {
  Future<AuthApiModel> register(AuthApiModel user);
  Future<AuthApiModel?> login(String email, String password);
  Future<AuthApiModel?> getUserById(String authId);
}
