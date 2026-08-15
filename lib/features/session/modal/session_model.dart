enum SessionStatus {
  scheduled,
  inProgress,
  completed,
  cancelled,
  noShow,
}

class SessionModel {
  final String id;
  final String tutorId;
  final String studentId;
  final String subject;
  final DateTime scheduledAt;
  final int durationMinutes;
  final String zoomLink;
  final SessionStatus status;
  final DateTime createdAt;

  const SessionModel({
    required this.id,
    required this.tutorId,
    required this.studentId,
    required this.subject,
    required this.scheduledAt,
    required this.durationMinutes,
    required this.zoomLink,
    required this.status,
    required this.createdAt,
  });
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tutor_id': tutorId,
      'student_id': studentId,
      'subject': subject,
      'scheduled_at': scheduledAt.toIso8601String(),
      'duration_minutes': durationMinutes,
      'zoom_link': zoomLink,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
    };
  }
  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'],
      tutorId: json['tutor_id'],
      studentId: json['student_id'],
      subject: json['subject'],
      scheduledAt: DateTime.parse(json['scheduled_at']),
      durationMinutes: json['duration_minutes'],
      zoomLink: json['zoom_link'],
      status: SessionStatus.values.firstWhere(
            (e) => e.name == json['status'],
      ),
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
