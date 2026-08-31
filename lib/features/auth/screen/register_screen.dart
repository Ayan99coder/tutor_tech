import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:tutor_tech/core/constants/app_strings.dart';
import 'package:tutor_tech/core/widgets/custom_button.dart';
import 'package:tutor_tech/core/widgets/loading_overlay.dart';
import 'package:tutor_tech/features/auth/authProvider/auth_provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/utils/validators.dart';
import '../../../core/widgets/custom_textfield.dart';
import '../../../core/widgets/subject_chip.dart';
import '../../student/model/student_model.dart';
import '../../subject/subject_model.dart';
import '../modal/user_model.dart';
import '../viewmodal/auth_state.dart';

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

  final _parentEmailController = TextEditingController();
  DateTime? _selectedDOB;
  bool _isUnder13 = false;
  SubjectStage _selectedStage = SubjectStage.gcse;
  final List<String> _selectedSubjectSlugs = [];
  GroupSize _selectedGroupSize = GroupSize.oneToOne;
  CommunicationPref _commPref = CommunicationPref.both;

  // Parent Specific
  final List<TextEditingController> _childEmailControllers = [
    TextEditingController(),
  ];

  // Tutor Specific
  final _educationController = TextEditingController();
  final _experienceController = TextEditingController();
  final List<String> _tutorSubjectSlugs = [];
  final List<String> _tutorTeachingLevels = [];
  String? _resumeFileName;
  String? _resumeUrl;

  bool _recordingConsent = false;
  bool _legalConsent = false;

  Future<void> _pickResumeFile() async {
    try {
      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _resumeFileName = result.files.single.name;
          _resumeUrl = result.files.single.path;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Could not pick file: $e')));
      }
    }
  }

  void validateStep0() {
    setState(() {
      _currentStep = 1;
    });
  }

  void _onDOBSelected(DateTime dob) {
    setState(() {
      _selectedDOB = dob;
      _isUnder13 = Validators.checkIsUnder13(dob);
    });
  }

  void _validateStep1() {
    setState(() {
      _fullNameError = Validators.validateRequired(
        _fullNameController.text,
        'Full Name',
      );
      _emailError = Validators.validateEmail(_emailController.text);
      _passwordError = Validators.validatePassword(_passwordController.text);
      _confirmPasswordError =
          _passwordController.text != _confirmPasswordController.text
          ? 'Passwords do not match'
          : null;

      if (_selectedRole == UserRole.student && _isUnder13) {
        _parentEmailError = Validators.validateEmail(
          _parentEmailController.text,
        );
      } else {
        _parentEmailError = null;
      }
    });

    bool isValid =
        _fullNameError == null &&
        _emailError == null &&
        _passwordError == null &&
        _confirmPasswordError == null &&
        _parentEmailError == null;

    if (_selectedRole == UserRole.student && _selectedDOB == null) {
      setState(() => _stepError = 'Please select your date of birth');
      isValid = false;
    }

    if (isValid) {
      setState(() {
        _currentStep = 2; // Go to specific info
        _stepError = null;
      });
    }
  }

  void _submitRegisterForm() {
    if (!_legalConsent) {
      setState(
        () => _stepError =
            'You must agree to the Terms of Service & Privacy Policy.',
      );
      return;
    }

    if (_selectedRole == UserRole.student && !_recordingConsent) {
      setState(
        () => _stepError =
            'You must give recording consent to create a student account.',
      );
      return;
    }

    final authData = ref.read(authNotifierProvider.notifier);

    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    switch (_selectedRole!) {
      case UserRole.student:
        AgeGroup ageGroup = AgeGroup.gcse;

        switch (_selectedStage) {
          case SubjectStage.primary:
            ageGroup = AgeGroup.primary;
            break;

          case SubjectStage.elevenPlus:
            ageGroup = AgeGroup.elevenPlus;
            break;

          case SubjectStage.gcse:
            ageGroup = AgeGroup.gcse;
            break;

          case SubjectStage.aLevel:
            ageGroup = AgeGroup.aLevel;
            break;

          case SubjectStage.btec:
            ageGroup = AgeGroup.btec;
            break;
        }

        authData.registerStudentWithEmailAndPassword(
          fullName: fullName,
          email: email,
          password: password,
          ageGroup: ageGroup,
          subjects: _selectedSubjectSlugs,
          preferredGroupSize: _selectedGroupSize,
          communicationPref: _commPref,
          isUnder13: _isUnder13,
          parentEmail: _isUnder13 ? _parentEmailController.text.trim() : null,
        );

        break;

      case UserRole.tutor:
        authData.registerTutorWithEmailAndPassword(
          fullName: fullName,
          email: email,
          password: password,
          education: _educationController.text.trim(),
          teachingExperience: _experienceController.text.trim(),
          subjects: _tutorSubjectSlugs,
          teachingLevels: _tutorTeachingLevels,
          cvLink: _resumeUrl,
        );

        break;

      case UserRole.parent:
        authData.registerParentWithEmailAndPassword(
          fullName: fullName,
          email: email,
          password: password,
          childrenEmails: _childEmailControllers
              .map((controller) => controller.text.trim())
              .where((email) => email.isNotEmpty)
              .toList(),
        );

        break;
    }
  }

  void _validateStep2() {
    if (_selectedRole == UserRole.student) {
      if (_selectedSubjectSlugs.isEmpty) {
        setState(() => _stepError = 'Please select at least 1 subject');
        return;
      }
    } else if (_selectedRole == UserRole.tutor) {
      if (_educationController.text.isEmpty ||
          _experienceController.text.isEmpty) {
        setState(
          () => _stepError = 'Please provide your education and experience',
        );
        return;
      }
      if (_tutorSubjectSlugs.isEmpty || _tutorTeachingLevels.isEmpty) {
        setState(
          () => _stepError =
              'Please select at least 1 subject and 1 teaching level',
        );
        return;
      }
    } else if (_selectedRole == UserRole.parent) {
      // No strict validation for child emails, they can be empty
    }

    setState(() {
      _currentStep = 3;
      _stepError = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authNotifierProvider, (prev, next) {
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              backgroundColor: AppColors.error,
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      next.errorMessage!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
      }
    });
    ref.listen<AuthState>(authNotifierProvider, (prev,next) {
      if (!prev!.isRegSuccess&&next.isRegSuccess) {
        context.go('/login');
      }
    });
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
                        onPressed: () => setState(() => _currentStep = 0),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        label: AppStrings.nextButton,
                        onPressed: _validateStep1,
                      ),
                    ),
                  ],
                ),
              ],
              if (_currentStep == 2) ...[
                if (_selectedRole == UserRole.student)
                  _buildStudentSpecificStep(),
                if (_selectedRole == UserRole.parent)
                  _buildParentSpecificStep(),
                if (_selectedRole == UserRole.tutor) _buildTutorSpecificStep(),
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
                        onPressed: _validateStep2,
                      ),
                    ),
                  ],
                ),
              ],
              if (_currentStep == 3) ...[
                Text('Confirm & Create Account', style: AppTextStyles.h2),
                const SizedBox(height: 16),

                // Summary Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(AppDimensions.radiusL),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Account Summary', style: AppTextStyles.h4),
                      const Divider(),
                      Text(
                        'Role: ${_selectedRole?.displayName}',
                        style: AppTextStyles.bodyMedium,
                      ),
                      Text(
                        'Name: ${_fullNameController.text}',
                        style: AppTextStyles.bodyMedium,
                      ),
                      Text(
                        'Email: ${_emailController.text}',
                        style: AppTextStyles.bodyMedium,
                      ),
                      if (_selectedRole == UserRole.student) ...[
                        Text(
                          'Stage: ${_selectedStage.displayName}',
                          style: AppTextStyles.bodyMedium,
                        ),
                        Text(
                          'Subjects: ${_selectedSubjectSlugs.join(", ")}',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                      if (_selectedRole == UserRole.parent) ...[
                        Text(
                          'Children Linked: ${_childEmailControllers.where((e) => e.text.isNotEmpty).length}',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                      if (_selectedRole == UserRole.tutor) ...[
                        Text(
                          'Subjects: ${_tutorSubjectSlugs.join(", ")}',
                          style: AppTextStyles.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _legalConsent,
                      onChanged: (val) =>
                          setState(() => _legalConsent = val ?? false),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: GestureDetector(
                          onTap: () {},
                          child: Text(
                            'I agree to the Terms of Service and Privacy Policy.',
                            style: AppTextStyles.bodySmall.copyWith(
                              decoration: TextDecoration.underline,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (_selectedRole == UserRole.student) ...[
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _recordingConsent,
                        onChanged: (val) =>
                            setState(() => _recordingConsent = val ?? false),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            AppStrings.recordingConsent,
                            style: AppTextStyles.bodySmall,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        label: 'Back',
                        variant: ButtonVariant.outline,
                        onPressed: () {
                          setState(() {
                            if (_selectedRole == UserRole.parent) {
                              _currentStep = 1;
                            } else {
                              _currentStep = 2;
                            }
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        label: AppStrings.createAccount,
                        onPressed: _submitRegisterForm,
                      ),
                    ),
                  ],
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

  Widget _buildStudentSpecificStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('What are you studying?', style: AppTextStyles.h2),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: SubjectStage.values.map((stage) {
              final isSel = _selectedStage == stage;
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ChoiceChip(
                  label: Text(stage.displayName),
                  selected: isSel,
                  selectedColor: stage.color.withValues(alpha: 0.2),
                  onSelected: (val) {
                    if (val) setState(() => _selectedStage = stage);
                  },
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 20),
        Text('Select Subjects (Max 3)', style: AppTextStyles.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: seededSubjects.where((s) => s.stage == _selectedStage).map((
            subject,
          ) {
            final isSel = _selectedSubjectSlugs.contains(subject.slug);
            return SubjectChip(
              emoji: subject.emoji,
              displayName: subject.displayName,
              stageColor: subject.stage.color,
              isSelected: isSel,
              onTap: () {
                setState(() {
                  if (isSel) {
                    _selectedSubjectSlugs.remove(subject.slug);
                  } else if (_selectedSubjectSlugs.length < 3) {
                    _selectedSubjectSlugs.add(subject.slug);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        Text('Preferred Group Size', style: AppTextStyles.labelLarge),
        const SizedBox(height: 8),
        Row(
          children: GroupSize.values.map((gs) {
            final isSel = _selectedGroupSize == gs;
            String title = gs == GroupSize.oneToOne
                ? '1-to-1'
                : gs == GroupSize.oneToFive
                ? '1-to-5'
                : '1-to-10';
            return Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _selectedGroupSize = gs),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSel
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : AppColors.surfaceCard,
                    border: Border.all(
                      color: isSel ? AppColors.primary : AppColors.border,
                      width: isSel ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  ),
                  child: Center(child: Text(title, style: AppTextStyles.h4)),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        Text('Communication Preference', style: AppTextStyles.labelLarge),
        Row(
          children: CommunicationPref.values.map((e) {
            final isSel = _commPref == e;
            String title = e == CommunicationPref.both
                ? 'both'
                : CommunicationPref.parentOnly == e
                ? 'Parent only'
                : 'student only';
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _commPref = e;
                  });
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSel
                        ? AppColors.primary.withValues(alpha: 0.1)
                        : AppColors.surfaceCard,
                    border: Border.all(
                      color: isSel ? AppColors.primary : AppColors.border,
                      width: isSel ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  ),
                  child: Center(child: Text(title, style: AppTextStyles.h4)),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildParentSpecificStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Link Your Children', style: AppTextStyles.h2),
        const SizedBox(height: 8),
        Text(
          'Enter the email addresses your children used to register. They will be linked to your dashboard automatically.',
          style: AppTextStyles.bodyMedium,
        ),
        const SizedBox(height: 24),
        ...List.generate(_childEmailControllers.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: CustomTextField(
              label: 'Child ${index + 1} Email',
              hint: 'e.g. child@example.com',
              controller: _childEmailControllers[index],
              keyboardType: TextInputType.emailAddress,
            ),
          );
        }),
        if (_childEmailControllers.length < 3)
          TextButton.icon(
            icon: const Icon(Icons.add),
            label: const Text('Add Another Child'),
            onPressed: () {
              setState(() {
                _childEmailControllers.add(TextEditingController());
              });
            },
          ),
      ],
    );
  }

  Widget _buildTutorSpecificStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Tutor Profile', style: AppTextStyles.h2),
        const SizedBox(height: 8),
        Text(
          'Provide your qualifications to help us approve your application.',
          style: AppTextStyles.bodyMedium,
        ),
        const SizedBox(height: 24),
        CustomTextField(
          label: 'Highest Education / Degree',
          hint: 'e.g. BSc Mathematics, UCL',
          controller: _educationController,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          label: 'Teaching Experience',
          hint: 'Briefly describe your tutoring experience',
          controller: _experienceController,
          maxLines: 3,
        ),
        const SizedBox(height: 24),
        Text('Teaching Levels', style: AppTextStyles.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: ['Primary', '11+', 'GCSE', 'A-Level'].map((level) {
            final isSel = _tutorTeachingLevels.contains(level);
            return FilterChip(
              label: Text(level),
              selected: isSel,
              onSelected: (val) {
                setState(() {
                  if (val) {
                    _tutorTeachingLevels.add(level);
                  } else {
                    _tutorTeachingLevels.remove(level);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        Text('Subjects You Teach', style: AppTextStyles.labelLarge),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: ['Maths', 'Physics', 'Biology', 'Chemistry', 'English'].map(
            (sub) {
              final isSel = _tutorSubjectSlugs.contains(sub);
              return FilterChip(
                label: Text(sub),
                selected: isSel,
                onSelected: (val) {
                  setState(() {
                    if (val)
                      _tutorSubjectSlugs.add(sub);
                    else
                      _tutorSubjectSlugs.remove(sub);
                  });
                },
              );
            },
          ).toList(),
        ),
        const SizedBox(height: 24),
        Text('Upload Resume / CV (PDF)', style: AppTextStyles.labelLarge),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceCard,
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
            border: Border.all(
              color: _resumeFileName != null
                  ? AppColors.success
                  : AppColors.border,
            ),
          ),
          child: Row(
            children: [
              Icon(
                _resumeFileName != null
                    ? Icons.description_rounded
                    : Icons.cloud_upload_outlined,
                color: _resumeFileName != null
                    ? AppColors.success
                    : AppColors.primary,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _resumeFileName ?? 'Select PDF or DOC file',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: _resumeFileName != null
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: _resumeFileName != null
                            ? AppColors.success
                            : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      _resumeFileName != null
                          ? 'CV Attached'
                          : 'Attach your resume for admin review',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                icon: const Icon(Icons.folder_open, size: 16),
                label: Text(_resumeFileName != null ? 'Change' : 'Browse'),
                onPressed: _pickResumeFile,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
