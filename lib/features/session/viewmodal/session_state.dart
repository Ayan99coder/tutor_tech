import '../modal/session_model.dart';


class SessionState {
  final bool isLoading;
  final List<SessionModel> sessions;
  final List<SessionModel> upcomingSessions;
  final SessionModel? selectedSession;
  final String? errorMessage;
  final bool isConfirmingZoom;
  final bool zoomConfirmSuccess;

  const SessionState({
    this.isLoading = false,
    this.sessions = const [],
    this.upcomingSessions = const [],
    this.selectedSession,
    this.errorMessage,
    this.isConfirmingZoom = false,
    this.zoomConfirmSuccess = false,
  });

  SessionState copyWith({
    bool? isLoading,
    List<SessionModel>? sessions,
    List<SessionModel>? upcomingSessions,
    SessionModel? selectedSession,
    String? errorMessage,
    bool? isConfirmingZoom,
    bool? zoomConfirmSuccess,
    bool clearError = false,
  }) {
    return SessionState(
      isLoading: isLoading ?? this.isLoading,
      sessions: sessions ?? this.sessions,
      upcomingSessions: upcomingSessions ?? this.upcomingSessions,
      selectedSession: selectedSession ?? this.selectedSession,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isConfirmingZoom: isConfirmingZoom ?? this.isConfirmingZoom,
      zoomConfirmSuccess: zoomConfirmSuccess ?? this.zoomConfirmSuccess,
    );
  }
}
