import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tutor_tech/features/student/model/student_dashboard_state.dart';

import 'package:tutor_tech/features/student/provider/provider.dart';
import 'package:tutor_tech/features/tutor/model/tutor_repository.dart';
import 'package:tutor_tech/features/tutor/provider/tutor_dashboardScreen_provider.dart';

import '../model/student_repository.dart';

class StudentDashboardNotifier
    extends FamilyNotifier<StudentDashboardState, String> {
  late final String ids;
  late final StudentRepository studentRepo;
  late final TutorRepository tutorRepo;

  @override
  StudentDashboardState build(String id) {
    ids = id;
    studentRepo = ref.read(studentRepoProvider);
    tutorRepo = ref.read(tutorRepoProvider);

    return StudentDashboardState();
  }

  Future<void> loadStudentProfile() async {
    if (state.student != null) return;
    try {
      state = state.copyWith(isLoading: true, clearError: false);
      final student = await studentRepo.getStudentById(ids);
      if (student == null) throw Exception("Student profile not found");
      final tutor = student.assignedTutorId != null
          ? await tutorRepo.getTutorById(student.assignedTutorId!)
          : null;

      state = state.copyWith(
        isLoading: false,
        student: student,
        assignedTutor: tutor,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        clearError: true,
        errorMessage: e.toString(),
      );
    }
  }
}
