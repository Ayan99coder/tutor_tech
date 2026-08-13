

import 'package:tutor_tech/features/group/modal/student_group_model.dart';

class StudentGroupState {
  final bool isLoading;
  final List<StudentGroupModel> groups;
  final String? errorMessage;

  const StudentGroupState({
    this.isLoading = false,
    this.groups = const [],
    this.errorMessage,
  });

  StudentGroupState copyWith({
    bool? isLoading,
    List<StudentGroupModel>? groups,
    String? errorMessage,
    bool clearError = false,
  }) {
    return StudentGroupState(
      isLoading: isLoading ?? this.isLoading,
      groups: groups ?? this.groups,
      errorMessage:
      clearError ? null : errorMessage ?? this.errorMessage,
    );
  }
}