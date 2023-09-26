class ConnectionException implements Exception {
  final String? cause;
  final int? code;
  final String? type;
  ConnectionException(
      {required this.cause, required this.code, required this.type});

  @override
  String toString() {
    return "Connection Exception: $cause code: $code type: $type";
  }
}
