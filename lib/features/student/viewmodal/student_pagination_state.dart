import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutor_tech/features/student/model/student_model.dart';

/// Tutor ke students ki pagination ka poora state yahan store hota hai.
///
/// Har variable ka role:
///   [students]      => Ab tak load hue saare students (accumulates across pages)
///   [lastDocument]  => Firestore cursor -- agli page yahan se shuru hogi
///   [hasMore]       => false hone par scroll listener ruk jata hai
///   [isLoadingMore] => true hone par duplicate requests block hoti hain
class StudentPaginationState {
  /// Ab tak load hue saare students.
  /// Har naye page ke baad expand hota hai: [...old, ...new]
  final List<StudentModel> students;

  /// Firestore cursor.
  /// - null  => pehla page (startAfterDocument skip hoga)
  /// - value => is document ke BAAD se next page aayega
  final DocumentSnapshot? lastDocument;

  /// Kya Firestore mein aur data baaki hai?
  /// Logic: milne wale docs < limit => hasMore = false
  final bool hasMore;

  /// Kya abhi next page fetch ho rahi hai?
  /// Guard: duplicate scroll events par duplicate requests nahi jayengi.
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
      // clearCursor = true tab use karo jab full refresh chahiye
      lastDocument: clearCursor ? null : (lastDocument ?? this.lastDocument),
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}
