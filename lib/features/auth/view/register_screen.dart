import 'package:file_picker/file_picker.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_tech/core/constants/app_dimensions.dart';
import 'package:tutor_tech/core/utils/validators.dart';
import 'package:tutor_tech/core/widgets/custom_appbar.dart';
import 'package:tutor_tech/core/widgets/custom_button.dart';
import 'package:tutor_tech/core/widgets/subject_chip.dart';
import 'package:tutor_tech/features/auth/modal/usermodal.dart';
import 'package:tutor_tech/features/auth/provider/auth_provider.dart';
import 'package:intl/intl.dart';
import 'package:tutor_tech/features/subjects/subject_model.dart';
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
  final List<String> _selectedSubjects = [];
  GroupSize _selectedGroupSize = GroupSize.oneToOne;
  CommunicationPref _commPref = CommunicationPref.both;

  //consent
  bool _recordingConsent = false;
  bool _legalConsent = false;

  //tutor
  final _educationController = TextEditingController();
  final _experienceController = TextEditingController();
  final List<String> _tutorSubjectSlugs = [];
  final List<String> _tutorTeachingLevels = [];
  String? _resumeFileName;
  String? _resumeUrl;

  //parents
  final List<TextEditingController> _childEmailControllers = [
    TextEditingController(),
  ];

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

  void _validateStep2() {
    if (_selectedRole == UserRole.student) {
      if (_selectedSubjects.isEmpty) {
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

  void _onDOBSelected(DateTime dob) {
    setState(() {
      _selectedDOB = dob;
      _isUnder13 = Validators.checkIsUnder13(dob);
    });
  }

  void _submitRegistrationForm() {
    if (!_legalConsent) {
      setState(() {
        _stepError = 'You must agree to the Terms of Service & Privacy Policy.';
      });
      return;
    }
    if (_selectedRole == UserRole.student && !_legalConsent) {
      setState(() {
        _stepError =
            'You must give recording consent to create a student account.';
      });
      return;
    }
    final reader = ref.read(authViewModalProvider.notifier);
    final fullName = _nameController.text.trim();
    final email = _emailContoller.text.trim();
    final password = _passwordController.text;

    switch (_selectedRole!) {
      case UserRole.parent:
        reader.registerParent(
          fullName: fullName,
          email: email,
          password: password,
          childrenEmails: _childEmailControllers
              .map((e) => e.text.trim())
              .where((e) => e.isNotEmpty)
              .toList(),
        );
        break;
      case UserRole.tutor:
        reader.registerTutor(
          fullName: fullName,
          email: email,
          password: password,
          education: _educationController.text.trim(),
          teachingExperience: _experienceController.text.trim(),
          subjects: _tutorSubjectSlugs,
          teachingLevels: _tutorTeachingLevels,
          cvLink: _resumeUrl ?? 'https://example.com/tutor_cv.pdf',
        );
        break;
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
        reader.registerStudent(
          fullName: fullName,
          email: email,
          password: password,
          ageGroup: ageGroup,
          subjects: _selectedSubjects,
          preferredGroupSize: _selectedGroupSize,
          communicationPref: _commPref,
          isUnder13: _isUnder13,
          parentEmail: _isUnder13 ? _parentEmailController.text.trim() : null,
        );
        break;
      case UserRole.admin:
        // TODO: Handle this case.
        throw UnimplementedError();
    }
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
                if (_currentStep == 2) ...[
                  _selectedRole == UserRole.student
                      ? _studentSpecificTask()
                      : _selectedRole == UserRole.tutor
                      ? _buildTutorSpecificTask()
                      : _buildParentSpecificTask(),
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
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusL,
                      ),
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
                          'Name: ${_nameController.text}',
                          style: AppTextStyles.bodyMedium,
                        ),
                        Text(
                          'Email: ${_emailContoller.text}',
                          style: AppTextStyles.bodyMedium,
                        ),
                        if (_selectedRole == UserRole.student) ...[
                          Text(
                            'Stage: ${_selectedStage.displayName}',
                            style: AppTextStyles.bodyMedium,
                          ),
                          Text(
                            'Subjects: ${_selectedSubjects.join(", ")}',
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
                  const SizedBox(height: 24),
                  if (_selectedRole == UserRole.student) ...[
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
                              _currentStep = 2;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: CustomButton(
                          label: AppStrings.createAccount,
                          onPressed: _submitRegistrationForm,
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

  Widget _buildParentSpecificTask() {
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
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: seededSubjects.where((e) => e.stage == _selectedStage).map((
            e,
          ) {
            final isSelect = _selectedSubjects.contains(e.slug);
            return SubjectChip(
              emoji: e.emoji,
              displayName: e.displayName,
              isSelected: isSelect,
              onTap: () {
                if (isSelect) {
                  _selectedSubjects.remove(e.slug);
                } else if (_selectedSubjects.length < 3) {
                  _selectedSubjects.add(e.slug);
                }
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
        Text('Preferred Group Size', style: AppTextStyles.labelLarge),
        const SizedBox(height: 8),
        Row(
          children: GroupSize.values.map((e) {
            final isSelect = _selectedGroupSize == e;
            String title = _selectedGroupSize == GroupSize.oneToOne
                ? '1-to-1'
                : _selectedGroupSize == GroupSize.oneToFive
                ? '1-to-5'
                : '1-to-10';
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedGroupSize = e;
                });
              },
              child: Container(
                decoration: BoxDecoration(
                  color: isSelect
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : AppColors.surfaceCard,
                  border: Border.all(
                    color: isSelect ? AppColors.primary : AppColors.border,
                    width: isSelect ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                ),
                child: Center(child: Text(title, style: AppTextStyles.h4)),
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

  Widget _buildTutorSpecificTask() {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text('Tutor Profile', style: AppTextStyles.h2),
        const SizedBox(height: 8),
        Text(
          'Provide your qualifications to help us approve your application.',
          style: AppTextStyles.bodyMedium,
        ),
        const SizedBox(height: 24),
        CustomTextField(
          label: 'Teaching Experience',
          hint: 'Briefly describe your tutoring experience',
          controller: _experienceController,
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
                    if (val) {
                      _tutorSubjectSlugs.add(sub);
                    } else {
                      _tutorSubjectSlugs.remove(sub);
                    }
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
