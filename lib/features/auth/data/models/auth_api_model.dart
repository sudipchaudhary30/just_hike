import 'package:just_hike/features/auth/domain/entities/user_auth_entity.dart';

class AuthApiModel {
  final String? userAuthId;
  final String fullName;
  final String email;
  final String? password;
  final String? profilePicture;
  final String? phoneNumber;

  AuthApiModel({
    this.userAuthId,
    required this.fullName,
    required this.email,
    this.password,
    this.profilePicture,
    this.phoneNumber,
  });

  //toJSon
  Map<String, dynamic> toJson() {
    return {
      "userAuthId": userAuthId,
      "name": fullName,
      "email": email,
      "password": password,
      "profilePicture": profilePicture,
      "phoneNumber": phoneNumber,
    };
  }

  //fromJson
  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      userAuthId: json["_id"] as String?,
      fullName: json["name"] as String,
      email: json["email"] as String,
      password: json["password"] as String?,
      profilePicture: json["profilePicture"] as String?,
      phoneNumber: json["phoneNumber"] as String?,
    );
  }

  //toEntity
  UserAuthEntity toEntity() {
    return UserAuthEntity(
      userAuthId: userAuthId,
      fullName: fullName,
      email: email,
      password: password,
      profilePicture: profilePicture,
      phoneNumber: phoneNumber,
    );
  }

  //fromEntity
  factory AuthApiModel.fromEntity(UserAuthEntity entity) {
    return AuthApiModel(
      userAuthId: entity.userAuthId,
      fullName: entity.fullName,
      email: entity.email,
      password: entity.password,
      profilePicture: entity.profilePicture,
      phoneNumber: entity.phoneNumber,
    );
  }
}
