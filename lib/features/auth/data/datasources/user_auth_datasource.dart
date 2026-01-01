import 'package:just_hike/features/auth/data/models/user_auth_hive_model.dart';

abstract interface class IAuthDataSource {
  Future<bool> register(UserAuthHiveModel model);
  Future<UserAuthHiveModel?> login(String email, String password);
  Future<UserAuthHiveModel?> getCurrentUser();
  Future<bool> logout();
  Future<bool> isEmailExists(String email);
}
