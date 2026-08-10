import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutor_tech/features/tutor/model/tutor_model.dart';
import 'package:tutor_tech/features/tutor/model/tutor_repository.dart';

class TutorRepositoryImpl implements TutorRepository {
  FirebaseFirestore _firestore;

  TutorRepositoryImpl(this._firestore);

  Future<TutorModel?> getTutorById(String id) async {
    final tutorDoc = await _firestore.collection('tutor').doc(id).get();
    if (tutorDoc.exists && tutorDoc.data() != null) {
      return TutorModel.fromJson(tutorDoc.data()!);
    }
    return null;
  }

  Future<List<Map<String, String>>> getAssignedStudentsBasicInfo(
    String tutorId,
  ) async {
    final List<Map<String, String>> assignedStudent = [];
    final students = await _firestore
        .collection('student')
        .where('assigned_tutor_id', isEqualTo: tutorId)
        .get();
    for (var i in students.docs) {
      final data = i.data();
      final name =
          data['fullName'] as String? ??
          data['full_name'] as String? ??
          'Student';
      final subjects =
          (data['selectedSubjects'] as List?)?.join(', ').toUpperCase() ??
          'GCSE';
      final userId =
          data['userId'] as String? ?? data['user_id'] as String? ?? '';
      assignedStudent.add({
        'id': i.id,
        'user_id': userId,
        'name': name,
        'subject': subjects,
      });
    }
    return assignedStudent;
  }
}
