import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

//Local Database Failure
class LocalDatabaseFailure extends Failure {
  const LocalDatabaseFailure({
    String message = 'Local database operation Failed',
  }) : super(message);
}

//API Failure with status code
class ApiFailure extends Failure {
  final int? statuscode;

  const ApiFailure({required String message, this.statuscode}) : super(message);

  @override
  List<Object?> get props => [message, statuscode];
}
