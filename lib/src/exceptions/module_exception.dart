enum ModuleExceptionType {
  injection(name: "Module dep. injection failed"),
  dependency(name: "Module dependencies failed"),
  initialization(name: "Module Initialization failed"),
  general(name: "General Module Exception");
  const ModuleExceptionType({required this.name});

  final String name;
}

class ModuleException implements Exception {
  final String cause;
  final ModuleExceptionType type;
  ModuleException(
      {required this.cause, required this.type});
}
