import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_tech/features/tutor/provider/tutor_provider.dart';
import 'package:tutor_tech/features/tutor/repository/repostiory.dart';
import 'package:tutor_tech/features/tutor/viewmodal/tutor_state.dart';

class TutorNotifier extends FamilyAsyncNotifier<TutorState, String?> {
  late TutorRepository repo;

  @override
  Future<TutorState> build(String? id) async {
    ref.keepAlive();
    repo = ref.read(tutorRepoProvider);

    // Fetch tutor profile + first page of students in parallel
    final tutor = await repo.getTutorById(id!);

    if (tutor == null) {
      return const TutorState();
    }

    // Load first page
    final page = await repo.getStudentsByTutorPaginated(
      id,
      tutor.subjectExpertise,
      limit: 5,
    );

    return TutorState(
      tutor: tutor,
      stdByTutor: page.students, // legacy field
      students: page.students,
      lastDocument: page.lastDocument,
      hasMore: page.hasMore,
      isLoadingMore: false,
    );
  }

  /// Fetches the next page of students and appends them to the current list.
  /// Safe to call multiple times — ignores duplicate calls while loading.
  Future<void> loadNextPage() async {
    final current = state.valueOrNull;
    if (current == null) return;
    if (!current.hasMore) return;
    if (current.isLoadingMore) return;

    // Mark as loading
    state = AsyncData(current.copyWith(isLoadingMore: true));

    try {
      final page = await repo.getStudentsByTutorPaginated(
        current.tutor!.id,
        current.tutor!.subjectExpertise,
        lastDocument: current.lastDocument,
        limit: 5,
      );

      final updated = current.copyWith(
        students: [...current.students, ...page.students],
        stdByTutor: [...current.stdByTutor, ...page.students],
        lastDocument: page.lastDocument,
        hasMore: page.hasMore,
        isLoadingMore: false,
      );

      state = AsyncData(updated);
    } catch (e, st) {
      // Restore loading flag on error so user can retry via scroll
      state = AsyncData(current.copyWith(isLoadingMore: false));
      // Surface error without wiping current data
      state = AsyncError(e, st);
    }
  }
}
