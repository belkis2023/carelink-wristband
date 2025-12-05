import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/widgets/custom_app_bar.dart';
import '../../../shared/widgets/custom_button.dart';

/// The edit profile screen for modifying user and monitored individual information.
/// Allows users to update profile details, emergency contacts, and relationship info.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Text controllers for form fields
  final _nameController = TextEditingController(text: 'Alex Johnson');
  final _ageController = TextEditingController(text: '14');
  final _dobController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();

  // Selected relationship value
  String _selectedRelationship = 'Parent';

  // Date of birth
  DateTime? _selectedDate;

  @override
  void dispose() {
    // Clean up controllers
    _nameController.dispose();
    _ageController.dispose();
    _dobController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Edit Profile',
        showConnectionStatus: false,
        showBackButton: true,
      ),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppConstants.paddingMedium),

                // Profile Avatar Section
                Center(
                  child: Stack(
                    children: [
                      // Avatar
                      Container(
                        width: AppConstants.avatarXLarge,
                        height: AppConstants.avatarXLarge,
                        decoration: BoxDecoration(
                          color: AppColors.lightBlueBackground,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.person,
                          size: AppConstants.iconXLarge,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      // Edit icon overlay
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(AppConstants.paddingSmall),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.cardBackground,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.paddingLarge),

                // Form Fields Container
                Container(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      // Full Name Field
                      _buildTextField(
                        label: 'Full Name',
                        controller: _nameController,
                        icon: Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),

                      // Age Field
                      _buildTextField(
                        label: 'Age',
                        controller: _ageController,
                        icon: Icons.cake_outlined,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter an age';
                          }
                          final age = int.tryParse(value);
                          if (age == null || age <= 0) {
                            return 'Please enter a valid age';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),

                      // Date of Birth Field
                      _buildDateField(
                        label: 'Date of Birth',
                        controller: _dobController,
                        icon: Icons.calendar_today_outlined,
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),

                      // Relationship to Wearer Dropdown
                      _buildDropdownField(
                        label: 'Relationship to Wearer',
                        value: _selectedRelationship,
                        icon: Icons.family_restroom_outlined,
                        items: ['Parent', 'Guardian', 'Caregiver', 'Other'],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedRelationship = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),

                      // Emergency Contact Name
                      _buildTextField(
                        label: 'Emergency Contact Name',
                        controller: _emergencyNameController,
                        icon: Icons.contact_emergency_outlined,
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),

                      // Emergency Contact Phone
                      _buildTextField(
                        label: 'Emergency Contact Phone',
                        controller: _emergencyPhoneController,
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppConstants.paddingLarge),

                // Save Changes Button
                CustomButton(
                  text: 'Save Changes',
                  onPressed: _saveChanges,
                  type: ButtonType.primary,
                ),
                const SizedBox(height: AppConstants.paddingLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a standard text field
  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primaryBlue),
            hintText: 'Enter $label',
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              borderSide: const BorderSide(color: AppColors.dangerRed),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
              vertical: AppConstants.paddingMedium,
            ),
          ),
        ),
      ],
    );
  }

  /// Builds a date picker field
  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        TextFormField(
          controller: controller,
          readOnly: true,
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _selectedDate ?? DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              setState(() {
                _selectedDate = date;
                controller.text = '${date.month}/${date.day}/${date.year}';
              });
            }
          },
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primaryBlue),
            hintText: 'Select Date',
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
              vertical: AppConstants.paddingMedium,
            ),
          ),
        ),
      ],
    );
  }

  /// Builds a dropdown field
  Widget _buildDropdownField({
    required String label,
    required String value,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: onChanged,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.primaryBlue),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppConstants.paddingMedium,
              vertical: AppConstants.paddingMedium,
            ),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Handles saving the profile changes
  void _saveChanges() {
    if (_formKey.currentState!.validate()) {
      // In a real app, this would save to a database or API
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: AppColors.successGreen,
        ),
      );
      Navigator.of(context).pop();
    }
  }
}
