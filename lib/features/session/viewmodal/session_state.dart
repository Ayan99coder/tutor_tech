import 'package:tutor_tech/features/student/model/student_model.dart';
import 'package:tutor_tech/features/tutor/model/tutor_model.dart';

class SessionState {
  final List<TutorModel> tutors;
  final List<StudentModel> studentsBySubject;
  final bool isCreateSuccess;

  const SessionState({
    this.tutors = const [],
    this.isCreateSuccess = false,
    this.studentsBySubject = const [],
  });

  SessionState copyWith({
    List<TutorModel>? tutors,
    bool? isCreateSuccess,
    List<StudentModel>? studentsBySubject,
  }) {
    return SessionState(
      tutors: tutors ?? this.tutors,
      isCreateSuccess: isCreateSuccess ?? this.isCreateSuccess,
      studentsBySubject: studentsBySubject ?? this.studentsBySubject,
    );
  }
}
