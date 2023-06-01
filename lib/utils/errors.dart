class FatalException implements Exception {
  final String message;
  FatalException(this.message);

  @override
  String toString() {
    return message;
  }
}

class NotLoginError extends FatalException {
  NotLoginError() : super('Not login');
}

class ServerError extends FatalException {
  final String errorMsg;
  ServerError({required this.errorMsg}) : super(errorMsg);
}