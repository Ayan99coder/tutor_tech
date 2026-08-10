import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:tutor_tech/features/tutor/model/tutor_model.dart';
import 'package:tutor_tech/features/tutor/viewmodal/tutor_dashboard_state.dart';

import '../model/tutor_repository.dart';
import '../provider/tutor_dashboardScreen_provider.dart';

class TutorDashboardViewmodal
    extends AutoDisposeFamilyNotifier<TutorDashboardState, String> {
  late final TutorRepository tutorRepo;
  late String tutorIds;

  @override
  TutorDashboardState build(String tutorId) {
    tutorIds = tutorId;
    tutorRepo = ref.read(tutorRepoProvider);
    return const TutorDashboardState();
  }

  Future<void> loadProfile() async {
    try {
      state = state.copyWith(isLoading: true, clearError: true);
      final tutor = await tutorRepo.getTutorById(tutorIds);
      final assignedStd = await tutorRepo.getAssignedStudentsBasicInfo(
        tutorIds,
      );
      state = state.copyWith(
        isLoading: false,
        assignedStudents: assignedStd,
        tutor: tutor,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}
