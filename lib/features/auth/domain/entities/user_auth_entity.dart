import 'package:equatable/equatable.dart';

class UserAuthEntity extends Equatable {
  final String? userAuthId;
  final String fullName;
  final String email;
 


  const UserAuthEntity({
    this.userAuthId,
    required this.fullName,
    required this.email,
    this.password, 
    this.profilePicture, 
    this.phoneNumber,
  });

  @override
  List<Object?> get props => [userAuthId, fullName, email, password];
}
