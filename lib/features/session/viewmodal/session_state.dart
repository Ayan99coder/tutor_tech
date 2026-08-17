import '../modal/session_model.dart';

class SessionState {
  final bool isLoading;
  final List<SessionModel> sessions;
  final String? errorMessage;

  const SessionState({
    this.isLoading = false,
    this.sessions = const [],
    this.errorMessage,
  });

  SessionState copyWith({
    bool? isLoading,
    List<SessionModel>? sessions,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SessionState(
      isLoading: isLoading ?? this.isLoading,
      sessions: sessions ?? this.sessions,
      errorMessage:
      clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}