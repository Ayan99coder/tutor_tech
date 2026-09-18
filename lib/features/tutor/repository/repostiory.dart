import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutor_tech/features/student/model/student_model.dart';
import 'package:tutor_tech/features/tutor/model/tutor_model.dart';

/// Result object for tutor-side subject-based student queries (legacy).
/// Renamed from StudentsPage to avoid conflict with student repository's StudentsPage.
class TutorStudentsPage {
  final List<StudentModel> students;
  final DocumentSnapshot? lastDocument;
  final bool hasMore;

  const TutorStudentsPage({
    required this.students,
    required this.lastDocument,
    required this.hasMore,
  });
}

abstract class TutorRepository {
  Future<TutorModel?> getTutorById(String id);

  Future<List<TutorModel>?> getAllTutors();

  /// Legacy: fetch all students at once (kept for compatibility)
  Future<List<StudentModel>> getStudentsByTutor(String id);

  /// Paginated: fetch [limit] students after [lastDocument] cursor (subject-based)
  Future<TutorStudentsPage> getStudentsByTutorPaginated(
    String tutorId,
    List<String> subjectExpertise, {
    DocumentSnapshot? lastDocument,
    int limit = 5,
  });
}

