import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutor_tech/features/student/model/student_model.dart';
import 'package:tutor_tech/features/tutor/model/tutor_model.dart';
class StudentsPage {
  final List<StudentModel> students;

  final DocumentSnapshot? lastDocument;
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
  Future<StudentsPage> getStudentsByTutorPaginated(
    String tutorId, {
    DocumentSnapshot? lastDocument,
    int limit = 20,
  });
  Future<void> assignTutorToStudent({
    required String studentId,
    required String tutorId,
  });
}
