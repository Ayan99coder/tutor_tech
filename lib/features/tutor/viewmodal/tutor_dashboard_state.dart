import '../../session/modal/session_model.dart';
import '../model/tutor_model.dart';

class TutorDashboardState {
  final bool isLoading;
  final TutorModel? tutor;
  final List<SessionModel> todaySessions;
  final List<SessionModel> upcomingSessions;
  final List<SessionModel> pendingReportSessions;
  final List<Map<String, String>> assignedStudents;
  final String? errorMessage;

  const TutorDashboardState({
    this.isLoading = false,
    this.tutor,
    this.todaySessions = const [],
    this.upcomingSessions = const [],
    this.pendingReportSessions = const [],
    this.assignedStudents = const [],
    this.errorMessage,
  });

  TutorDashboardState copyWith({
    bool? isLoading,
    TutorModel? tutor,
    List<SessionModel>? todaySessions,
    List<SessionModel>? upcomingSessions,
    List<SessionModel>? pendingReportSessions,
    List<Map<String, String>>? assignedStudents,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TutorDashboardState(
      isLoading: isLoading ?? this.isLoading,
      tutor: tutor ?? this.tutor,
      todaySessions: todaySessions ?? this.todaySessions,
      upcomingSessions: upcomingSessions ?? this.upcomingSessions,
      pendingReportSessions: pendingReportSessions ?? this.pendingReportSessions,
      assignedStudents: assignedStudents ?? this.assignedStudents,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}