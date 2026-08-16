import '../../student/model/student_model.dart';
import '../../tutor/model/tutor_model.dart';

class AdminState {
  final List<TutorModel> filteredTutors;
  final List<StudentModel> filteredStudents;
  final bool isLoading;
  final String? errorMessage;

  const AdminState({
    this.filteredTutors = const [],
    this.filteredStudents = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  AdminState copyWith({
    List<TutorModel>? filteredTutors,
    List<StudentModel>? filteredStudents,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return AdminState(
      filteredTutors: filteredTutors ?? this.filteredTutors,
      filteredStudents: filteredStudents ?? this.filteredStudents,
      isLoading: isLoading ?? this.isLoading,
      errorMessage:
      clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}