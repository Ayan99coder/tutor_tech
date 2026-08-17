import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_tech/core/widgets/errorWidget.dart';

import 'package:tutor_tech/features/auth/provider/auth_provider.dart';
import 'package:tutor_tech/features/student/provider/provider.dart';

import '../../../core/constants/app_dimensions.dart';
import '../../../core/widgets/shimmer_loading.dart';

class StudentDashboardScreen extends ConsumerStatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  ConsumerState<StudentDashboardScreen> createState() =>
      _StudentDashboardScreenState();
}

class _StudentDashboardScreenState
    extends ConsumerState<StudentDashboardScreen> {
  @override
  void initState() {
    super.initState();
    final currentUser = ref.read(authViewModalProvider).currentUser;
    if (currentUser != null) {
      ref.read(studentProvider(currentUser.id).notifier).loadStudentProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = ref.read(authViewModalProvider).currentUser;
    final state = ref.watch(studentProvider(currentUser!.id));
    return Scaffold(
      body: state.isLoading
          ? ListView.builder(
              padding: const EdgeInsets.all(AppDimensions.paddingM),
              itemCount: 4,
              itemBuilder: (_, __) => Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: ShimmerLoading(
                  width: double.infinity,
                  height: 110,
                  borderRadius: 16,
                ),
              ),
            )
          : state.errorMessage != null
          ? CustomErrorWidget(
              message: state.errorMessage!,
              onRetry: () {
                final user = ref.read(authViewModalProvider).currentUser;
                if (user != null) {
                  ref
                      .read(studentProvider(user.id).notifier)
                      .loadStudentProfile();
                }
              },
            )
          : null,
    );
  }
}
