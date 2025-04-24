import 'package:flutter/material.dart';
import 'package:chat/components/my_button.dart';
import 'package:chat/components/my_text_fild.dart';
import 'package:chat/pakage/home_page.dart';
import 'package:chat/service/auth/auth_service.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  LoginPage({super.key, required this.onTab});
  final void Function() onTab;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailControler = TextEditingController();

  final passwordControler = TextEditingController();

  void signIn() async {
    final authService = Provider.of<AuthService>(context, listen: false);

    try {
      await authService.signinGmailandPassword(
        emailControler.text,
        passwordControler.text,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Chat App")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Login", style: TextStyle(fontSize: 30)),
              SizedBox(height: 60),

              MyTextFild(
                controlertext: emailControler,
                obscruteText: false,
                libertext: "Email",
              ),
              SizedBox(height: 30),
              MyTextFild(
                controlertext: passwordControler,
                obscruteText: true,
                libertext: "Password",
              ),
              SizedBox(height: 50),
              MyButton(textButton: "Login", onTab: () => signIn()),
              TextButton(
                child: Text("Register"),
                onPressed: () => widget.onTab(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
