  import 'package:flutter_riverpod/flutter_riverpod.dart';
  import 'package:tutor_tech/features/tutor/provider/tutor_provider.dart';
  import 'package:tutor_tech/features/tutor/repository/repostiory.dart';
  import 'package:tutor_tech/features/tutor/viewmodal/tutor_state.dart';

  class TutorNotifier extends FamilyNotifier<TutorState, String> {
    late final String ids;
    late final TutorRepository repo;

    @override
    TutorState build(String id) {
      ids = id;
      repo = ref.read(tutorRepoProvider);
      return TutorState();
    }

    Future<void> getTutorById() async {
      try {
        state = state.copyWith( isLoading: true,clearError: true);
        final user = await repo.getTutorById(ids);
        state = state.copyWith(tutor: user, isLoading: false,);
      } catch (e) {
        state = state.copyWith(errorMessage: e.toString(), isLoading: false);
      }
    }
  }
