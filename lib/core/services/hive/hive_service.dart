import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:just_hike/core/constants/hive_table_constant.dart';
import 'package:just_hike/features/auth/data/models/user_auth_hive_model.dart';
import 'package:path_provider/path_provider.dart';

final hiveServiceProvider = Provider<HiveService>((ref) {
  return HiveService();
});

class HiveService {
  Future<void> init() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = '${directory.path}/${HiveTableConstant.dbName}';
    Hive.init(path);
    _registerAdapter();
    await openBoxes();
  }

  void _registerAdapter() {
    if (!Hive.isAdapterRegistered(HiveTableConstant.userAuthTypeId)) {
      Hive.registerAdapter(UserAuthHiveModelAdapter());
    }
  }

  Future<void> openBoxes() async {
    await Hive.openBox<UserAuthHiveModel>(HiveTableConstant.userAuthTable);
  }

  Future<void> close() async {
    await Hive.close();
  }

  //queries
  Box<UserAuthHiveModel> get _userAuthBox =>
      Hive.box<UserAuthHiveModel>(HiveTableConstant.userAuthTable);

  Future<UserAuthHiveModel> register(UserAuthHiveModel model) async {
    await _userAuthBox.put(model.userAuthId, model);
    return model;
  }

  //login
  Future<UserAuthHiveModel?> login(String email, String password) async {
    final users = _userAuthBox.values.where(
      (user) => user.email == email && user.password == password,
    );
    if (users.isNotEmpty) {
      return users.first;
    }
    return null;
  }

  //logout
  Future<void> logout() async {}

  //get current user
  UserAuthHiveModel? getCurrentUser(String userAuthId) {
    return _userAuthBox.get(userAuthId);
  }

  //is Email exists
  bool isEmailExists(String email) {
    final users = _userAuthBox.values.where((user) => user.email == email);
    return users.isNotEmpty;
  }
}
