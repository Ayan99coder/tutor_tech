import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_tech/core/provider/third_party_provider.dart';
import 'package:tutor_tech/features/student/repostiory/repository.dart';
import 'package:tutor_tech/features/student/repostiory/repository_impl.dart';
import 'package:tutor_tech/features/student/viewmodal/student_notifier.dart';
import 'package:tutor_tech/features/student/viewmodal/student_pagination_notifier.dart';
import 'package:tutor_tech/features/student/viewmodal/student_pagination_state.dart';
import 'package:tutor_tech/features/student/viewmodal/student_state.dart';
import 'package:tutor_tech/features/tutor/provider/tutor_provider.dart';

final studentRepoProvider = Provider<StudentRepository>((ref) {
  return StudentRepositoryImpl(
    ref.read(fireStoreProvider),
    ref.read(tutorRepoProvider),
  );
});

// ── Existing student profile provider (unchanged) ──────────────────────────
final studentProvider = AsyncNotifierProviderFamily<
    StudentNotifier,
    StudentState,
    String>(
  StudentNotifier.new,
);

// ── Pagination provider ─────────────────────────────────────────────────────
/// Har tutorId ka alag isolated pagination state.
///
/// AutoDispose: screen close hone par state automatically reset ho jati hai.
/// Memory leak nahi hoga.
///
/// Usage (UI mein):
///   final paginationState = ref.watch(studentPaginationProvider('tutor_abc'));
///   ref.read(studentPaginationProvider('tutor_abc').notifier).loadNextPage();
final studentPaginationProvider = AutoDisposeAsyncNotifierProviderFamily<
    StudentPaginationNotifier, StudentPaginationState, String>(
  StudentPaginationNotifier.new,
);
