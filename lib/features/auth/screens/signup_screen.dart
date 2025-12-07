import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/custom_button.dart';
import '../widgets/auth_text_field.dart';
import '../../../navigation/app_router.dart';
import '../../../core/services/api_service.dart';

/// The sign-up screen where new users create an account.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Account Info Controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Monitored Person Controllers
  final _monitoredNameController = TextEditingController();
  final _dobController = TextEditingController();

  // Emergency Contact Controllers
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();

  // State variables
  bool _acceptedTerms = false;
  
  // API service for backend communication
  final _apiService = ApiService();
  
  // Loading state
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _monitoredNameController.dispose();
    _dobController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  /// Opens date picker for DOB selection
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 10)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primaryBlue,
              onPrimary: Colors.white,
              surface: AppColors.cardBackground,
              onSurface: AppColors.textPrimary,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _dobController.text = '${picked.month}/${picked.day}/${picked.year}';
      });
    }
  }

  /// Handles the account creation process
  /// Creates an account with the Flask backend
  Future<void> _handleSignUp() async {
    if (_formKey.currentState?. validate() ?? false) {
      if (!_acceptedTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please accept the terms and conditions'),
            backgroundColor: AppColors.dangerRed,
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        // Call signup API
        await _apiService.signup(
          _emailController.text.trim(),
          _passwordController.text,
          _nameController.text.trim(),
        );

        // Navigate to connection test screen on success
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(AppRouter.connectionTest);
        }
      } catch (e) {
        // Show error message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString().replaceAll('Exception: ', '')),
              backgroundColor: AppColors.dangerRed,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
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
                  // Header
                  Text('Create Account', style: AppTextStyles.heading1),
                  const SizedBox(height: AppConstants.paddingSmall),
                  Text(
                    'Sign up to start monitoring',
                    style: AppTextStyles.subtitle,
                  ),
                  const SizedBox(height: AppConstants.paddingLarge),

                  // ========== ACCOUNT INFO SECTION ==========
                  _buildSectionHeader('Account Information'),
                  const SizedBox(height: AppConstants.paddingMedium),

                  // Full Name
                  AuthTextField(
                    labelText: 'Full Name',
                    hintText: 'Enter your full name',
                    prefixIcon: Icons.person_outline,
                    controller: _nameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),

                  // Email
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
                  const SizedBox(height: AppConstants.paddingMedium),

                  // Phone Number
                  AuthTextField(
                    labelText: 'Phone Number',
                    hintText: 'Enter your phone number',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    controller: _phoneController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),

                  // Password
                  AuthTextField(
                    labelText: 'Password',
                    hintText: 'Create a password',
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    controller: _passwordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),

                  // Confirm Password
                  AuthTextField(
                    labelText: 'Confirm Password',
                    hintText: 'Re-enter your password',
                    prefixIcon: Icons.lock_outline,
                    isPassword: true,
                    controller: _confirmPasswordController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.paddingLarge),

                  // ========== MONITORED PERSON SECTION ==========
                  _buildSectionHeader('Monitored Person Details'),
                  const SizedBox(height: AppConstants.paddingMedium),

                  // Monitored Person Name
                  AuthTextField(
                    labelText: "Monitored Person's Full Name",
                    hintText: 'Enter their full name',
                    prefixIcon: Icons.face_outlined,
                    controller: _monitoredNameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter the monitored person\'s name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),

                  // Date of Birth
                  _buildDateField(),
                  const SizedBox(height: AppConstants.paddingMedium),

                  // Relationship Dropdown
                  _buildRelationshipDropdown(),
                  const SizedBox(height: AppConstants.paddingLarge),

                  // ========== EMERGENCY CONTACT SECTION ==========
                  _buildSectionHeader('Emergency Contact'),
                  const SizedBox(height: AppConstants.paddingMedium),

                  // Emergency Contact Name
                  AuthTextField(
                    labelText: 'Emergency Contact Name',
                    hintText: 'Enter emergency contact name',
                    prefixIcon: Icons.contact_emergency_outlined,
                    controller: _emergencyNameController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter emergency contact name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.paddingMedium),

                  // Emergency Contact Phone
                  AuthTextField(
                    labelText: 'Emergency Contact Phone',
                    hintText: 'Enter emergency contact phone',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    controller: _emergencyPhoneController,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter emergency contact phone';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppConstants.paddingLarge),

                  // ========== TERMS & CONDITIONS ==========
                  Row(
                    children: [
                      Checkbox(
                        value: _acceptedTerms,
                        onChanged: (value) {
                          setState(() {
                            _acceptedTerms = value ?? false;
                          });
                        },
                        activeColor: AppColors.primaryBlue,
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _acceptedTerms = !_acceptedTerms;
                            });
                          },
                          child: RichText(
                            text: TextSpan(
                              style: AppTextStyles.bodySmall,
                              children: [
                                const TextSpan(text: 'I agree to the '),
                                TextSpan(
                                  text: 'Terms & Conditions',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.primaryBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.primaryBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.paddingLarge),

                  // Create Account Button
                  CustomButton(
                    text: _isLoading ? 'Creating Account...' : 'Create Account',
                    onPressed: _isLoading ? () {} : _handleSignUp,
                  ),
                  const SizedBox(height: AppConstants.paddingLarge),

                  // Sign In Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account?  ',
                        style: AppTextStyles.bodyMedium,
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          'Sign In',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: AppColors.primaryBlue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.paddingLarge),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a section header
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: AppTextStyles.heading3.copyWith(color: AppColors.primaryBlue),
    );
  }

  /// Builds the date of birth field
  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date of Birth',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        TextFormField(
          controller: _dobController,
          readOnly: true,
          onTap: _selectDate,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please select date of birth';
            }
            return null;
          },
          decoration: InputDecoration(
            hintText: 'Select date of birth',
            prefixIcon: const Icon(
              Icons.calendar_today_outlined,
              color: AppColors.primaryBlue,
            ),
            suffixIcon: const Icon(
              Icons.arrow_drop_down,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the relationship dropdown
  Widget _buildRelationshipDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Relationship to Wearer',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        DropdownButtonFormField<String>(
          value: _selectedRelationship,
          decoration: InputDecoration(
            prefixIcon: const Icon(
              Icons.family_restroom_outlined,
              color: AppColors.primaryBlue,
            ),
          ),
          items: _relationshipOptions.map((String relationship) {
            return DropdownMenuItem<String>(
              value: relationship,
              child: Text(relationship),
            );
          }).toList(),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedRelationship = newValue;
              });
            }
          },
        ),
      ],
    );
  }
}
