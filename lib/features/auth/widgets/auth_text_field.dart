import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';

/// A custom text field widget designed specifically for authentication screens.
/// Includes optional icon, obscure text for passwords, and validation.
class AuthTextField extends StatefulWidget {
  // The hint text to display when the field is empty
  final String hintText;

  // The label text to display above the field
  final String labelText;

  // Optional icon to display at the start of the field
  final IconData? prefixIcon;

  // Whether this is a password field (shows/hides text)
  final bool isPassword;

  // The keyboard type (e.g., email, text, number)
  final TextInputType keyboardType;

  // Controller to manage the text input
  final TextEditingController controller;

  // Optional validation function
  final String? Function(String?)? validator;

  const AuthTextField({
    super.key,
    required this.hintText,
    required this.labelText,
    required this.controller,
    this.prefixIcon,
    this.isPassword = false,
    this.keyboardType = TextInputType.text,
    this.validator,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  // Track whether password is visible or hidden
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.labelText,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword && _obscureText,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          decoration: InputDecoration(
            hintText: widget.hintText,
            prefixIcon: widget.prefixIcon != null
                ? Icon(widget.prefixIcon, color: AppColors.primaryBlue)
                : null,
            // Add eye icon for password fields to toggle visibility
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textSecondary,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null,
          ),
        ),
      ],
    );
  }
}
