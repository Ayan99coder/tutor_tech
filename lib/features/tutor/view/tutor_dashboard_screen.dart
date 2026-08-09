import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_tech/core/widgets/custom_appbar.dart';
import 'package:tutor_tech/features/auth/provider/auth_provider.dart';

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
  Widget build(BuildContext context) {
    final currentTutor = ref.watch(authViewModalProvider).currentUser;
    final currentUser = currentTutor!.fullName.isNotEmpty
        ? currentTutor.fullName
        : 'tutor';
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
