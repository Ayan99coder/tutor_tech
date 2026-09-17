import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutor_tech/features/student/model/student_model.dart';
import 'package:tutor_tech/features/tutor/model/tutor_model.dart';

class TutorState {
  final TutorModel? tutor;

  // ── Legacy field (kept for compatibility) ──────────────────────────────────
  final List<StudentModel> stdByTutor;

  // ── Paginated students ─────────────────────────────────────────────────────
  /// All students loaded so far (accumulates across pages)
  final List<StudentModel> students;

  /// Firestore cursor — last document of the most recent page
  final DocumentSnapshot? lastDocument;

  /// Whether there are more pages to load from Firestore
  final bool hasMore;

  /// True while a next-page fetch is in progress
  final bool isLoadingMore;

  const TutorState({
    this.tutor,
    this.stdByTutor = const [],
    this.students = const [],
    this.lastDocument,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  TutorState copyWith({
    TutorModel? tutor,
    List<StudentModel>? stdByTutor,
    List<StudentModel>? students,
    DocumentSnapshot? lastDocument,
    bool? hasMore,
    bool? isLoadingMore,
    bool clearLastDocument = false,
  }) {
    return TutorState(
      tutor: tutor ?? this.tutor,
      stdByTutor: stdByTutor ?? this.stdByTutor,
      students: students ?? this.students,
      lastDocument: clearLastDocument ? null : (lastDocument ?? this.lastDocument),
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}
