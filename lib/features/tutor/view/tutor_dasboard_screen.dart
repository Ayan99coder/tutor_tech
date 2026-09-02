import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_tech/features/auth/authProvider/auth_provider.dart';
import 'package:tutor_tech/features/tutor/provider/tutor_provider.dart';

class TutorDashboardScreen extends ConsumerStatefulWidget {
  const TutorDashboardScreen({super.key});

  @override
  ConsumerState<TutorDashboardScreen> createState() =>
      _TutorDashboardScreenState();
}

class _TutorDashboardScreenState extends ConsumerState<TutorDashboardScreen> {
  late final String tutorId;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authNotifierProvider).currentUser;
    tutorId = user?.id ?? '';

    ref.read(tutorProvider(tutorId).notifier).getTutorById();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tutorProvider(tutorId));
    return Scaffold(
      body: Center(child: Text('this is ${state.tutor?.fullName ?? 'Tutor'}')),
    );
  }
}
