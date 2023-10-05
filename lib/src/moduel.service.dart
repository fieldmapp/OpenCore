part of core;

class ModuleService<T extends AppModule> {
  final T module;

  const ModuleService({required this.module});
}
