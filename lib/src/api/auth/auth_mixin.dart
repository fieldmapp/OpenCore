part of core;

/// Mixin which forces the implementation of `onLogout` and `onLogin`
/// used for Modules which are depending on external authentication
mixin ModuleAuth {
  FutureOr<void> onLogout();
  FutureOr<void> onLogin();
}

mixin WidgetAuth<T extends StatefulWidget> on State<T> {
  FutureOr<void> onLogout();
  FutureOr<void> onLogin();

  ApiAuthRepository get auth;

  @override
  void initState() {
    super.initState();
    auth.addListeners(onLogin: onLogin, onLogout: onLogout);
  }

  @override
  void dispose() {
    // Don't forget to clean up listeners when the widget is disposed
    // auth.removeListeners(onLogin: onLogin, onLogout: onLogout);
    super.dispose();
  }
}

/// Mixin which forces the implementation of `onLogout` and `onLogin`
/// used for Repositories which are depending on external authentication
mixin RepositoryAuth {
  FutureOr<void> onLogout();
  FutureOr<void> onLogin();
}
