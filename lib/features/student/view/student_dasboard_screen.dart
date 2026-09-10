import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_tech/core/widgets/error_widgets.dart';
import 'package:tutor_tech/features/auth/authProvider/auth_provider.dart';
import 'package:tutor_tech/features/session/provider/session_provider.dart';
import 'package:tutor_tech/features/student/provider/student_provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/custom_appBar.dart';

class StudentDashboardScreen extends ConsumerWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('User not found')));
    }

    final studentAsync = ref.watch(studentProvider(user.id));
    final sessionState = ref.watch(studentSessions(user.id));
    return Scaffold(
      body: Center(
        child: studentAsync.when(
          loading: () {
            return const CircularProgressIndicator();
          },

          error: (error, stackTrace) {
            return CustomErrorWidget(
              message: error.toString(),
              onRetry: () {
                ref.invalidate(studentProvider(user.id));
              },
            );
          },

          data: (student) {
            final state = student.student;
            return CustomScrollView(
              slivers: [
                CustomSliverAppBar(
                  title: 'My Learning Hub',
                  showBackButton: false,
                  showNotificationBell: true,
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingM),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // HERO CARD (Primary Color Gradient)
                        Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.primaryLight,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusCard,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Hello, ${state?.fullName ?? "Student"} 👋',
                                    style: AppTextStyles.h2.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Assigned Tutor : ${student.assignedTutors ?? []} ',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.accentLight,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Wrap(
                                    spacing: 8,
                                    children: (state?.selectedSubjects ?? [])
                                        .map((s) {
                                          return Chip(
                                            label: Text(
                                              s.toUpperCase().replaceAll(
                                                '_',
                                                ' ',
                                              ),
                                            ),
                                            backgroundColor:
                                                AppColors.secondary,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: .circular(12),
                                            ),
                                            labelStyle: AppTextStyles.labelSmall
                                                .copyWith(color: Colors.white),
                                          );
                                        })
                                        .toList(),
                                  ),
                                ],
                              ),
                            )
                            .animate()
                            .fade(duration: const Duration(milliseconds: 500))
                            .scale(
                              begin: const Offset(0.95, 0.95),
                              end: const Offset(1.0, 1.0),
                              curve: Curves.easeOutCubic,
                              duration: const Duration(milliseconds: 500),
                            ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
