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
      return StudentModel.fromJson(user.data()!);
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

}
