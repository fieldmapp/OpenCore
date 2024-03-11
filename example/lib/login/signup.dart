import 'package:appwrite/appwrite.dart';
import 'package:open_core/core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key, required this.apiService, required this.onSuccess});

  final ApiAuthRepository apiService;
  final String onSuccess;

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final TextEditingController _email = TextEditingController();

  final TextEditingController _name = TextEditingController();

  final TextEditingController _password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Form(
              child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Padding(
              padding:
                  const EdgeInsets.only(left: 16.0, right: 16.0, top: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text("Register",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w200,
                          fontFamily: "Poppins-Bold",
                          letterSpacing: .6)),
                  TextFormField(
                    controller: _name,
                    decoration: const InputDecoration(
                        hintText: "User name",
                        hintStyle:
                            TextStyle(color: Colors.grey, fontSize: 12.0)),
                    obscureText: false,
                    // validator: (value)=>
                    // value.isEmpty ? validation: null,
                  ),
                  TextFormField(
                    controller: _email,
                    decoration: const InputDecoration(
                        hintText: "Email",
                        hintStyle:
                            TextStyle(color: Colors.grey, fontSize: 12.0)),
                    obscureText: false,
                    // validator: (value)=>
                    // value.isEmpty ? validation: null,
                  ),
                  TextFormField(
                    controller: _password,
                    decoration: const InputDecoration(
                        hintText: "Password",
                        hintStyle:
                            TextStyle(color: Colors.grey, fontSize: 12.0)),
                    obscureText: true,
                  ),
                ],
              ),
            ),
          )),
          IconButton(
              onPressed: () async {
                try {
                  print("#### EMAIL ###");
                  print(_email.text);
                  await widget.apiService.signup(
                      name: _name.text,
                      email: _email.text,
                      password: _password.text);
                  await widget.apiService
                      .login(email: _email.text, password: _password.text);
                  context.go(widget.onSuccess);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                      content: Text(" Successfully account created")));
                } on AppwriteException catch (e) {
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(
                    e.message ?? " Unkown Error",
                  )));
                }
              },
              icon: const Icon(Icons.check_circle_rounded))
        ],
      ),
    );
  }
}
