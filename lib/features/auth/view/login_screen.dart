import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tutor_tech/core/router/app_router.dart';
import 'package:tutor_tech/core/widgets/loading_overlay.dart';
import 'package:tutor_tech/features/auth/provider/auth_provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_textfield.dart';

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
  void _handleLogin() {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    setState(() {
      _emailError = Validators.validateEmail(email);
      _passwordError = Validators.validatePassword(password);
    });

    if (_emailError == null && _passwordError == null) {
      ref.read(authViewModalProvider.notifier).login(email, password);
    }
  }
  @override
  Widget build(BuildContext context) {
    final watcher = ref.watch(authViewModalProvider);
    return LoadingOverlay(
      isLoading: watcher.isLoading,
      message: 'Signing in',
      child: Scaffold(
        backgroundColor: AppColors.primary,
        body: SafeArea(
          child: Column(
            children: [
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
                          isLoading: watcher.isLoading,
                        ),

                        if (watcher.errorMessage != null) ...[
                          const SizedBox(height: 12),
                          Center(
                            child: Text(
                              watcher.errorMessage!,
                              style: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                            ),
                          ),
                        ],
                        const SizedBox(height: 20),

                        // Register Links
                        Center(
                          child: Column(
                            children: [
                              TextButton(
                                onPressed: () => context.push(AppRoutes.register),
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
                                onPressed: () => context.push(AppRoutes.register),
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
              ).animate().slideY(
                begin: 0.2, end: 0,
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutCubic,
              ).fade(
                duration: const Duration(milliseconds: 700),
              ),
            ],
          ),

        ),
      ),
    );
  }
}
