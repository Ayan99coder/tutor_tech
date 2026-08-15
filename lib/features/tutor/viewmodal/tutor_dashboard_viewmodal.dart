import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_tech/features/student/model/student_model.dart';
import 'package:tutor_tech/features/tutor/viewmodal/tutor_dashboard_state.dart';

import '../model/tutor_repository.dart';
import '../provider/tutor_dashboardScreen_provider.dart';

class TutorDashboardViewmodal
    extends FamilyNotifier<TutorDashboardState, String> {
  late final TutorRepository tutorRepo;
  late final String tutorIds;
  StreamSubscription<List<StudentModel>>? _studentsSubscription;

  @override
  TutorDashboardState build(String tutorId) {
    tutorIds = tutorId;
    tutorRepo = ref.read(tutorRepoProvider);
    watchAssignedStudents();
    ref.onDispose(() {
      _studentsSubscription?.cancel();
    });
    return const TutorDashboardState();
  }

  Future<void> loadProfile() async {
    // Already loaded → Firebase request nahi
    if (state.tutor != null) {
      return;
    }

    try {
      state = state.copyWith(isLoading: true, clearError: true);

      final tutor = await tutorRepo.getTutorById(tutorIds);

      state = state.copyWith(isLoading: false, tutor: tutor);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void watchAssignedStudents() {
    _studentsSubscription?.cancel();

    _studentsSubscription = tutorRepo
        .watchAssignedStudents(tutorIds)
        .listen(
          (students) {
            state = state.copyWith(assignedStudents: students);
          },
          onError: (error) {
            state = state.copyWith(errorMessage: error.toString());
          },
        );
  }
}
