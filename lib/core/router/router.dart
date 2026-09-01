import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tutor_tech/features/parent/view/parent_dasboard_screen.dart';
import 'package:tutor_tech/features/student/view/student_dasboard_screen.dart';
import 'package:tutor_tech/features/tutor/view/tutor_dasboard_screen.dart';

import '../../features/auth/screen/login_screen.dart';
import '../../features/auth/screen/register_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/login',

    routes: [
      GoRoute(
        path: '/tutor-dashboard',
        name: 'tutor',
        builder: (context, state) {
          return const TutorDasboardScreen();
        },
      ),
      GoRoute(
        path: '/student-dashboard',
        name: 'student',
        builder: (context, state) {
          return const StudentDasboardScreen();
        },
      ),
      GoRoute(
        path: '/parent-dashboard',
        name: 'parent',
        builder: (context, state) {
          return const ParentDasboardScreen();
        },
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) {
          return const LoginScreen();
        },
      ),

      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) {
          return const RegisterScreen();
        },
      ),
    ],
  );
});
