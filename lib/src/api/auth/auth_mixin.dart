import 'dart:async';

/// Mixin which forces the implementation of `onLogout` and `onLogin`
/// used for Modules which are depending on external authentication
mixin ModuleAuth {
  FutureOr<void> onLogout();
  FutureOr<void> onLogin();
}

/// Mixin which forces the implementation of `onLogout` and `onLogin`
/// used for Repositories which are depending on external authentication
mixin RepositoryAuth {
  FutureOr<void> onLogout();
  FutureOr<void> onLogin();
}
