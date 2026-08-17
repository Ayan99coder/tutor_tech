enum SessionStatus { scheduled, inProgress, completed, cancelled, noShow }

enum AudienceType { public, specific, groups }

enum ClassroomPlatform { zoom, googleClassroom }

class SessionModel {
  final String id;

  // Basic session information
  final String title;
  final String subject;

  // Tutor
  final String tutorId;

  // Student
  // Har student ke liye individual session document mein ye ID hogi.
  final String studentId;

  // Classroom
  final ClassroomPlatform platform;
  final String meetingUrl;

  // Schedule
  final DateTime scheduledAt;
  final int durationMinutes;

  // Audience targeting
  final AudienceType audienceType;
  final List<String> targetStudentIds;
  final List<String> targetGroupIds;

  // Session status
  final SessionStatus status;

  // Optional admin notes
  final String? notes;

  final DateTime createdAt;

  const SessionModel({
    required this.id,
    required this.title,
    required this.subject,
    required this.tutorId,
    required this.studentId,
    required this.platform,
    required this.meetingUrl,
    required this.scheduledAt,
    required this.durationMinutes,
    required this.audienceType,
    this.targetStudentIds = const [],
    this.targetGroupIds = const [],
    this.status = SessionStatus.scheduled,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'subject': subject,
      'tutor_id': tutorId,
      'student_id': studentId,
      'platform': platform.name,
      'meeting_url': meetingUrl,
      'scheduled_at': scheduledAt.toIso8601String(),
      'duration_minutes': durationMinutes,
      'audience_type': audienceType.name,
      'target_student_ids': targetStudentIds,
      'target_group_ids': targetGroupIds,
      'status': status.name,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] as String? ?? '',

      title: json['title'] as String? ?? '',

      subject: json['subject'] as String? ?? '',

      tutorId: json['tutor_id'] as String? ?? '',

      studentId: json['student_id'] as String? ?? '',

      platform: ClassroomPlatform.values.firstWhere(
        (e) => e.name == json['platform'],
        orElse: () => ClassroomPlatform.zoom,
      ),

      meetingUrl: json['meeting_url'] as String? ?? '',

      scheduledAt: json['scheduled_at'] != null
          ? DateTime.parse(json['scheduled_at'] as String)
          : DateTime.now(),

      durationMinutes: json['duration_minutes'] as int? ?? 60,

      audienceType: AudienceType.values.firstWhere(
        (e) => e.name == json['audience_type'],
        orElse: () => AudienceType.public,
      ),

      targetStudentIds: List<String>.from(json['target_student_ids'] ?? []),

      targetGroupIds: List<String>.from(json['target_group_ids'] ?? []),

      status: SessionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SessionStatus.scheduled,
      ),

      notes: json['notes'] as String?,

      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }
}
