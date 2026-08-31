import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tutor_tech/features/auth/authProvider/auth_provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';

import '../../../core/utils/utils/validators.dart';

import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_textfield.dart';
import '../../../core/widgets/loading_overlay.dart';

import 'package:flutter_animate/flutter_animate.dart';
import '../modal/user_model.dart';

import '../viewmodal/auth_state.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String? _emailError;
  String? _passwordError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _emailError = Validators.validateEmail(email);
      _passwordError = Validators.validatePassword(password);
    });

    if (_emailError == null && _passwordError == null) {
      ref.read(authNotifierProvider.notifier).signInWithEmail(email, password);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authNotifierProvider, (prev, next) {
      if (next.isAuthenticated && next.currentUser != null) {
        final user = next.currentUser!;
        switch (user.role) {
          case UserRole.tutor:
            context.go('/tutor-dashboard');
            break;
          case UserRole.student:
            context.go('/student-dashboard');
            break;
          case UserRole.parent:
            context.go('/parent-dashboard');
            break;
        }
      }
    });

    final authState = ref.watch(authNotifierProvider);

    return LoadingOverlay(
      isLoading: authState.isLoading,
      message: 'Signing in...',
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // Top Banner Area
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 24.0,
                  horizontal: 24.0,
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(40),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          AppStrings.appLogo,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.school_rounded,
                            size: 54,
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppStrings.appName,
                      style: AppTextStyles.h2.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      AppStrings.welcomeBack,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.accentLight,
                      ),
                    ),
                  ],
                ),
              ),

              // Sliding White Form Card
              Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceWhite,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(AppDimensions.radiusXL),
                          topRight: Radius.circular(AppDimensions.radiusXL),
                        ),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(AppDimensions.paddingL),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.signInToContinue,
                              style: AppTextStyles.h3,
                            ),
                            const SizedBox(height: 20),

                            // Email Field
                            CustomTextField(
                              label: AppStrings.emailLabel,
                              hint: AppStrings.emailHint,
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              prefixIcon: Icons.email_outlined,
                              errorText: _emailError,
                            ),
                            const SizedBox(height: 16),

                            // Password Field
                            CustomTextField(
                              label: AppStrings.passwordLabel,
                              hint: AppStrings.passwordHint,
                              controller: _passwordController,
                              obscureText: true,
                              showToggle: true,
                              prefixIcon: Icons.lock_outline,
                              errorText: _passwordError,
                            ),
                            const SizedBox(height: 8),

                            // Forgot Password Link
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {},
                                child: Text(
                                  AppStrings.forgotPassword,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Sign In Button
                            CustomButton(
                              label: AppStrings.signInButton,
                              onPressed: _handleLogin,
                              isLoading: authState.isLoading,
                            ),

                            if (authState.errorMessage != null) ...[
                              const SizedBox(height: 12),
                              Center(
                                child: Text(
                                  authState.errorMessage!,
                                  style: AppTextStyles.bodySmall.copyWith(
                                    color: AppColors.error,
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 20),

                            // Register Links
                            Center(
                              child: Column(
                                children: [
                                  TextButton(
                                    onPressed: () => context.push('/register'),
                                    child: Text(
                                      AppStrings.newStudentRegister,
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  TextButton(
                                    onPressed: null,
                                    child: Text(
                                      AppStrings.applyToTeach,
                                      style: AppTextStyles.bodySmall.copyWith(
                                        color: AppColors.textSecondary,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                  .animate()
                  .slideY(
                    begin: 0.2,
                    end: 0,
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                  )
                  .fade(duration: const Duration(milliseconds: 700)),
            ],
          ),
        ),
      ),
    );
  }
}
