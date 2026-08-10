import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_tech/core/widgets/custom_appbar.dart';
import 'package:tutor_tech/core/widgets/custom_button.dart';
import 'package:tutor_tech/features/auth/provider/auth_provider.dart';
import 'package:tutor_tech/features/tutor/provider/tutor_dashboardScreen_provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';

class TutorDashboardScreen extends ConsumerStatefulWidget {
  const TutorDashboardScreen({super.key});

  @override
  ConsumerState<TutorDashboardScreen> createState() =>
      _TutorDashboardScreenState();
}

class _TutorDashboardScreenState extends ConsumerState<TutorDashboardScreen> {
  @override
  void initState() {
    super.initState();
    final currentTutor = ref.watch(authViewModalProvider).currentUser;
    if (currentTutor != null) {
      ref.read(tutorDashboardProvider(currentTutor.id).notifier).loadProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentTutor = ref.watch(authViewModalProvider).currentUser;
    final currentUser = currentTutor!.fullName.isNotEmpty
        ? currentTutor.fullName
        : 'tutor';
    final dashboardState = ref.watch(tutorDashboardProvider(currentTutor.id));
    final pendingReport = dashboardState.pendingReportSessions;
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          CustomAppbar(
            title: 'Welcome,$currentUser',
            showBackButton: false,
            showNotificationBell: true,
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              child: Column(
                crossAxisAlignment: .start,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.tutorColor, Color(0xFF2E8B60)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusL,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Good day, $currentTutor',
                          style: AppTextStyles.h2.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'You have  ${dashboardState.todaySessions.length} active sessions scheduled.',
                          style: AppTextStyles.bodyMedium.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: CustomButton(
                                label: 'Upload Resource 📚',
                                variant: ButtonVariant.primary,
                                onPressed: () => null,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: CustomButton(
                                label: 'Manage Groups 👥',
                                variant: ButtonVariant.secondary,
                                onPressed: () {},
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        if (pendingReport.isNotEmpty) ...[
                          Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.warning.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    AppDimensions.radiusM,
                                  ),
                                  border: Border.all(
                                    color: AppColors.warning.withValues(
                                      alpha: 0.5,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                          Icons.access_time_filled,
                                          color: AppColors.warning,
                                        )
                                        .animate(
                                          onPlay: (c) =>
                                              c.repeat(reverse: true),
                                        )
                                        .shimmer(
                                          duration: const Duration(
                                            milliseconds: 1200,
                                          ),
                                          color: Colors.white,
                                        )
                                        .scale(
                                          end: const Offset(1.1, 1.1),
                                          duration: const Duration(
                                            milliseconds: 1200,
                                          ),
                                        ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'You have ${pendingReport.length} pending report(s) to submit.',
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(
                                              color: AppColors.textPrimary,
                                            ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () => null,
                                      child: const Text('Review Now'),
                                    ),
                                  ],
                                ),
                              )
                              .animate()
                              .slideY(
                                begin: -0.2,
                                end: 0,
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeOutCubic,
                              )
                              .fade(
                                duration: const Duration(milliseconds: 400),
                              ),
                          const SizedBox(height: 24),
                        ],
                        Text("Today's Sessions", style: AppTextStyles.h3),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
