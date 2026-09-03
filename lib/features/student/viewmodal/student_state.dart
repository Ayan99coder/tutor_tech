import 'package:tutor_tech/features/tutor/model/tutor_model.dart';

import '../model/student_model.dart';

class StudentState {
  final StudentModel? student;
  final List<TutorModel>? assignedTutors;

  const StudentState({this.student,this.assignedTutors});

  StudentState copyWith({
    StudentModel? student,
    List<TutorModel>? assignedTutors,
  }) {
    return StudentState(
      student: student ?? this.student,
      assignedTutors: assignedTutors ?? this.assignedTutors,
    );
  }
}
