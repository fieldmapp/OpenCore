class ConnectionException implements Exception {
  final String? cause;
  final int? code;
  final String? type;
  ConnectionException(
      {required this.cause, required this.code, required this.type});
}
