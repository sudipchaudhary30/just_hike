import 'package:flutter/material.dart';

class MyTextformfield extends StatelessWidget {
  const MyTextformfield({
    super.key,
    required this.labelText,
    required this.hintText,
    required this.controller,
  });

  final String labelText;
  final String hintText;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,

      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        labelText: labelText,
        hintText: hintText,
      ),

      validator: (value) {
        if (value == null || value.isEmpty) {
          return "$labelText is required";
        }
        return null;
      },
    );
  }
}
