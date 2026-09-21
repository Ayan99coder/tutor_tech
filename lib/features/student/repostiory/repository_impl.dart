import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutor_tech/features/student/model/student_model.dart';
import 'package:tutor_tech/features/student/repostiory/repository.dart';
import 'package:tutor_tech/features/tutor/model/tutor_model.dart';
import 'package:tutor_tech/features/tutor/repository/repostiory.dart';

class StudentRepositoryImpl implements StudentRepository {
  final FirebaseFirestore _firestore;
  final TutorRepository _tutorRepository;

  StudentRepositoryImpl(this._firestore, this._tutorRepository);
  @override
  Future<StudentModel?> getStudentById(String id) async {
    final user = await _firestore.collection('students').doc(id).get();
    if (user.exists && user.data() != null) {
      return StudentModel.fromJson({...user.data()!, 'id': user.id});
    }
    return null;
  }


  @override
  Future<List<TutorModel>> getAssignedTutors(String id) async {
    final student = await getStudentById(id);

    if (student == null) {
      return [];
    }

    final tutors = await _tutorRepository.getAllTutors();
    if (tutors == null) {
      return [];
    }
    return tutors
        .where(
          (tutor) => tutor.subjectExpertise.any(
            (subject) => student.selectedSubjects.contains(subject),
          ),
        )
        .toList();
  }

  @override
  Future<StudentsPage> getStudentsByTutorPaginated(
    String tutorId, {
    DocumentSnapshot? lastDocument,
    int limit = 20,
  }) async {

    var query = _firestore
        .collection('students')
        .where('tutorId', isEqualTo: tutorId)
        .orderBy('createdAt', descending: true)
        .limit(limit);
    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final snap = await query.get();

    return StudentsPage(
      students: snap.docs
          .map((doc) => StudentModel.fromJson({...doc.data(), 'id': doc.id}))
          .toList(),


      lastDocument: snap.docs.isNotEmpty ? snap.docs.last : null,

      hasMore: snap.docs.length == limit,
    );
  }
  @override
  Future<void> assignTutorToStudent({
    required String studentId,
    required String tutorId,
  }) async {
    await _firestore.collection('students').doc(studentId).update({
      'tutorId': tutorId,
    });
  }
}

