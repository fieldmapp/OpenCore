import 'package:example/login/signin.dart';
import 'package:example/login/signup.dart';
import 'package:open_core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AuthView extends StatelessWidget {
  const AuthView({super.key, required this.apiService, required this.onSucess});

  final ApiAuthRepository apiService;
  final String onSucess;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
              onPressed: () async {
                await showModalBottomSheet<void>(
                    context: context,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    clipBehavior: Clip.antiAlias,
                    isScrollControlled: true,
                    builder: (BuildContext context) {
                      return SignIn(
                          apiService: apiService, onSuccess: onSucess);
                    });
              },
              icon: const Icon(Icons.login)),
          IconButton(
              onPressed: () {
                showModalBottomSheet<void>(
                    context: context,
                    isScrollControlled: true,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    clipBehavior: Clip.antiAlias,
                    builder: (BuildContext context) {
                      return SignUp(
                        apiService: apiService,
                        onSuccess: onSucess,
                      );
                    });
              },
              icon: const Icon(Icons.app_registration_rounded))
        ],
      )),
    );
  }
}

class AuthLandingPage extends ModulePage {
  const AuthLandingPage(
      {super.key,
      required this.apiService,
      required this.authSuccessRoute,
      required super.module});
  final ApiAuthRepository apiService;
  final String authSuccessRoute;

  @override
  Widget build(BuildContext context) {
    if (apiService.getUser() != null) {
      context.go(authSuccessRoute);
    }
    return AuthView(apiService: apiService, onSucess: authSuccessRoute);
  }
}
