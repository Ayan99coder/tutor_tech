import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutor_tech/features/student/model/student_model.dart';

class StudentPaginationState {

  final List<StudentModel> students;
  final DocumentSnapshot? lastDocument;
  final bool hasMore;
  final bool isLoadingMore;

  const StudentPaginationState({
    this.students = const [],
    this.lastDocument,
    this.hasMore = true,
    this.isLoadingMore = false,
  });

  StudentPaginationState copyWith({
    List<StudentModel>? students,
    DocumentSnapshot? lastDocument,
    bool? hasMore,
    bool? isLoadingMore,
    bool clearCursor = false,
  }) {
    return StudentPaginationState(
      students: students ?? this.students,
      lastDocument: clearCursor ? null : (lastDocument ?? this.lastDocument),
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}
