import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/custom_button.dart';
import '../widgets/auth_text_field.dart';
import '../../../navigation/app_router.dart';
import '../../../core/api/carelink_api.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  String? _message;
  bool _isLoading = false;

  // JWT token stored in memory for now:
  String? _token;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
      _message = null;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    final response = await CareLinkApi.login(email, password);

    if (response["token"] != null) {
      setState(() {
        _message = "Login successful!";
        _token = response["token"];
      });
      // Directly navigate to dashboard after 500ms for feedback
      await Future.delayed(const Duration(milliseconds: 500));
      Navigator.of(
        context,
      ).pushReplacementNamed(AppRouter.dashboard, arguments: {"token": _token});
    } else {
      setState(() {
        _message = response["error"] ?? "Login failed";
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppConstants.paddingXLarge),
                  Icon(
                    Icons.watch_rounded,
                    size: 80,
                    color: AppColors.primaryBlue,
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),
                  Text(
                    'CareLink Wristband',
                    style: AppTextStyles.heading1,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),
                  Text(
                    'Monitor. Care. Connect.',
                    style: AppTextStyles.subtitle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppConstants.paddingXLarge * 1.5),
                  Text('Welcome Back', style: AppTextStyles.heading2),
                  const SizedBox(height: AppConstants.paddingSmall),
                  Text(
                    'Sign in to continue monitoring',
                    style: AppTextStyles.subtitle,
                  ),
                  const SizedBox(height: AppConstants.paddingLarge),

                  AuthTextField(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController,
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Please enter your email';
                      if (!value.contains('@'))
                        return 'Please enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),

                  AuthTextField(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    controller: _passwordController,
                    validator: (value) {
                      if (value == null || value.isEmpty)
                        return 'Please enter your password';
                      if (value.length < 6)
                        return 'Password must be at least 6 characters';
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.paddingSmall),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(
                          context,
                        ).pushNamed(AppRouter.forgotPassword);
                      },
                      child: Text(
                        'Forgot Password?',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),

                  CustomButton(
                    text: _isLoading ? 'Signing In...' : 'Sign In',
                    onPressed: _isLoading ? null : _handleSignIn,
                  ),
                  const SizedBox(height: AppConstants.paddingLarge),

                  if (_message != null)
                    Text(
                      _message!,
                      style: TextStyle(
                        color: _message == "Login successful!"
                            ? Colors.green
                            : Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: AppTextStyles.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pushNamed(AppRouter.signup);
                        },
                        child: Text(
                          'Sign Up',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
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
