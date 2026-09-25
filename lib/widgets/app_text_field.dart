import 'package:flutter/material.dart';

class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool requiredField;
  final TextInputType? keyboardType;
  final int? maxLength;

  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.requiredField = false,
    this.keyboardType,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLength: maxLength,
      decoration: InputDecoration(
        labelText: requiredField ? '$label *' : label,
        prefixIcon: Icon(icon),
        counterText: '',
      ),
      validator: requiredField
          ? (value) => value == null || value.trim().isEmpty
              ? 'Este campo es obligatorio'
              : null
          : null,
    );
  }
}
