import 'package:hive/hive.dart';
import 'package:just_hike/core/constants/hive_table_constant.dart';
import 'package:uuid/uuid.dart';
import 'package:just_hike/features/auth/domain/entities/user_auth_entity.dart';

part 'user_auth_hive_model.g.dart';

@HiveType(typeId: HiveTableConstant.userAuthTypeId)
class UserAuthHiveModel extends HiveObject {
  @HiveField(0)
  final String? userAuthId;
  @HiveField(1)
  final String fullName;
  @HiveField(2)
  final String email;
  @HiveField(3)
  final String? phoneNumber;
  @HiveField(4)
  final String? password;
  @HiveField(5)
  final String? profilePicture;

  UserAuthHiveModel({
    String? userAuthId,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.password,
    required this.profilePicture,
  }) : userAuthId = userAuthId ?? Uuid().v4();

  factory UserAuthHiveModel.fromEntity(UserAuthEntity entity) {
    return UserAuthHiveModel(
      userAuthId: entity.userAuthId,
      fullName: entity.fullName,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      password: entity.password,
      profilePicture: entity.profilePicture,
    );
  }

  UserAuthEntity toEntity() {
    return UserAuthEntity(
      userAuthId: userAuthId,
      fullName: fullName, 
      email: email,
      phoneNumber: phoneNumber,
      password: password,
      profilePicture: profilePicture,
    );
  }

  //To entity List
  static List<UserAuthEntity> toEntityList(List<UserAuthHiveModel> models) {
    return models.map((model) => model.toEntity()).toList();
  }
}
