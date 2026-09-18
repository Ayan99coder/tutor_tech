import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_tech/features/student/provider/student_provider.dart';
import 'package:tutor_tech/features/student/repostiory/repository.dart';
import 'package:tutor_tech/features/student/viewmodal/student_pagination_state.dart';

/// Tutor ke students ki pagination ko manage karta hai.
///
/// AutoDispose: screen close hone par state automatically reset hoti hai.
/// Family argument: tutorId (String) -- har tutor ka alag isolated state.
///
/// Usage:
///   ref.watch(studentPaginationProvider('tutor_abc'))
///   ref.read(studentPaginationProvider('tutor_abc').notifier).loadNextPage()
class StudentPaginationNotifier
    extends AutoDisposeFamilyAsyncNotifier<StudentPaginationState, String> {
  late StudentRepository _repo;

  @override
  Future<StudentPaginationState> build(String tutorId) async {
    _repo = ref.read(studentRepoProvider);

    // Pehla page fetch karo (lastDocument = null = no cursor = first page)
    final page = await _repo.getStudentsByTutorPaginated(tutorId);

    return StudentPaginationState(
      students: page.students,
      lastDocument: page.lastDocument,
      hasMore: page.hasMore,
      isLoadingMore: false,
    );
  }

  // Next page load karo
  // Teen guards prevent karte hain duplicate / unnecessary requests:
  //   Guard 1: state ready nahi
  //   Guard 2: hasMore = false (kuch bacha nahi)
  //   Guard 3: isLoadingMore = true (race condition)
  Future<void> loadNextPage() async {
    final current = state.valueOrNull;
    if (current == null) return;        // Guard 1
    if (!current.hasMore) return;       // Guard 2
    if (current.isLoadingMore) return;  // Guard 3

    // Loading flag on
    state = AsyncData(current.copyWith(isLoadingMore: true));

    try {
      final page = await _repo.getStudentsByTutorPaginated(
        arg, // tutorId (FamilyAsyncNotifier ka built-in family argument)
        lastDocument: current.lastDocument,
      );

      // Purane students mein naye append karo
      state = AsyncData(
        current.copyWith(
          students: [...current.students, ...page.students],
          lastDocument: page.lastDocument,
          hasMore: page.hasMore,
          isLoadingMore: false,
        ),
      );
    } catch (_) {
      // Error par loading flag reset karo -- user scroll karke retry kar sake
      state = AsyncData(current.copyWith(isLoadingMore: false));
    }
  }

  // Pull-to-refresh: build() dubara chalega, cursor reset hoga
  Future<void> refresh() async {
      ref.invalidateSelf();
    await future;
  }
}
