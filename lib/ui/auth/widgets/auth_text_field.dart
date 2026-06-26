import 'package:flutter/material.dart';

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.labelText,
    this.keyboardType,
    this.autofillHints,
    this.obscureText = false,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final String labelText;
  final TextInputType? keyboardType;
  final Iterable<String>? autofillHints;
  final bool obscureText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      autofillHints: autofillHints,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        border: const OutlineInputBorder(),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
