import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutor_tech/features/session/modal/session_modal.dart';
import 'package:tutor_tech/features/session/repository/session_repo.dart';
import 'package:tutor_tech/features/tutor/model/tutor_model.dart';
import 'package:tutor_tech/features/tutor/repository/repostiory.dart';

import '../../student/model/student_model.dart';

class SessionRepoImpl implements SessionRepo {
  final TutorRepository repo;
  final FirebaseFirestore _firestore;

  SessionRepoImpl(this.repo, this._firestore);

  @override
  Future<List<TutorModel>?> getTutorsBySubject(String subject) async {
    final tutors = await repo.getAllTutors();

    final normalizedSubject = subject.trim().toLowerCase();

    final filteredTutors = tutors?.where((tutor) {
      return tutor.subjectExpertise.any(
        (sbj) => sbj.trim().toLowerCase() == normalizedSubject,
      );
    }).toList();

    if (filteredTutors == null || filteredTutors.isEmpty) {
      return tutors;
    }

    return filteredTutors;
  }

  @override
  Future<List<StudentModel>>? getStudentBySubject(String subject) async {
    final snapshot = await _firestore
        .collection('students')
        .where('selectedSubjects', arrayContains: subject)
        .get();

    return snapshot.docs
        .map((doc) => StudentModel.fromJson(doc.data()))
        .toList();
  }

  @override
  Future<SessionModel> createSession(SessionModel session) async {
    final docRef = _firestore.collection('sessions').doc();

    await docRef.set({...session.toJson(), 'id': docRef.id});
    return session.copyWith(id: docRef.id);
  }
@override
  Stream<List<SessionModel>> watchSessions() {
    return _firestore.collection('sessions').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => SessionModel.fromJson(doc.data()))
          .toList();
    });
  }
  @override
  Stream<List<SessionModel>> watchStudentSessions(String studentId) {
    return _firestore
        .collection('sessions')
        .where('studentIds', arrayContains: studentId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map((doc) => SessionModel.fromJson(doc.data()))
          .toList(),
    );
  }
  @override
  Stream<List<SessionModel>> watchTutorSessions(String tutorId) {
    return _firestore
        .collection('sessions')
        .where('tutorId', isEqualTo: tutorId)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
          .map((doc) => SessionModel.fromJson(doc.data()))
          .toList(),
    );
  }
}
