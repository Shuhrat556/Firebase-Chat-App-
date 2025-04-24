import 'package:flutter/material.dart';
import 'package:chat/pakage/login_page.dart';
import 'package:chat/pakage/register_page.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {
  bool shoowLoginPage = true;

  void tagglePage() {
    setState(() {
      shoowLoginPage = !shoowLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (shoowLoginPage) {
      return LoginPage(onTab: tagglePage);
    } else {
      return RegisternPage(onTab: tagglePage);
    }
    
  }
}
