

import '../../student/model/student_model.dart';

class ParentModel {
  final String id;
  final String userId;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final List<String> childrenIds;
  final CommunicationPref communicationPreference;
  final DateTime createdAt;

  const ParentModel({
    required this.id,
    required this.userId,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    required this.childrenIds,
    this.communicationPreference = CommunicationPref.both,
    required this.createdAt,
  });

  ParentModel copyWith({
    String? id,
    String? userId,
    String? fullName,
    String? email,
    String? phoneNumber,
    List<String>? childrenIds,
    CommunicationPref? communicationPreference,
    DateTime? createdAt,
  }) {
    return ParentModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      childrenIds: childrenIds ?? this.childrenIds,
      communicationPreference: communicationPreference ?? this.communicationPreference,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'full_name': fullName,
      'email': email,
      'phone_number': phoneNumber,
      'children_ids': childrenIds,
      'communication_pref': communicationPreference.name,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ParentModel.fromJson(Map<String, dynamic> json, [String? docId]) {
    final parsedId = docId ?? json['id'] as String? ?? json['user_id'] as String? ?? json['userId'] as String? ?? '';
    DateTime parsedCreated = DateTime.now();
    final rawCreated = json['created_at'] ?? json['createdAt'];
    if (rawCreated != null) {
      if (rawCreated is String) {
        parsedCreated = DateTime.tryParse(rawCreated) ?? DateTime.now();
      } else if (rawCreated.runtimeType.toString().contains('Timestamp')) {
        try {
          parsedCreated = (rawCreated as dynamic).toDate();
        } catch (_) {}
      }
    }

    return ParentModel(
      id: parsedId,
      userId: json['user_id'] as String? ?? json['userId'] as String? ?? parsedId,
      fullName: json['full_name'] as String? ?? json['fullName'] as String? ?? 'Parent',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? json['phoneNumber'] as String?,
      childrenIds: List<String>.from(json['children_ids'] ?? json['childrenIds'] ?? []),
      communicationPreference: CommunicationPref.values.firstWhere(
        (e) => e.name == json['communication_pref'] || e.name == json['communicationPreference'],
        orElse: () => CommunicationPref.both,
      ),
      createdAt: parsedCreated,
    );
  }
}
