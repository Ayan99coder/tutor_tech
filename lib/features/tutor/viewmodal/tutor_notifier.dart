import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_tech/features/tutor/provider/tutor_provider.dart';
import 'package:tutor_tech/features/tutor/repository/repostiory.dart';
import 'package:tutor_tech/features/tutor/viewmodal/tutor_state.dart';

/// Sirf tutor ki profile fetch karta hai.
/// Students ki pagination → StudentPaginationNotifier (alag provider)
class TutorNotifier extends FamilyAsyncNotifier<TutorState, String?> {
  late TutorRepository repo;

  @override
  Future<TutorState> build(String? id) async {
    ref.keepAlive();
    repo = ref.read(tutorRepoProvider);

    final tutor = await repo.getTutorById(id!);

    if (tutor == null) {
      return const TutorState();
    }

    return TutorState(tutor: tutor);
  }
}
