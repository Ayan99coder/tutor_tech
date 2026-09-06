import 'package:tutor_tech/features/student/model/student_model.dart';
import 'package:tutor_tech/features/tutor/model/tutor_model.dart';

class SessionState {
  final List<TutorModel> tutors;
  final List<StudentModel> studentsBySubject;

  const SessionState({
    this.tutors = const [],
    this.studentsBySubject = const [],
  });

  SessionState copyWith({
    List<TutorModel>? tutors,
    List<StudentModel>? studentsBySubject,
  }) {
    return SessionState(
      tutors: tutors ?? this.tutors,
      studentsBySubject: studentsBySubject ?? this.studentsBySubject,
    );
  }
}
