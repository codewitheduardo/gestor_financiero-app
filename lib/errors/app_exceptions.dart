abstract class AppException implements Exception {
  final String message;
  AppException(this.message);
}

class NetworkException extends AppException {
  NetworkException() : super('No se pudo conectar con el servidor');
}

class UnauthorizedException extends AppException {
  UnauthorizedException() : super('Usuario o contraseña incorrectos');
}

class ServerException extends AppException {
  ServerException() : super('Error interno del servidor');
}

class UnknownException extends AppException {
  UnknownException() : super('Ocurrió un error inesperado');
}

class ConflictException extends AppException {
  ConflictException(String msg) : super(msg);
}

class ValidationException extends AppException {
  ValidationException(String msg) : super(msg);
}
