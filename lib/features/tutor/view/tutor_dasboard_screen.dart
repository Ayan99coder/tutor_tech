import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_tech/features/auth/authProvider/auth_provider.dart';
import 'package:tutor_tech/features/tutor/provider/tutor_provider.dart';

import '../../../core/widgets/error_widgets.dart';

class TutorDashboardScreen extends ConsumerStatefulWidget {
  const TutorDashboardScreen({super.key});

  @override
  ConsumerState<TutorDashboardScreen> createState() =>
      _TutorDashboardScreenState();
}

class _TutorDashboardScreenState extends ConsumerState<TutorDashboardScreen> {
  late final String tutorId;

  @override
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tutorProvider(tutorId));
    return Scaffold(
      body: Center(
        child: state.when(
          data: (tutor) {},
          error: (error, stackTrace) {
            return CustomErrorWidget(message: error.toString(), onRetry: () {});
          },
          loading: () {},
        ),
      ),
    );
  }
}
