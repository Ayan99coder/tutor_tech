import 'package:tutor_tech/features/student/model/student_model.dart';
import 'package:tutor_tech/features/tutor/model/tutor_model.dart';

class TutorState {
  final TutorModel? tutor;
  final List<StudentModel> stdByTutor;

  const TutorState({this.tutor, this.stdByTutor = const []});

  TutorState copyWith({
    TutorModel? tutor,
    List<TutorModel>? tutors,
    List<StudentModel>? stdByTutor,
  }) {
    return TutorState(
      tutor: tutor ?? this.tutor,
      stdByTutor: stdByTutor ?? this.stdByTutor,
    );
  }
}
