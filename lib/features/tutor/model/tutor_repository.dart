import 'package:tutor_tech/features/parent/model/parent_model.dart';
import 'package:tutor_tech/features/student/model/student_model.dart';
import 'package:tutor_tech/features/tutor/model/tutor_model.dart';

abstract class TutorRepository {
Future<TutorModel?> getTutorById(String id);
Stream<List<StudentModel>> watchAssignedStudents(
    String tutorId,
    );
Future<List<TutorModel>> getAllTutors();
}
class StudentWithParent {
  final StudentModel student;
  final ParentModel? parent;
  final bool isActive;
  final String applicationStatus;

  const StudentWithParent({
    required this.student,
    this.parent,
    required this.isActive,
    required this.applicationStatus,
  });
}