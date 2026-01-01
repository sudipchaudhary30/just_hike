import 'package:equatable/equatable.dart';

class UserAuthEntity extends Equatable {
  final String? donorAuthId;
  final String fullName;
  final String email;
  final String? password;

  const UserAuthEntity({
    this.donorAuthId,
    required this.fullName,
    required this.email,
    this.password,
  });

  @override
  List<Object?> get props => [donorAuthId, fullName, email, password];
}
