import '../model/student_model.dart';

class StudentState {
  final StudentModel? student;

  const StudentState({this.student});

  StudentState copyWith({StudentModel? student}) {
    return StudentState(student: student ?? this.student);
  }
}
