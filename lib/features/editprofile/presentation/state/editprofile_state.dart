import 'package:equatable/equatable.dart';

enum EditprofileStatus { initial, loading, success, error }

class EditprofileState extends Equatable {
  final EditprofileStatus status;
  final String? fullName;
  final String? email;
  final String? phoneNumber;
  final String? bio;
  final String? errorMessage;

  const EditprofileState({
    this.status = EditprofileStatus.initial,
    this.fullName,
    this.email,
    this.phoneNumber,
    this.bio,
    this.errorMessage,
  });

  factory EditprofileState.initial() {
    return const EditprofileState(
      status: EditprofileStatus.initial,
    );
  }

  EditprofileState copyWith({
    EditprofileStatus? status,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? bio,
    String? errorMessage,
  }) {
    return EditprofileState(
      status: status ?? this.status,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      bio: bio ?? this.bio,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, fullName, email, phoneNumber, bio, errorMessage];
}