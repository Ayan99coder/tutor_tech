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
    if (tutor.exists && tutor.data() != null) {
      return TutorModel.fromJson({...tutor.data()!, 'id': tutor.id});
    }
    return null;
  }

  @override
  Future<List<TutorModel>> getAllTutors() async {
    final snapshot = await _firestore.collection('tutors').get();
    return snapshot.docs
        .map((doc) => TutorModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  @override
  Future<List<StudentModel>> getStudentsByTutor(String tutorId) async {
    final tutorDoc = await _firestore.collection('tutors').doc(tutorId).get();
    if (!tutorDoc.exists) return [];

    final tutor = TutorModel.fromJson({...tutorDoc.data()!, 'id': tutorDoc.id});
    if (tutor.subjectExpertise.isEmpty) return [];

    final snap = await _firestore
        .collection('students')
        .where('selectedSubjects', arrayContainsAny: tutor.subjectExpertise)
        .get();

    return snap.docs
        .map((doc) => StudentModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  @override
  Future<TutorStudentsPage> getStudentsByTutorPaginated(
    String tutorId,
    List<String> subjectExpertise, {
    DocumentSnapshot? lastDocument,
    int limit = 5,
  }) async {
    if (subjectExpertise.isEmpty) {
      return const TutorStudentsPage(
        students: [],
        lastDocument: null,
        hasMore: false,
      );
    }

    final subjects = subjectExpertise.take(30).toList();

    var query = _firestore
        .collection('students')
        .where('selectedSubjects', arrayContainsAny: subjects)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snap = await query.get();

    return TutorStudentsPage(
      students: snap.docs
          .map((doc) => StudentModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList(),
      lastDocument: snap.docs.isNotEmpty ? snap.docs.last : null,
      hasMore: snap.docs.length == limit,
    );
  }
}
