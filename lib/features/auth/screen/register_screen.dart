import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_tech/core/constants/app_strings.dart';
import 'package:tutor_tech/core/widgets/custom_button.dart';
import 'package:tutor_tech/core/widgets/loading_overlay.dart';
import 'package:tutor_tech/features/auth/authProvider/auth_provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/utils/validators.dart';
import '../../../core/widgets/custom_textfield.dart';
import '../modal/user_model.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  int _currentStep = 0;
  UserRole? _selectedRole;
  String? _stepError;

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _fullNameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _parentEmailError;

  void validateStep0() {
    setState(() {
      _currentStep = 1;
    });
  }

  void validateStep1() {
    setState(() {
      _fullNameError =
          Validators.validateRequired(_fullNameController.text, 'Full Name');
      _emailError = Validators.validateEmail(_emailController.text);
      _passwordError = Validators.validatePassword(_passwordController.text);
      _confirmPasswordError =
      _passwordController.text != _confirmPasswordController.text
          ? 'Passwords do not match'
          : null;

    });

    setState(() {
      _currentStep = 2;
      _stepError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    return LoadingOverlay(
      isLoading: authState.isLoading,
      message: 'Creating account',
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.paddingL),
          child: Column(
            crossAxisAlignment: .start,
            children: [
              if (_stepError != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline,
                          color: AppColors.error, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _stepError!,
                          style: AppTextStyles.bodySmall
                              .copyWith(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (_currentStep == 0) ...[
                Text('Select Your Role', style: AppTextStyles.h2),
                const SizedBox(height: 8),
                Text(
                  'Choose how you will use Tech Tutors.',
                  style: AppTextStyles.bodyMedium,
                ),
                const SizedBox(height: 24),
                ...UserRole.values.map((e) {
                  return _buildRoleCard(
                    e,
                    Icons.person,
                    e.displayName,
                    e.subtitle,
                  );
                }),
                const SizedBox(height: 32),
                CustomButton(
                  label: AppStrings.nextButton,
                  onPressed: _selectedRole != null ? validateStep0 : null,
                ),
              ],
              if (_currentStep == 1) ...[
                Text('Personal Information', style: AppTextStyles.h2),
                const SizedBox(height: 16),
                CustomTextField(
                  label: AppStrings.fullNameLabel,
                  hint: 'Enter your full name',
                  controller: _fullNameController,
                  errorText: _fullNameError,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: AppStrings.emailLabel,
                  hint: AppStrings.emailHint,
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  errorText: _emailError,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: AppStrings.passwordLabel,
                  hint: AppStrings.passwordHint,
                  controller: _passwordController,
                  obscureText: true,
                  showToggle: true,
                  errorText: _passwordError,
                ),
                const SizedBox(height: 16),
                CustomTextField(
                  label: 'Confirm Password',
                  hint: 'Re-enter your password',
                  controller: _confirmPasswordController,
                  obscureText: true,
                  showToggle: true,
                  errorText: _confirmPasswordError,
                ),
                const SizedBox(height: 16),
                CustomButton(
                  label: AppStrings.nextButton,
                  onPressed: validateStep1,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard(
    UserRole role,
    IconData icon,
    String title,
    String subtitle,
  ) {
    final isSel = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: .symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSel
              ? role.color.withValues(alpha: 0.1)
              : AppColors.surfaceCard,
          border: Border.all(
            color: isSel ? role.color : AppColors.border,
            width: isSel ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusL),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: role.color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: role.color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.h3),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTextStyles.bodySmall),
                ],
              ),
            ),
            if (isSel) Icon(Icons.check_circle, color: role.color),
          ],
        ),
      ),
    );
  }
}
