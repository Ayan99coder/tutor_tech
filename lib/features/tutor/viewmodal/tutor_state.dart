import 'package:tutor_tech/features/student/model/student_model.dart';
import 'package:tutor_tech/features/tutor/model/tutor_model.dart';

/// Sirf tutor ki profile aur legacy stdByTutor rakhta hai.
/// Students ki pagination ab StudentPaginationNotifier handle karta hai.
class TutorState {
  final TutorModel? tutor;

  // ── Legacy field (kept for session card compatibility) ─────────────────
  final List<StudentModel> stdByTutor;

  const TutorState({
    this.tutor,
    this.stdByTutor = const [],
  });

  TutorState copyWith({
    TutorModel? tutor,
    List<StudentModel>? stdByTutor,
  }) {
    return TutorState(
      tutor: tutor ?? this.tutor,
      stdByTutor: stdByTutor ?? this.stdByTutor,
    );
  }
}

