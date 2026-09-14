import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tutor_tech/features/auth/authProvider/auth_provider.dart';
import 'package:tutor_tech/features/auth/modal/user_model.dart';
import 'package:tutor_tech/features/auth/screen/login_screen.dart';
import 'package:tutor_tech/features/auth/screen/register_screen.dart';
import 'package:tutor_tech/features/parent/view/parent_dasboard_screen.dart';
import 'package:tutor_tech/features/session/view/assign_session_screen.dart';
import 'package:tutor_tech/features/student/view/student_dasboard_screen.dart';
import 'package:tutor_tech/features/tutor/view/tutor_dasboard_screen.dart';

import '../../splashScreen.dart';

part 'router.g.dart';
@TypedGoRoute<SplashRoute>(path: '/')
class SplashRoute extends GoRouteData with $SplashRoute {
  const SplashRoute();

  @override
  Widget build(BuildContext context, GoRouterState state) {
    return const SplashScreen();
  }
}
@TypedGoRoute<LoginRoute>(path: '/login')
class LoginRoute extends GoRouteData with $LoginRoute {
  const LoginRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => const LoginScreen();
}

@TypedGoRoute<RegisterRoute>(path: '/register')
class RegisterRoute extends GoRouteData with $RegisterRoute {
  const RegisterRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => const RegisterScreen();
}

@TypedGoRoute<TutorDashboardRoute>(path: '/tutor-dashboard')
class TutorDashboardRoute extends GoRouteData with $TutorDashboardRoute {
  const TutorDashboardRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => const TutorDashboardScreen();
}

@TypedGoRoute<StudentDashboardRoute>(path: '/student-dashboard')
class StudentDashboardRoute extends GoRouteData with $StudentDashboardRoute {
  const StudentDashboardRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => const StudentDashboardScreen();
}

@TypedGoRoute<ParentDashboardRoute>(path: '/parent-dashboard')
class ParentDashboardRoute extends GoRouteData with $ParentDashboardRoute {
  const ParentDashboardRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => const ParentDasboardScreen();
}

@TypedGoRoute<AssignSessionRoute>(path: '/assign-session')
class AssignSessionRoute extends GoRouteData with $AssignSessionRoute {
  const AssignSessionRoute();
  @override
  Widget build(BuildContext context, GoRouterState state) => const AssignSessionScreen();
}

class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen(authNotifierProvider, (previous, next) {
      notifyListeners();
    });
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final appRouterProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: notifier,
    routes: $appRoutes,
      redirect: (context, state) {
        final authState = ref.read(authNotifierProvider);

        final location = state.matchedLocation;

        if (authState.isLoading) {
          return location == '/' ? null : '/';
        }

        final isAuthenticated =
            authState.isAuthenticated &&
                authState.currentUser != null;

        if (!isAuthenticated) {
          if (location == '/login' || location == '/register') {
            return null;
          }

          return '/login';
        }

        // Authenticated user
        final role = authState.currentUser!.role;

        if (location == '/' ||
            location == '/login' ||
            location == '/register') {
          switch (role) {
            case UserRole.tutor:
              return '/tutor-dashboard';

            case UserRole.student:
              return '/student-dashboard';

            case UserRole.parent:
              return '/parent-dashboard';
          }
        }

        return null;
      },
  );
});
