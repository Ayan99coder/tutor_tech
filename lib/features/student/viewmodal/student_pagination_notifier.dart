import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_tech/features/student/provider/student_provider.dart';
import 'package:tutor_tech/features/student/repostiory/repository.dart';
import 'package:tutor_tech/features/student/viewmodal/student_pagination_state.dart';


class StudentPaginationNotifier
    extends AutoDisposeFamilyAsyncNotifier<StudentPaginationState, String> {
  late StudentRepository _repo;

  @override
  Future<StudentPaginationState> build(String tutorId) async {
    _repo = ref.read(studentRepoProvider);
    final page = await _repo.getStudentsByTutorPaginated(tutorId);

    return StudentPaginationState(
      students: page.students,
      lastDocument: page.lastDocument,
      hasMore: page.hasMore,
      isLoadingMore: false,
    );
  }
  Future<void> loadNextPage() async {
    final current = state.valueOrNull;
    if (current == null) return;
    if (!current.hasMore) return;
    if (current.isLoadingMore) return;
    state = AsyncData(current.copyWith(isLoadingMore: true));

    try {
      final page = await _repo.getStudentsByTutorPaginated(
        arg,
        lastDocument: current.lastDocument,
      );
      state = AsyncData(
        current.copyWith(
          students: [...current.students, ...page.students],
          lastDocument: page.lastDocument,
          hasMore: page.hasMore,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }
  }
  Future<void> refresh() async {
      ref.invalidateSelf();
    await future;
  }
}
