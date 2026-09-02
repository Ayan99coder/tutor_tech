import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_tech/core/widgets/error_widgets.dart';
import 'package:tutor_tech/features/auth/authProvider/auth_provider.dart';
import 'package:tutor_tech/features/student/provider/student_provider.dart';

class StudentDashboardScreen extends ConsumerWidget {
  const StudentDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text('User not found')));
    }

    final studentAsync = ref.watch(studentProvider(user.id));

    return Scaffold(
      body: Center(
        child: studentAsync.when(
          loading: () {
            return const CircularProgressIndicator();
          },

          error: (error, stackTrace) {
            return CustomErrorWidget(message: error.toString(), onRetry: (){studentAsync;});
          },

          data: (student) {
            final state = student.student;
            return Text('This is ${state?.fullName??'student'}');
          },
        ),
      ),
    );
  }
}
