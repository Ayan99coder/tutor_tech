import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tutor_tech/features/auth/authProvider/auth_provider.dart';
import 'package:tutor_tech/features/session/provider/session_provider.dart';
import 'package:tutor_tech/features/tutor/provider/tutor_provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/custom_appbar.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/error_widgets.dart';
import '../../../core/widgets/session_card.dart';

class TutorDashboardScreen extends ConsumerWidget {
  const TutorDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    late final String tutorId;
    final currentUser = ref.read(authNotifierProvider).currentUser;
    tutorId = currentUser?.id ?? '';
    final state = ref.watch(tutorProvider(tutorId));
    final sessionState = ref.watch(tutorSessions(tutorId));
    return Scaffold(
      body: Center(
        child: state.when(
          data: (tutor) {
            return CustomScrollView(
                  slivers: [
                    CustomSliverAppBar(
                      title: 'Welcome, ${tutor.tutor?.fullName ?? 'tutor'}',
                      showBackButton: false,
                      showNotificationBell: true,
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.all(AppDimensions.paddingM),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // GREETING CARD (Green Gradient)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    AppColors.tutorColor,
                                    Color(0xFF2E8B60),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusL,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Good day, ${tutor.tutor?.fullName ?? ''} 👋',
                                    style: AppTextStyles.h2.copyWith(
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'You have ${sessionState.value?.length ?? '0'} active sessions scheduled.',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),

                            // TUTOR QUICK ACTIONS ROW
                            Row(
                              children: [
                                Expanded(
                                  child: CustomButton(
                                    label: 'Upload Resource 📚',
                                    variant: ButtonVariant.primary,
                                    onPressed: () =>
                                        context.go('/assign-session'),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                            ),
                            const SizedBox(height: 24),

                            // WARNING BANNER (Dynamic)

                            // SECTION: Today's Sessions
                            Text("Today's Sessions", style: AppTextStyles.h3),
                            sessionState.when(
                              data: (sessions) {
                                if (sessions.isEmpty) {
                                  return const Text('No sessions scheduled.');
                                }

                                return Column(
                                  children: sessions.map((session) {
                                    return SessionCard(
                                      session: session,
                                      id: tutorId,
                                    );
                                  }).toList(),
                                );
                              },
                              loading: () => const CircularProgressIndicator(),
                              error: (error, stack) => Text(error.toString()),
                            ),
                            const SizedBox(height: 12),

                            const SizedBox(height: 24),

                            // SECTION: Pending Reports (Dynamic)
                            Text(
                              'Pending Lesson Reports',
                              style: AppTextStyles.h3,
                            ),
                            const SizedBox(height: 12),

                            const SizedBox(height: 24),

                            // SECTION: My Students (Dynamic)
                            Text('My Students', style: AppTextStyles.h3),
                            const SizedBox(height: 12),

                            const SizedBox(height: 140),
                            // Clear spacing so bottom cards are never covered by floating BNB!
                          ],
                        ),
                      ),
                    ),
                  ],
                )
                .animate()
                .fade(duration: const Duration(milliseconds: 500))
                .scale(
                  begin: const Offset(0.95, 0.95),
                  end: const Offset(1.0, 1.0),
                  curve: Curves.easeOutCubic,
                  duration: const Duration(milliseconds: 500),
                );
          },
          error: (error, stackTrace) {
            return CustomErrorWidget(message: error.toString(), onRetry: () {});
          },
          loading: () {
            return CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}
