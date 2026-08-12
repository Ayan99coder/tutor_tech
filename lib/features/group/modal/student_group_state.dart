import 'package:tutor_tech/features/group/modal/student_group_model.dart';

class StudentGroupState {
  final bool isLoading;
  final bool isSaving;
  final bool isCreating;

  final List<StudentGroupModel> groups;
  final List<StudentGroupStudentModel> students;

  final Set<String> selectedStudentIds;

  final String? errorMessage;

  const StudentGroupState({
    this.isLoading = false,
    this.isSaving = false,
    this.isCreating = false,
    this.groups = const [],
    this.students = const [],
    this.selectedStudentIds = const {},
    this.errorMessage,
  });

  StudentGroupState copyWith({
    bool? isLoading,
    bool? isSaving,
    bool? isCreating,
    List<StudentGroupModel>? groups,
    List<StudentGroupStudentModel>? students,
    Set<String>? selectedStudentIds,
    String? errorMessage,
    bool clearError = false,
  }) {
    return StudentGroupState(
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isCreating: isCreating ?? this.isCreating,
      groups: groups ?? this.groups,
      students: students ?? this.students,
      selectedStudentIds: selectedStudentIds ?? this.selectedStudentIds,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}
