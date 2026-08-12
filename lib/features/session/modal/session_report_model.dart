class SessionReportModel {
  final String id;
  final String sessionId;
  final String tutorId;
  final String studentId;
  final String? studentName;
  final String? subject;
  final String topicsCovered;
  final String studentPerformance;
  final String homeworkSet;
  final String? concerns;
  final int performanceRating;
  final double? quizMarks;
  final double? quizTotal;
  final double? vivaMarks;
  final double? vivaTotal;
  final String? vivaFeedback;
  final int? classroomRating;
  final DateTime submittedAt;
  final bool viewedByStudent;
  final bool viewedByParent;

  // ── UK-Standard Reporting Fields (F6) ──────────────────────────
  /// Did the student complete homework from the previous session?
  final bool? homeworkCompletedFromPrevious;
  /// Specific academic areas requiring further development.
  final String? areasForImprovement;
  /// Recommended focus / objectives for the next session.
  final String? nextStepsRecommendation;
  /// Overall grade awarded for this session: A / B / C / D.
  final String? overallGrade;
  /// Engagement level 1–5 (1 = disengaged, 5 = fully engaged).
  final int? engagementLevel;

  const SessionReportModel({
    required this.id,
    required this.sessionId,
    required this.tutorId,
    required this.studentId,
    this.studentName,
    this.subject,
    required this.topicsCovered,
    required this.studentPerformance,
    required this.homeworkSet,
    this.concerns,
    required this.performanceRating,
    this.quizMarks,
    this.quizTotal,
    this.vivaMarks,
    this.vivaTotal,
    this.vivaFeedback,
    this.classroomRating,
    required this.submittedAt,
    this.viewedByStudent = false,
    this.viewedByParent = false,
    this.homeworkCompletedFromPrevious,
    this.areasForImprovement,
    this.nextStepsRecommendation,
    this.overallGrade,
    this.engagementLevel,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'session_id': sessionId,
      'tutor_id': tutorId,
      'student_id': studentId,
      'student_name': studentName,
      'subject': subject,
      'topics_covered': topicsCovered,
      'student_performance': studentPerformance,
      'homework_set': homeworkSet,
      'concerns': concerns,
      'performance_rating': performanceRating,
      'quiz_marks': quizMarks,
      'quiz_total': quizTotal,
      'viva_marks': vivaMarks,
      'viva_total': vivaTotal,
      'viva_feedback': vivaFeedback,
      'classroom_rating': classroomRating,
      'submitted_at': submittedAt.toIso8601String(),
      'viewed_by_student': viewedByStudent,
      'viewed_by_parent': viewedByParent,
      'homework_completed_from_previous': homeworkCompletedFromPrevious,
      'areas_for_improvement': areasForImprovement,
      'next_steps_recommendation': nextStepsRecommendation,
      'overall_grade': overallGrade,
      'engagement_level': engagementLevel,
    };
  }

  factory SessionReportModel.fromJson(Map<String, dynamic> json, [String? docId]) {
    return SessionReportModel(
      id: docId ?? json['id'] as String? ?? '',
      sessionId: json['session_id'] as String? ?? json['sessionId'] as String? ?? '',
      tutorId: json['tutor_id'] as String? ?? json['tutorId'] as String? ?? '',
      studentId: json['student_id'] as String? ?? json['studentId'] as String? ?? '',
      studentName: json['student_name'] as String? ?? json['studentName'] as String?,
      subject: json['subject'] as String?,
      topicsCovered: json['topics_covered'] as String? ?? json['topicsCovered'] as String? ?? '',
      studentPerformance: json['student_performance'] as String? ?? json['studentPerformance'] as String? ?? '',
      homeworkSet: json['homework_set'] as String? ?? json['homeworkSet'] as String? ?? '',
      concerns: json['concerns'] as String?,
      performanceRating: json['performance_rating'] as int? ?? json['performanceRating'] as int? ?? 5,
      quizMarks: (json['quiz_marks'] ?? json['quizMarks'] as num?)?.toDouble(),
      quizTotal: (json['quiz_total'] ?? json['quizTotal'] as num?)?.toDouble(),
      vivaMarks: (json['viva_marks'] ?? json['vivaMarks'] as num?)?.toDouble(),
      vivaTotal: (json['viva_total'] ?? json['vivaTotal'] as num?)?.toDouble(),
      vivaFeedback: json['viva_feedback'] as String? ?? json['vivaFeedback'] as String?,
      classroomRating: json['classroom_rating'] as int? ?? json['classroomRating'] as int?,
      submittedAt: json['submitted_at'] != null
          ? DateTime.parse(json['submitted_at'] as String)
          : DateTime.now(),
      viewedByStudent: json['viewed_by_student'] as bool? ?? json['viewedByStudent'] as bool? ?? false,
      viewedByParent: json['viewed_by_parent'] as bool? ?? json['viewedByParent'] as bool? ?? false,
      homeworkCompletedFromPrevious: json['homework_completed_from_previous'] as bool?,
      areasForImprovement: json['areas_for_improvement'] as String?,
      nextStepsRecommendation: json['next_steps_recommendation'] as String?,
      overallGrade: json['overall_grade'] as String?,
      engagementLevel: json['engagement_level'] as int?,
    );
  }
}


