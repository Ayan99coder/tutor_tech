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

class SessionModel {
  final String id;
  final String title;
  final String tutorId;
  final List<String> studentIds;
  final String subject;
  final String? level;
  final int groupSize;
  final AudienceScope audienceScope;
  final ClassroomPlatform platform;
  final String meetingLink;
  final DateTime scheduledAt;
  final String? notes;
  final DateTime createdAt;

  const SessionModel({
    required this.id,
    required this.title,
    required this.tutorId,
    required this.studentIds,
    required this.subject,
    this.level,
    required this.groupSize,
    required this.audienceScope,
    required this.platform,
    required this.meetingLink,
    required this.scheduledAt,
    this.notes,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'tutorId': tutorId,
      'studentIds': studentIds,
      'subject': subject,
      'level': level,
      'groupSize': groupSize,
      'audienceScope': audienceScope.name,
      'platform': platform.name,
      'meetingLink': meetingLink,
      'scheduledAt': Timestamp.fromDate(scheduledAt),
      'notes': notes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      tutorId: json['tutorId'] as String,
      studentIds: List<String>.from(json['studentIds'] ?? []),
      subject: json['subject'] as String,
      level: json['level'] as String?,
      groupSize: json['groupSize'] as int,
      audienceScope: AudienceScope.values.byName(
        json['audienceScope'] as String,
      ),
      platform: ClassroomPlatform.values.byName(
        json['platform'] as String,
      ),
      meetingLink: json['meetingLink'] as String,
      scheduledAt: (json['scheduledAt'] as Timestamp).toDate(),
      notes: json['notes'] as String?,
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }
}