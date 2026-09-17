import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutor_tech/features/student/model/student_model.dart';
import 'package:tutor_tech/features/tutor/model/tutor_model.dart';

/// Result object returned by paginated student queries
class StudentsPage {
  final List<StudentModel> students;

  /// The last Firestore document — used as a cursor for the next page
  final DocumentSnapshot? lastDocument;

  /// False when the returned batch is smaller than [limit] (no more data)
  final bool hasMore;

  const StudentsPage({
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

  /// Paginated: fetch [limit] students after [lastDocument] cursor
  Future<StudentsPage> getStudentsByTutorPaginated(
    String tutorId,
    List<String> subjectExpertise, {
    DocumentSnapshot? lastDocument,
    int limit = 5,
  });
}
