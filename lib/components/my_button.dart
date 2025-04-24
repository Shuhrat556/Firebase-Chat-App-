import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final void Function()? onTab;
  final String textButton;
  const MyButton({super.key, required this.onTab, required this.textButton});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTab,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 20),
        alignment: Alignment.center,
        child: Text(textButton),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.blueAccent,
        ),
      ),
    );
  }
}
