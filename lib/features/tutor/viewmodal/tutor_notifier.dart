import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_tech/features/tutor/provider/tutor_provider.dart';
import 'package:tutor_tech/features/tutor/repository/repostiory.dart';
import 'package:tutor_tech/features/tutor/viewmodal/tutor_state.dart';

class TutorNotifier extends FamilyAsyncNotifier<TutorState, String?> {
  late final TutorRepository repo;

  @override
  Future<TutorState> build(String? id) async {
    repo = ref.read(tutorRepoProvider);
    final tutor = await repo.getTutorById(id!);

    return TutorState(tutor: tutor,);
  }
}
