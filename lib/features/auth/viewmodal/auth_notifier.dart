import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_tech/core/utils/utils/validators.dart';
import 'package:tutor_tech/features/auth/authProvider/auth_provider.dart';

import 'package:tutor_tech/features/auth/viewmodal/auth_state.dart';

import '../../student/model/student_model.dart';
import '../repository/auth_repository.dart';

class AuthNotifier extends Notifier<AuthState> {
  late final AuthRepository repo;
  final AuthErrorHandler _authErrorHandler = AuthErrorHandler();
  StreamSubscription? _authStateSubscription;

  @override
  AuthState build() {
    repo = ref.watch(authRepoProvider);
    _authStateSubscription?.cancel();
    _authStateSubscription = repo.authStateChanges().listen((user) {
      if (user != null) {
        state = state.copyWith(
          currentUser: user,
          isAuthenticated: true,
          isEmailVerified: true,
          isLoading: false,
          errorMessage: null,
        );
      } else {
        state = state.copyWith(
          currentUser: null,
          isAuthenticated: false,
          isLoading: false,
        );
      }
    });

    ref.onDispose(() {
      _authStateSubscription?.cancel();
    });

    return const AuthState(isLoading: true);
  }

  Future<void> registerStudentWithEmailAndPassword({
    required String fullName,
    required String email,
    required String password,
    required AgeGroup ageGroup,
    required List<String> subjects,
    required GroupSize preferredGroupSize,
    required CommunicationPref communicationPref,
    required bool isUnder13,
    String? parentEmail,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null, isRegSuccess: false);

    try {
      await repo.registerStudent(
        fullName: fullName,
        email: email,
        password: password,
        ageGroup: ageGroup,
        subjects: subjects,
        preferredGroupSize: preferredGroupSize,
        communicationPref: communicationPref,
        isUnder13: isUnder13,
        parentEmail: parentEmail,
      );
      await repo.signOut();
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        isRegSuccess: true,
        currentUser: null,
        isEmailVerified: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _authErrorHandler.getMessage(e),
      );
    }
  }


  Future<void> registerTutorWithEmailAndPassword({
    required String fullName,
    required String email,
    required String password,
    required String education,
    required String teachingExperience,
    required List<String> subjects,
    required List<String> teachingLevels,
    String? cvLink,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null,isRegSuccess: false);

    try {
      await repo.registerTutor(
        fullName: fullName,
        email: email,
        password: password,
        education: education,
        teachingExperience: teachingExperience,
        subjects: subjects,
        teachingLevels: teachingLevels,
        cvLink: cvLink,
      );
      await repo.signOut();
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        currentUser: null,
        isEmailVerified: false,
        isRegSuccess: true
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _authErrorHandler.getMessage(e),
      );
    }
  }

  Future<void> registerParentWithEmailAndPassword({
    required String fullName,
    required String email,
    required String password,
    required List<String> childrenEmails,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null,isRegSuccess: false);

    try {
      await repo.registerParent(
        fullName: fullName,
        email: email,
        password: password,
        childrenEmails: childrenEmails,
      );
      await repo.signOut();
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        isRegSuccess: true,
        currentUser: null,
        isEmailVerified: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _authErrorHandler.getMessage(e),
      );
    }
  }


  Future<void> signInWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final user = await repo.signInWithEmail(email, password);

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        currentUser: user,
        isEmailVerified: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }


  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      await repo.signOut();

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        currentUser: null,
        isEmailVerified: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: _authErrorHandler.getMessage(e),
      );
    }
  }
}
