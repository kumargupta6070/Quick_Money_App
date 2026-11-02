import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/utils/validators.dart';

class PhoneInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const PhoneInputField({
    super.key,
    required this.controller,
    this.label = 'Mobile Number',
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.phone,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(LucideIcons.phone),
        prefixText: '+91 ',
      ),
      validator: Validators.validatePhone,
    );
  }
}

