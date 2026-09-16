import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutor_tech/features/tutor/model/tutor_model.dart';
import 'package:tutor_tech/features/tutor/repository/repostiory.dart';

import '../../student/model/student_model.dart';

class TutorRepositoryImpl implements TutorRepository {
  final FirebaseFirestore _firestore;

  TutorRepositoryImpl(this._firestore);

  @override
  Future<TutorModel?> getTutorById(String id) async {
    final tutor = await _firestore.collection('tutors').doc(id).get();
    if(tutor.exists && tutor.data() != null){
      return TutorModel.fromJson(tutor.data()!);
    }
    return null;
  }
  @override
  Future<List<TutorModel>> getAllTutors() async {
    final snapshot = await _firestore.collection('tutors').get();

    return snapshot.docs
        .map((doc) => TutorModel.fromJson(doc.data()))
        .toList();
  }
  @override
  Future<List<StudentModel>> getStudentsByTutor(String tutorId) async {
    final tutorDoc = await FirebaseFirestore.instance
        .collection('tutors')
        .doc(tutorId)
        .get();

    if (!tutorDoc.exists) return [];

    final tutor = TutorModel.fromJson({
      ...tutorDoc.data()!,
      'id': tutorDoc.id,
    });

    if (tutor.subjectExpertise.isEmpty) return [];

    final studentsSnapshot = await FirebaseFirestore.instance
        .collection('students')
        .where(
      'selectedSubjects',
      arrayContainsAny: tutor.subjectExpertise,
    )
        .get();

    return studentsSnapshot.docs.map((doc) {
      return StudentModel.fromJson({
        ...doc.data(),
        'id': doc.id,
      });
    }).toList();
  }
}
