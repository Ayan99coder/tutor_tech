import 'package:tutor_tech/features/student/model/student_model.dart';

import '../../session/modal/session_model.dart';
import '../../session/modal/session_report_model.dart';
import '../../tutor/model/tutor_model.dart';

class StudentDashboardState {
  final bool isLoading;
  final StudentModel? student;
  final TutorModel? assignedTutor;
  final List<SessionModel> upcomingSessions;
  final List<SessionReportModel> recentReports;
  final int unreadNotificationsCount;
  final String? errorMessage;

  const StudentDashboardState({
    this.isLoading = false,
    this.student,
    this.assignedTutor,
    this.upcomingSessions = const [],
    this.recentReports = const [],
    this.unreadNotificationsCount = 0,
    this.errorMessage,
  });

  StudentDashboardState copyWith({
    bool? isLoading,
    StudentModel? student,
    TutorModel? assignedTutor,
    List<SessionModel>? upcomingSessions,
    List<SessionReportModel>? recentReports,
    int? unreadNotificationsCount,
    String? errorMessage,
    bool clearError = false,
  }) {
    return StudentDashboardState(
      isLoading: isLoading ?? this.isLoading,
      student: student ?? this.student,
      assignedTutor: assignedTutor ?? this.assignedTutor,
      upcomingSessions: upcomingSessions ?? this.upcomingSessions,
      recentReports: recentReports ?? this.recentReports,
      unreadNotificationsCount: unreadNotificationsCount ?? this.unreadNotificationsCount,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}