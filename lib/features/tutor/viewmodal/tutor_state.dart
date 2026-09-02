import 'package:tutor_tech/features/tutor/model/tutor_model.dart';

class TutorState {
  final TutorModel? tutor;
  final String? errorMessage;
  final bool isLoading;

  const TutorState({
    this.tutor,
    this.errorMessage,
    this.isLoading = false,
  });

  TutorState copyWith({
    TutorModel? tutor,
    String? errorMessage,
    bool? isLoading,
    bool clearError = false,
  }) {
    return TutorState(
      tutor: tutor ?? this.tutor,
      errorMessage: clearError
          ? null
          : errorMessage ?? this.errorMessage,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}