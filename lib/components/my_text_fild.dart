import 'package:flutter/material.dart';

class MyTextFild extends StatelessWidget {
  final TextEditingController controlertext;
  final bool obscruteText;
  final String libertext;
  const MyTextFild({
    super.key,
    required this.controlertext,
    required this.obscruteText,
    required this.libertext,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      // scrollPadding: EdgeInsets.symmetric(horizontal: 20),
      controller: controlertext,
      obscureText: obscruteText,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.symmetric(horizontal: 20),
        labelText: libertext,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
