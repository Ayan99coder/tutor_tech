// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'router.dart';

// **************************************************************************
// GoRouterGenerator
// **************************************************************************

List<RouteBase> get $appRoutes => [
  $loginRoute,
  $registerRoute,
  $tutorDashboardRoute,
  $studentDashboardRoute,
  $parentDashboardRoute,
  $assignSessionRoute,
];

RouteBase get $loginRoute => GoRouteData.$route(
  path: '/login',
  hasOverriddenOnExit: false,
  factory: $LoginRoute._fromState,
);

mixin $LoginRoute on GoRouteData {
  static LoginRoute _fromState(GoRouterState state) => const LoginRoute();

  @override
  String get location => GoRouteData.$location('/login');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $registerRoute => GoRouteData.$route(
  path: '/register',
  hasOverriddenOnExit: false,
  factory: $RegisterRoute._fromState,
);

mixin $RegisterRoute on GoRouteData {
  static RegisterRoute _fromState(GoRouterState state) => const RegisterRoute();

  @override
  String get location => GoRouteData.$location('/register');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $tutorDashboardRoute => GoRouteData.$route(
  path: '/tutor-dashboard',
  hasOverriddenOnExit: false,
  factory: $TutorDashboardRoute._fromState,
);

mixin $TutorDashboardRoute on GoRouteData {
  static TutorDashboardRoute _fromState(GoRouterState state) =>
      const TutorDashboardRoute();

  @override
  String get location => GoRouteData.$location('/tutor-dashboard');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $studentDashboardRoute => GoRouteData.$route(
  path: '/student-dashboard',
  hasOverriddenOnExit: false,
  factory: $StudentDashboardRoute._fromState,
);

mixin $StudentDashboardRoute on GoRouteData {
  static StudentDashboardRoute _fromState(GoRouterState state) =>
      const StudentDashboardRoute();

  @override
  String get location => GoRouteData.$location('/student-dashboard');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $parentDashboardRoute => GoRouteData.$route(
  path: '/parent-dashboard',
  hasOverriddenOnExit: false,
  factory: $ParentDashboardRoute._fromState,
);

mixin $ParentDashboardRoute on GoRouteData {
  static ParentDashboardRoute _fromState(GoRouterState state) =>
      const ParentDashboardRoute();

  @override
  String get location => GoRouteData.$location('/parent-dashboard');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}

RouteBase get $assignSessionRoute => GoRouteData.$route(
  path: '/assign-session',
  hasOverriddenOnExit: false,
  factory: $AssignSessionRoute._fromState,
);

mixin $AssignSessionRoute on GoRouteData {
  static AssignSessionRoute _fromState(GoRouterState state) =>
      const AssignSessionRoute();

  @override
  String get location => GoRouteData.$location('/assign-session');

  @override
  void go(BuildContext context) => context.go(location);

  @override
  Future<T?> push<T>(BuildContext context) => context.push<T>(location);

  @override
  void pushReplacement(BuildContext context) =>
      context.pushReplacement(location);

  @override
  void replace(BuildContext context) => context.replace(location);
}
