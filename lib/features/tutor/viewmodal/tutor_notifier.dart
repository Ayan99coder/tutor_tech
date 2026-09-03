import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_tech/features/tutor/provider/tutor_provider.dart';
import 'package:tutor_tech/features/tutor/repository/repostiory.dart';
import 'package:tutor_tech/features/tutor/viewmodal/tutor_state.dart';

class TutorNotifier extends FamilyAsyncNotifier<TutorState, String> {
  late final String ids;
  late final TutorRepository repo;

  @override
  TutorState build(String id) {
    ids = id;
    repo = ref.read(tutorRepoProvider);
    getTutorById();
    return TutorState();
  }

  Future<void> getTutorById() async {
    final user = await repo.getTutorById(ids);
    state = AsyncData(state.requireValue.copyWith(tutor: user));
  }
}
