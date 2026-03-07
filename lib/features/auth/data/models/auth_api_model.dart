import 'package:just_hike/features/auth/domain/entities/user_auth_entity.dart';

class AuthApiModel {
  final String? userAuthId;
  final String fullName;
  final String email;
  final String? password;
  final String? profilePicture;
  final String? phoneNumber;
  final String? token;

  AuthApiModel({
    this.userAuthId,
    required this.fullName,
    required this.email,
    this.password,
    this.profilePicture,
    this.phoneNumber,
    this.token,
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
    String? pickString(List<String> keys) {
      for (final key in keys) {
        final value = json[key];
        if (value is String && value.trim().isNotEmpty) {
          return value;
        }
      }
      return null;
    }

    final id = pickString(['_id', 'id', 'userAuthId', 'userId']);
    final fullName =
        pickString(['name', 'fullName', 'username', 'displayName']) ?? '';
    final email = pickString(['email']) ?? '';
    final profilePicture = pickString([
      'profilePicture',
      'profileImage',
      'imageUrl',
      'image',
      'avatar',
      'photo',
      'thumbnailUrl',
    ]);
    final phone = pickString(['phoneNumber', 'phone', 'mobile']);

    return AuthApiModel(
      userAuthId: id,
      fullName: fullName,
      email: email,
      password: json["password"] as String?,
      profilePicture: profilePicture,
      phoneNumber: phone,
      token: pickString(['token', 'accessToken']),
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
