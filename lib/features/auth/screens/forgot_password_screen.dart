import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/custom_button.dart';
import '../widgets/auth_text_field.dart';
import '../services/auth_service.dart';

/// The forgot password screen where users can request a password reset link.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // Controller to manage email input
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  // Auth service to handle password reset
  final _authService = AuthService();
  
  // Track loading state during password reset
  bool _isLoading = false;

  @override
  void dispose() {
    // Clean up controller when the widget is disposed
    _emailController.dispose();
    super.dispose();
  }

  /// Handles the password reset request with Supabase
  Future<void> _handleResetPassword() async {
    // Validate form field
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Show loading indicator
    setState(() {
      _isLoading = true;
    });

    try {
      // Attempt to send password reset email
      final error = await _authService.resetPassword(
        email: _emailController.text.trim(),
      );

      // If still mounted after async operation
      if (!mounted) return;

      if (error == null) {
        // Password reset email sent successfully
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Check your email for reset link'),
            backgroundColor: AppColors.successGreen,
          ),
        );

        // Navigate back to login after a short delay
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      } else {
        // Password reset failed - show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: AppColors.dangerRed,
          ),
        );
      }
    } finally {
      // Hide loading indicator
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryBlue),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppConstants.paddingLarge),

                  // Icon
                  Icon(
                    Icons.lock_reset_rounded,
                    size: 80,
                    color: AppColors.primaryBlue,
                  ),
                  const SizedBox(height: AppConstants.paddingLarge),

                  // Header
                  Text(
                    'Forgot Password?',
                    style: AppTextStyles.heading1,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  Text(
                    "Don't worry! Enter your email address and we'll send you a link to reset your password.",
                    style: AppTextStyles.subtitle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.paddingXLarge),

                  // Email Input
                  AuthTextField(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.paddingLarge),

                  // Send Reset Link Button
                  CustomButton(
                    text: _isLoading ? 'Sending...' : 'Send Reset Link',
                    onPressed: _isLoading ? () {} : _handleResetPassword,
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),

                  // Back to Sign In Link
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        'Back to Sign In',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
