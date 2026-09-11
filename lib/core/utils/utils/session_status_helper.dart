import '../../../features/session/modal/session_modal.dart';


SessionStatus calculateSessionStatus(SessionModel session) {
  final now = DateTime.now();

  final startTime = session.scheduledAt;

  final endTime = startTime.add(
    const Duration(minutes: 90),
  );

  if (now.isBefore(startTime)) {
    return SessionStatus.scheduled;
  }

  if (now.isBefore(endTime)) {
    return SessionStatus.inProgress;
  }

  return SessionStatus.completed;
}