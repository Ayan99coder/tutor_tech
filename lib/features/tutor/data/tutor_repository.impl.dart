import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutor_tech/features/tutor/model/tutor_model.dart';
import 'package:tutor_tech/features/tutor/model/tutor_repository.dart';

import '../../student/model/student_model.dart';

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

  @override
  Stream<List<StudentModel>> watchAssignedStudents(String tutorId) {
    return _firestore
        .collection('students')
        .where('tutorId', isEqualTo: tutorId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => StudentModel.fromJson(doc.data()))
              .toList(),
        );
  }
}
