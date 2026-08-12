import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tutor_tech/features/student/model/student_dashboard_state.dart';

import 'package:tutor_tech/features/student/provider/provider.dart';

import '../model/student_repository.dart';

class StudentDashboardNotifier
    extends FamilyNotifier<StudentDashboardState, String> {
  late final String ids;
  late final StudentRepository repo;

  @override
  StudentDashboardState build(String id) {
    ids = id;
    repo = ref.read(studentRepoProvider);
    return StudentDashboardState();
  }

  Future<void> loadStudentProfile() async {
    if (state.student != null) return;
    try {
      state = state.copyWith(isLoading: true, clearError: false);
      final data = await repo.getStudentById(ids);
      state = state.copyWith(isLoading: false, student: data);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        clearError: true,
        errorMessage: e.toString(),
      );
    }
  }
}
