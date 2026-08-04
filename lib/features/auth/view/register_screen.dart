import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_tech/core/constants/app_dimensions.dart';
import 'package:tutor_tech/core/utils/validators.dart';
import 'package:tutor_tech/core/widgets/custom_appbar.dart';
import 'package:tutor_tech/core/widgets/custom_button.dart';
import 'package:tutor_tech/features/auth/modal/usermodal.dart';
import 'package:tutor_tech/features/auth/provider/auth_provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/custom_textfield.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../../student/model/student_model.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  int _currentStep = 0;
  UserRole? _selectedRole;

  int get _totalSteps => 4;

  String? _fullNameError;
  String? _emailError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _parentEmailError;
  String? _stepError;
  final _nameController = TextEditingController();
  final _emailContoller = TextEditingController();
  final _passwordController = TextEditingController();
  final _parentEmailController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // Student
  SubjectStage _selectedStage = SubjectStage.gcse;
  DateTime? _selectedDOB;
  bool _isUnder13 = false;

  void validate0() {
    if (_selectedRole == null) {
      setState(() {
        _stepError = 'Please Select the role';
      });
    }
    setState(() {
      _stepError = null;
      _currentStep = 1;
    });
  }

  void validate1() {
    setState(() {
      _fullNameError = Validators.validateRequired(
        _nameController.text,
        'FullName',
      );
      _emailError = Validators.validateEmail(_emailContoller.text);
      _passwordError = Validators.validatePassword(_passwordController.text);
      _confirmPasswordError = _passwordController != _confirmPasswordController
          ? "Please enter the same password as before"
          : null;
    });
    bool isValid =
        _fullNameError == null &&
        _emailError == null &&
        _passwordError == null &&
        _confirmPasswordError == null;
    if (_selectedRole == UserRole.student && _selectedDOB == null) {
      setState(() => _stepError = 'Please select your date of birth');
      isValid = false;
    }
    if (isValid) {
      setState(() {
        _stepError = null;
        _currentStep = 2;
      });
    }
  }

  void _onDOBSelected(DateTime dob) {
    setState(() {
      _selectedDOB = dob;
      _isUnder13 = Validators.checkIsUnder13(dob);
    });
  }

  @override
  Widget build(BuildContext context) {
    final int uiStep = _currentStep;
    final authState = ref.watch(authViewModalProvider);
    return LoadingOverlay(
      isLoading: authState.isLoading,
      message: 'Creating account',
      child: Scaffold(
        appBar: CustomAppbar(title: " Tutor tech", showBackButton: true),
        body: SingleChildScrollView(
          padding: .all(AppDimensions.paddingL),
          child: Column(
            children: [
              Row(
                children: List.generate(_totalSteps, (index) {
                  final isActive = index <= uiStep;
                  return Expanded(
                    child: Container(
                      height: 6,
                      margin: EdgeInsets.only(
                        right: index < (_totalSteps - 1) ? 8 : 0,
                      ),
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.primary : AppColors.border,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 8),
              Text(
                'Step ${uiStep + 1} of $_totalSteps',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              if (_stepError != null) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.errorLight,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _stepError!,
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.error,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                if (_currentStep == 0) ...[
                  Text('Select Your Role', style: AppTextStyles.h2),
                  const SizedBox(height: 8),
                  Text(
                    'Choose how you will use Takween Tutors.',
                    style: AppTextStyles.bodyMedium,
                  ),
                  const SizedBox(height: 24),

                  _buildRoleCard(
                    UserRole.student,
                    Icons.school,
                    'Student',
                    'I want to find tutors and attend sessions.',
                  ),
                  const SizedBox(height: 12),
                  _buildRoleCard(
                    UserRole.parent,
                    Icons.family_restroom,
                    'Parent',
                    'I want to manage and pay for my child\'s tutoring.',
                  ),
                  const SizedBox(height: 12),
                  _buildRoleCard(
                    UserRole.tutor,
                    Icons.person,
                    'Tutor',
                    'I want to teach students and manage my schedule.',
                  ),
                  // ⚠️ Admin role intentionally excluded — admins are created manually via Firebase Console.
                  const SizedBox(height: 32),
                  CustomButton(label: 'Submit', onPressed: validate0),
                ],
                if (_currentStep == 1) ...[
                  Text('Personal Information', style: AppTextStyles.h2),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: AppStrings.fullNameLabel,
                    hint: 'Enter your full name',
                    controller: _nameController,
                    errorText: _fullNameError,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: AppStrings.emailLabel,
                    hint: AppStrings.emailHint,
                    controller: _emailContoller,
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
                  if (_selectedRole == UserRole.student) ...[
                    Text('Date of Birth', style: AppTextStyles.labelLarge),
                    const SizedBox(height: 6),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now().subtract(
                            const Duration(days: 3650),
                          ),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          _onDOBSelected(picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceCard,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusM,
                          ),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              color: AppColors.primary,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _selectedDOB != null
                                  ? DateFormat(
                                      'dd MMMM yyyy',
                                    ).format(_selectedDOB!)
                                  : 'Select Date of Birth',
                              style: AppTextStyles.bodyLarge,
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_isUnder13) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.warningLight,
                          borderRadius: BorderRadius.circular(
                            AppDimensions.radiusM,
                          ),
                          border: Border.all(color: AppColors.warning),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: AppColors.warning,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                AppStrings.under13Banner,
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      CustomTextField(
                        label: AppStrings.parentEmailLabel,
                        hint: AppStrings.parentEmailHint,
                        controller: _parentEmailController,
                        keyboardType: TextInputType.emailAddress,
                        errorText: _parentEmailError,
                      ),
                    ],
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: CustomButton(
                          label: 'Back',
                          variant: ButtonVariant.outline,
                          onPressed: () => setState(() => _currentStep = 1),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomButton(
                          label: AppStrings.nextButton,
                          onPressed: validate1,
                        ),
                      ),
                    ],
                  ),
                ],
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

  Widget _studentSpecificTask() {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text('What are you studying?', style: AppTextStyles.h2),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: SubjectStage.values.map((e) {
              final isSelect = _selectedStage == e;
              return ChoiceChip(
                label: Text(e.displayName),
                selected: isSelect,
                onSelected: (val) {
                  if (val) {
                    setState(() {
                      _selectedStage = e;
                    });
                  }
                },
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),
        Text('Select Subjects (Max 3)', style: AppTextStyles.labelLarge),
        const SizedBox(height: 8),

      ],
    );
  }
}
