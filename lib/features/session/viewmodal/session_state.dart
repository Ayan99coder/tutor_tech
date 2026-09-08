import 'package:tutor_tech/features/session/modal/session_modal.dart';
import 'package:tutor_tech/features/student/model/student_model.dart';
import 'package:tutor_tech/features/tutor/model/tutor_model.dart';

class SessionState {
  final List<TutorModel> tutors;
  final List<StudentModel> studentsBySubject;
  final bool isCreateSuccess;
  final String? createdSessionTitle;
  final List<SessionModel> sessionLists;

  const SessionState({
    this.sessionLists = const [],
    this.tutors = const [],
    this.createdSessionTitle,
    this.isCreateSuccess = false,
    this.studentsBySubject = const [],
  });

  SessionState copyWith({
    List<SessionModel>? sessionLists,
    List<TutorModel>? tutors,
    String? createdSessionTitle,
    bool? isCreateSuccess,
    List<StudentModel>? studentsBySubject,
  }) {
    return SessionState(
      sessionLists: sessionLists ?? this.sessionLists,
      tutors: tutors ?? this.tutors,
      createdSessionTitle: createdSessionTitle ?? this.createdSessionTitle,
      isCreateSuccess: isCreateSuccess ?? this.isCreateSuccess,
      studentsBySubject: studentsBySubject ?? this.studentsBySubject,
    );
  }
}
