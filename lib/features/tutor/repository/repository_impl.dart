import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutor_tech/features/tutor/model/tutor_model.dart';
import 'package:tutor_tech/features/tutor/repository/repostiory.dart';

import '../../student/model/student_model.dart';

class TutorRepositoryImpl implements TutorRepository {
  final FirebaseFirestore _firestore;

  TutorRepositoryImpl(this._firestore);

  // ── Basic fetch ──────────────────────────────────────────────────────────
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

  // ── Legacy (all-at-once) ─────────────────────────────────────────────────
  @override
  Future<List<StudentModel>> getStudentsByTutor(String tutorId) async {
    final tutorDoc =
        await _firestore.collection('tutors').doc(tutorId).get();
    if (!tutorDoc.exists) return [];

    final tutor = TutorModel.fromJson({...tutorDoc.data()!, 'id': tutorDoc.id});
    if (tutor.subjectExpertise.isEmpty) return [];

    final snap = await _firestore
        .collection('students')
        .where('selectedSubjects',
            arrayContainsAny: tutor.subjectExpertise)
        .get();

    return snap.docs
        .map((doc) => StudentModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();
  }

  // ── Server-side paginated fetch ──────────────────────────────────────────
  @override
  Future<StudentsPage> getStudentsByTutorPaginated(
    String tutorId,
    List<String> subjectExpertise, {
    DocumentSnapshot? lastDocument,
    int limit = 5,
  }) async {
    if (subjectExpertise.isEmpty) {
      return const StudentsPage(
        students: [],
        lastDocument: null,
        hasMore: false,
      );
    }

    // Firestore arrayContainsAny supports max 30 items; slice if needed
    final subjects = subjectExpertise.take(30).toList();

    // Build base query: order by createdAt for stable cursor pagination
    var query = _firestore
        .collection('students')
        .where('selectedSubjects', arrayContainsAny: subjects)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    // Apply cursor if we have a previous last document
    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snap = await query.get();

    final students = snap.docs
        .map((doc) => StudentModel.fromJson({...doc.data(), 'id': doc.id}))
        .toList();

    return StudentsPage(
      students: students,
      lastDocument: snap.docs.isNotEmpty ? snap.docs.last : null,
      hasMore: snap.docs.length == limit, // fewer docs than limit → no more pages
    );
  }
}
