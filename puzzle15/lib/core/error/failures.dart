import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Ошибка сервера']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Нет соединения с сервером']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Ошибка локального хранилища']);
}

class ValidationFailure extends Failure {
  const ValidationFailure([super.message = 'Ошибка валидации']);
}
