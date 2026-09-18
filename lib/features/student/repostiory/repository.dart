import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutor_tech/features/student/model/student_model.dart';
import 'package:tutor_tech/features/tutor/model/tutor_model.dart';

// ── Pagination result object ────────────────────────────────────────────────
/// Har page fetch ke baad yeh object return hota hai.
///
/// [students]     → Is page ke students (20 items)
/// [lastDocument] → Firestore cursor (next page ke liye)
/// [hasMore]      → Kya aur pages baaki hain?
class StudentsPage {
  final List<StudentModel> students;

  /// Firestore ka internal cursor — next page yahan se shuru hoga.
  /// null agar koi document nahi aaya.
  final DocumentSnapshot? lastDocument;

  /// true  → aur data hai (fetch karte raho)
  /// false → sab load ho gaya (stop karo)
  final bool hasMore;

  const StudentsPage({
    required this.students,
    required this.lastDocument,
    required this.hasMore,
  });
}

// ── Repository interface ────────────────────────────────────────────────────
abstract class StudentRepository {
  Future<StudentModel?> getStudentById(String id);
  Future<List<TutorModel>> getAssignedTutors(String id);

  /// Cursor-based paginated fetch — NO composite index required!
  ///
  /// Query used:
  ///   .where('tutorId', isEqualTo: tutorId)
  ///   .orderBy('createdAt', descending: true)
  ///   .limit(limit)
  ///   .startAfterDocument(lastDocument) // sirf next pages ke liye
  Future<StudentsPage> getStudentsByTutorPaginated(
    String tutorId, {
    DocumentSnapshot? lastDocument, // null = pehla page
    int limit = 20,
  });

  /// Kisi student ko tutor assign karo (tutorId field set karo)
  Future<void> assignTutorToStudent({
    required String studentId,
    required String tutorId,
  });
}