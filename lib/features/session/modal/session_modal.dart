import 'package:cloud_firestore/cloud_firestore.dart';

enum ClassroomPlatform {
  zoom,
  googleClassroom,
}

enum AudienceScope {
  public,
  specificStudent,
  studentGroup,
}

enum SessionStatus {
  scheduled,
  inProgress,
  completed,
  cancelled,
  noShow,
}

class SessionModel {
  final String id;
  final String title;
  final String tutorId;
  final List<String> studentIds;
  final String subject;
  final String? level;
  final int durationMinutes;
  final int groupSize;
  final AudienceScope audienceScope;
  final ClassroomPlatform platform;
  final String meetingLink;
  final DateTime scheduledAt;
  final String? notes;
  final DateTime createdAt;
  final SessionStatus sessionStatus;

  const SessionModel({
    required this.id,
    required this.title,
    required this.tutorId,
    required this.studentIds,
    required this.subject,
    this.level,
    this.durationMinutes = 60,
    required this.groupSize,
    required this.audienceScope,
    required this.platform,
    required this.meetingLink,
    required this.scheduledAt,
    this.notes,
    required this.createdAt,
    required this.sessionStatus,
  });

  SessionModel copyWith({
    String? id,
    String? title,
    String? tutorId,
    List<String>? studentIds,
    String? subject,
    String? level,
    int? durationMinutes,
    int? groupSize,
    AudienceScope? audienceScope,
    ClassroomPlatform? platform,
    String? meetingLink,
    DateTime? scheduledAt,
    String? notes,
    DateTime? createdAt,
    SessionStatus? sessionStatus,
  }) {
    return SessionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      tutorId: tutorId ?? this.tutorId,
      studentIds: studentIds ?? this.studentIds,
      subject: subject ?? this.subject,
      level: level ?? this.level,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      groupSize: groupSize ?? this.groupSize,
      audienceScope: audienceScope ?? this.audienceScope,
      platform: platform ?? this.platform,
      meetingLink: meetingLink ?? this.meetingLink,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      sessionStatus: sessionStatus ?? this.sessionStatus,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'tutorId': tutorId,
      'studentIds': studentIds,
      'subject': subject,
      'level': level,
      'durationMinutes': durationMinutes,
      'groupSize': groupSize,
      'audienceScope': audienceScope.name,
      'platform': platform.name,
      'meetingLink': meetingLink,
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
      'sessionStatus': sessionStatus.name,
    };
  }

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: (json['id'] as String?) ?? '',
      title: (json['title'] as String?) ?? '',
      tutorId: (json['tutorId'] as String?) ?? '',
      studentIds: List<String>.from(json['studentIds'] ?? []),
      subject: (json['subject'] as String?) ?? '',
      level: json['level'] as String?,
      durationMinutes:
      (json['durationMinutes'] as num?)?.toInt() ?? 60,
      groupSize:
      (json['groupSize'] as num?)?.toInt() ?? 1,
      audienceScope: AudienceScope.values.byName(
        (json['audienceScope'] as String?) ??
            AudienceScope.public.name,
      ),
      platform: ClassroomPlatform.values.byName(
        (json['platform'] as String?) ??
            ClassroomPlatform.zoom.name,
      ),
      meetingLink: (json['meetingLink'] as String?) ?? '',
      scheduledAt: json['scheduledAt'] != null
          ? (json['scheduledAt'] as Timestamp).toDate()
          : DateTime.now(),
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      sessionStatus: SessionStatus.values.byName(
        (json['sessionStatus'] as String?) ??
            SessionStatus.scheduled.name,
      ),
    );
  }
}