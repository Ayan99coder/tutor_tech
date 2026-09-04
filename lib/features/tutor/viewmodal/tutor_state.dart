import 'package:tutor_tech/features/tutor/model/tutor_model.dart';

class TutorState {
  final TutorModel? tutor;


  const TutorState({this.tutor,});

  TutorState copyWith({TutorModel? tutor, List<TutorModel>? tutors}) {
    return TutorState(
      tutor: tutor ?? this.tutor,

    );
  }
}
