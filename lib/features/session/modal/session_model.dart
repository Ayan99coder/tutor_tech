import '../../student/model/student_model.dart';

enum SessionStatus {
  scheduled,
  inProgress,
  completed,
  cancelled,
  noShow,
}
enum ClassroomPlatform { zoom, googleClassroom }
class SessionModel {
  final String id;
  final String tutorId;
  final String studentId;
  final String subject;
  final String level;
  final GroupSize groupSize;
  final DateTime scheduledAt;
  final int durationMinutes;
  final String zoomLink;
  final DateTime? zoomConfirmedAt;
  final String? zoomConfirmedByAdminId;
  final SessionStatus sessionStatus;
  final bool reportSubmitted;
  final DateTime? reportSubmittedAt;
  final DateTime createdAt;
  final String? tutorName;
  final String? studentName;
  final String? notes;

  // ── Attendance Tracking (F3) ──────────────────────────────────
  /// Whether the tutor conducted / attended this session.
  final bool? tutorAttended;
  /// Whether the student joined / attended this session.
  final bool? studentAttended;
  /// Reason for no-show (tutor or student).
  final String? noShowReason;
  /// Timestamp when the tutor first joined the Zoom session.
  final DateTime? tutorJoinedAt;
  /// Timestamp when the session was officially ended / marked complete.
  final DateTime? sessionEndedAt;

  const SessionModel({
    required this.id,
    required this.tutorId,
    required this.studentId,
    required this.subject,
    required this.level,
    required this.groupSize,
    required this.scheduledAt,
    this.durationMinutes = 60,
    required this.zoomLink,
    this.zoomConfirmedAt,
    this.zoomConfirmedByAdminId,
    this.sessionStatus = SessionStatus.scheduled,
    this.reportSubmitted = false,
    this.reportSubmittedAt,
    required this.createdAt,
    this.tutorName,
    this.studentName,
    this.notes,
    this.tutorAttended,
    this.studentAttended,
    this.noShowReason,
    this.tutorJoinedAt,
    this.sessionEndedAt,
  });

  SessionModel copyWith({
    String? id,
    String? tutorId,
    String? studentId,
    String? subject,
    String? level,
    GroupSize? groupSize,
    DateTime? scheduledAt,
    int? durationMinutes,
    String? zoomLink,
    DateTime? zoomConfirmedAt,
    String? zoomConfirmedByAdminId,
    SessionStatus? sessionStatus,
    bool? reportSubmitted,
    DateTime? reportSubmittedAt,
    DateTime? createdAt,
    String? tutorName,
    String? studentName,
    String? notes,
    bool? tutorAttended,
    bool? studentAttended,
    String? noShowReason,
    DateTime? tutorJoinedAt,
    DateTime? sessionEndedAt,
  }) {
    return SessionModel(
      id: id ?? this.id,
      tutorId: tutorId ?? this.tutorId,
      studentId: studentId ?? this.studentId,
      subject: subject ?? this.subject,
      level: level ?? this.level,
      groupSize: groupSize ?? this.groupSize,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      zoomLink: zoomLink ?? this.zoomLink,
      zoomConfirmedAt: zoomConfirmedAt ?? this.zoomConfirmedAt,
      zoomConfirmedByAdminId: zoomConfirmedByAdminId ?? this.zoomConfirmedByAdminId,
      sessionStatus: sessionStatus ?? this.sessionStatus,
      reportSubmitted: reportSubmitted ?? this.reportSubmitted,
      reportSubmittedAt: reportSubmittedAt ?? this.reportSubmittedAt,
      createdAt: createdAt ?? this.createdAt,
      tutorName: tutorName ?? this.tutorName,
      studentName: studentName ?? this.studentName,
      notes: notes ?? this.notes,
      tutorAttended: tutorAttended ?? this.tutorAttended,
      studentAttended: studentAttended ?? this.studentAttended,
      noShowReason: noShowReason ?? this.noShowReason,
      tutorJoinedAt: tutorJoinedAt ?? this.tutorJoinedAt,
      sessionEndedAt: sessionEndedAt ?? this.sessionEndedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tutor_id': tutorId,
      'tutor_name': tutorName,
      'student_id': studentId,
      'student_name': studentName,
      'subject': subject,
      'level': level,
      'group_size': groupSize.name,
      'scheduled_at': scheduledAt.toIso8601String(),
      'duration_minutes': durationMinutes,
      'zoom_link': zoomLink,
      'zoom_confirmed_at': zoomConfirmedAt?.toIso8601String(),
      'zoom_confirmed_by_admin_id': zoomConfirmedByAdminId,
      'session_status': sessionStatus.name,
      'report_submitted': reportSubmitted,
      'report_submitted_at': reportSubmittedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'notes': notes,
      'tutor_attended': tutorAttended,
      'student_attended': studentAttended,
      'no_show_reason': noShowReason,
      'tutor_joined_at': tutorJoinedAt?.toIso8601String(),
      'session_ended_at': sessionEndedAt?.toIso8601String(),
    };
  }

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] as String,
      tutorId: json['tutor_id'] as String? ?? json['tutorId'] as String? ?? '',
      studentId: json['student_id'] as String? ?? json['studentId'] as String? ?? '',
      subject: json['subject'] as String? ?? '',
      level: json['level'] as String? ?? '',
      groupSize: GroupSize.values.firstWhere(
        (e) => e.name == json['group_size'] || e.name == json['groupSize'],
        orElse: () => GroupSize.oneToOne,
      ),
      scheduledAt: json['scheduled_at'] != null
          ? DateTime.parse(json['scheduled_at'] as String)
          : DateTime.now(),
      durationMinutes: json['duration_minutes'] as int? ?? json['durationMinutes'] as int? ?? 60,
      zoomLink: json['zoom_link'] as String? ?? json['zoomLink'] as String? ?? '',
      zoomConfirmedAt: json['zoom_confirmed_at'] != null
          ? DateTime.parse(json['zoom_confirmed_at'] as String)
          : null,
      zoomConfirmedByAdminId: json['zoom_confirmed_by_admin_id'] as String? ?? json['zoomConfirmedByAdminId'] as String?,
      sessionStatus: SessionStatus.values.firstWhere(
        (e) => e.name == json['session_status'] || e.name == json['sessionStatus'],
        orElse: () => SessionStatus.scheduled,
      ),
      reportSubmitted: json['report_submitted'] as bool? ?? json['reportSubmitted'] as bool? ?? false,
      reportSubmittedAt: json['report_submitted_at'] != null
          ? DateTime.parse(json['report_submitted_at'] as String)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      tutorName: json['tutor_name'] as String? ?? json['tutorName'] as String?,
      studentName: json['student_name'] as String? ?? json['studentName'] as String?,
      notes: json['notes'] as String?,
      tutorAttended: json['tutor_attended'] as bool?,
      studentAttended: json['student_attended'] as bool?,
      noShowReason: json['no_show_reason'] as String?,
      tutorJoinedAt: json['tutor_joined_at'] != null
          ? DateTime.parse(json['tutor_joined_at'] as String)
          : null,
      sessionEndedAt: json['session_ended_at'] != null
          ? DateTime.parse(json['session_ended_at'] as String)
          : null,
    );
  }
}
