import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tutor_tech/features/admin/view/assign_session_screen.dart';
import 'package:tutor_tech/features/auth/modal/usermodal.dart';
import 'package:tutor_tech/features/auth/provider/auth_provider.dart';
import 'package:tutor_tech/features/auth/view/login_screen.dart';
import 'package:tutor_tech/features/auth/view/register_screen.dart';
import 'package:tutor_tech/features/student/view/student_dashboard_screen.dart';
import 'package:tutor_tech/features/tutor/view/tutor_dashboard_screen.dart';

/// Centralized Route Names & Paths for the application
class AppRoutes {
  static const String initial = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String studentDashboard = '/student-dashboard';
  static const String tutorDashboard = '/tutor-dashboard';
  static const String assignSession = '/assign-session';
  static const String admin = '/admin';
  static const String parentDashboard = '/parent-dashboard';
}

/// A ChangeNotifier that notifies GoRouter when the Riverpod AuthState changes.
class RouterNotifier extends ChangeNotifier {
  final Ref _ref;

  RouterNotifier(this._ref) {
    _ref.listen(authViewModalProvider, (previous, next) {
      notifyListeners();
    });
  }
}

final routerNotifierProvider = Provider<RouterNotifier>((ref) {
  return RouterNotifier(ref);
});

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final routerProvider = Provider<GoRouter>((ref) {
  final notifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppRoutes.login,
    refreshListenable: notifier,
    debugLogDiagnostics: true,
    redirect: (BuildContext context, GoRouterState state) {
      final authState = ref.read(authViewModalProvider);
      final isLoggedIn = authState.isAuthenticated && authState.currentUser != null;
      final currentLocation = state.matchedLocation;

      final isLoggingIn = currentLocation == AppRoutes.login;
      final isRegistering = currentLocation == AppRoutes.register;

      // If user is not logged in and tries to access a protected route
      if (!isLoggedIn) {
        if (isLoggingIn || isRegistering) {
          return null; // allow access to auth screens
        }
        return AppRoutes.login;
      }

      // If user is logged in and is currently on login or register screen, redirect to their role-specific dashboard
      if (isLoggingIn || isRegistering || currentLocation == AppRoutes.initial) {
        final role = authState.currentUser?.role;
        switch (role) {
          case UserRole.student:
            return AppRoutes.studentDashboard;
          case UserRole.tutor:
            return AppRoutes.tutorDashboard;
          case UserRole.admin:
            return AppRoutes.assignSession;
          case UserRole.parent:
            return AppRoutes.parentDashboard;
          default:
            return AppRoutes.studentDashboard;
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.initial,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: AppRoutes.studentDashboard,
        name: 'studentDashboard',
        builder: (context, state) => const StudentDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.tutorDashboard,
        name: 'tutorDashboard',
        builder: (context, state) => const TutorDashboardScreen(),
      ),
      GoRoute(
        path: AppRoutes.assignSession,
        name: 'assignSession',
        builder: (context, state) => const AssignSessionScreen(),
      ),
      GoRoute(
        path: AppRoutes.admin,
        name: 'admin',
        builder: (context, state) => const AssignSessionScreen(),
      ),
      GoRoute(
        path: AppRoutes.parentDashboard,
        name: 'parentDashboard',
        builder: (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Parent Dashboard')),
          body: const Center(
            child: Text('Parent Dashboard Screen (Coming Soon)'),
          ),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'No route defined for ${state.uri}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.login),
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    ),
  );
});
