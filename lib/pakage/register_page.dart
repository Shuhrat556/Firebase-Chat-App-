import 'package:flutter/material.dart';
import 'package:chat/components/my_button.dart';
import 'package:chat/components/my_text_fild.dart';
import 'package:chat/pakage/home_page.dart';
import 'package:chat/service/auth/auth_service.dart';
import 'package:provider/provider.dart';

class RegisternPage extends StatelessWidget {
  RegisternPage({super.key, required this.onTab});
  final emailControler = TextEditingController();
  final passwordControler = TextEditingController();
  final configPasswordControler = TextEditingController();
  final void Function() onTab;

  void signUp(context) async {
    if (passwordControler.text != configPasswordControler.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Password do not match!")));
      return;
    }
    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      await authService.signUpWithLoginPassword(
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
              SizedBox(height: 30),
              MyTextFild(
                controlertext: configPasswordControler,
                obscruteText: true,
                libertext: "Confil Password",
              ),
              SizedBox(height: 50),
              MyButton(textButton: "Register", onTab: () => signUp(context)),
              TextButton(child: Text("Login"), onPressed: () => onTab()),
            ],
          ),
        ),
      ),
    );
  }
}
