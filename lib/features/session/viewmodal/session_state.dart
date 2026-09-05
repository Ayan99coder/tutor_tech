
import 'package:tutor_tech/features/tutor/model/tutor_model.dart';

class SessionState {
  final List<TutorModel> tutors;

  const SessionState({
    this.tutors = const [],
  });

  SessionState copyWith({
    List<TutorModel>? tutors,
  }) {
    return SessionState(
      tutors: tutors ?? this.tutors,
    );
  }
}