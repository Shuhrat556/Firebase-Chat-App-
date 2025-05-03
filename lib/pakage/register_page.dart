import 'package:flutter/material.dart';
import 'package:chat/components/my_button.dart';
import 'package:chat/components/my_text_fild.dart';
import 'package:chat/pakage/home_page.dart';
import 'package:chat/service/auth/auth_service.dart';
import 'package:provider/provider.dart';

class RegisternPage extends StatefulWidget {
  const RegisternPage({super.key, required this.onTab});
  final void Function() onTab;

  @override
  State<RegisternPage> createState() => _RegisternPageState();
}

class _RegisternPageState extends State<RegisternPage> {
  final nameControler = TextEditingController();
  final emailControler = TextEditingController();
  final passwordControler = TextEditingController();
  final configPasswordControler = TextEditingController();
  bool _isLoading = false;

  void signUp() async {
    if (passwordControler.text != configPasswordControler.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Passwords do not match!"),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.all(10),
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final authService = Provider.of<AuthService>(context, listen: false);
    try {
      await authService.signUpWithLoginPassword(
        nameControler.text,
        emailControler.text,
        passwordControler.text,
      );
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (_) => HomePage()),
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          margin: EdgeInsets.all(10),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 60),
                Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Fill in your details to get started",
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                SizedBox(height: 48),
                MyTextFild(
                  controlertext: nameControler,
                  obscruteText: false,
                  libertext: "Full Name",
                  prefixIcon: Icon(Icons.person),
                ),
                SizedBox(height: 16),
                MyTextFild(
                  controlertext: emailControler,
                  obscruteText: false,
                  libertext: "Email",
                  prefixIcon: Icon(Icons.email),
                ),
                SizedBox(height: 16),
                MyTextFild(
                  controlertext: passwordControler,
                  obscruteText: true,
                  libertext: "Password",
                  prefixIcon: Icon(Icons.lock),
                ),
                SizedBox(height: 16),
                MyTextFild(
                  controlertext: configPasswordControler,
                  obscruteText: true,
                  libertext: "Confirm Password",
                  prefixIcon: Icon(Icons.lock),
                ),
                SizedBox(height: 32),
                MyButton(
                  textButton: "Register",
                  onTab: signUp,
                  isLoading: _isLoading,
                ),
                SizedBox(height: 24),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Already have an account?",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      TextButton(
                        onPressed: widget.onTab,
                        child: Text(
                          "Login",
                          style: TextStyle(
                            color: Colors.deepPurple,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
