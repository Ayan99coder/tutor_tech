import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';

enum SubjectStage {
  primary,
  elevenPlus,
  gcse,
  aLevel,
  btec,
}

extension SubjectStageExtension on SubjectStage {
  Color get color {
    switch (this) {
      case SubjectStage.primary:
        return AppColors.primaryStage;
      case SubjectStage.elevenPlus:
        return AppColors.elevenPlus;
      case SubjectStage.gcse:
        return AppColors.gcseColor;
      case SubjectStage.aLevel:
        return AppColors.aLevelColor;
      case SubjectStage.btec:
        return AppColors.btecColor;
    }
  }

  String get displayName {
    switch (this) {
      case SubjectStage.primary:
        return 'Primary';
      case SubjectStage.elevenPlus:
        return '11+';
      case SubjectStage.gcse:
        return 'GCSE';
      case SubjectStage.aLevel:
        return 'A-Level';
      case SubjectStage.btec:
        return 'BTEC';
    }
  }
}

class SubjectModel {
  final String id;
  final String slug;
  final String displayName;
  final String emoji;
  final SubjectStage stage;
  final String description;
  final bool isActive;
  final DateTime createdAt;

  const SubjectModel({
    required this.id,
    required this.slug,
    required this.displayName,
    required this.emoji,
    required this.stage,
    required this.description,
    this.isActive = true,
    required this.createdAt,
  });

  SubjectModel copyWith({
    String? id,
    String? slug,
    String? displayName,
    String? emoji,
    SubjectStage? stage,
    String? description,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return SubjectModel(
      id: id ?? this.id,
      slug: slug ?? this.slug,
      displayName: displayName ?? this.displayName,
      emoji: emoji ?? this.emoji,
      stage: stage ?? this.stage,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'slug': slug,
      'display_name': displayName,
      'emoji': emoji,
      'stage': stage.name,
      'description': description,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      id: json['id'] as String,
      slug: json['slug'] as String,
      displayName: json['display_name'] as String? ?? json['displayName'] as String? ?? '',
      emoji: json['emoji'] as String? ?? '📚',
      stage: SubjectStage.values.firstWhere(
        (e) => e.name == json['stage'],
        orElse: () => SubjectStage.gcse,
      ),
      description: json['description'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? json['isActive'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }
}

// 44 Seeded Subjects List
final List<SubjectModel> seededSubjects = [
  // Primary (1-8)
  SubjectModel(id: 's1', slug: 'primary_maths', displayName: 'Primary Maths', emoji: '🔢', stage: SubjectStage.primary, description: 'Foundational numeracy and arithmetic', createdAt: DateTime.now()),
  SubjectModel(id: 's2', slug: 'primary_english', displayName: 'Primary English', emoji: '📖', stage: SubjectStage.primary, description: 'Phonics, reading & creative writing', createdAt: DateTime.now()),
  SubjectModel(id: 's3', slug: 'primary_science', displayName: 'Primary Science', emoji: '🔬', stage: SubjectStage.primary, description: 'Basic biology, physics & chemistry concepts', createdAt: DateTime.now()),
  SubjectModel(id: 's4', slug: 'primary_phonics', displayName: 'Primary Phonics', emoji: '🔤', stage: SubjectStage.primary, description: 'Early years reading development', createdAt: DateTime.now()),
  SubjectModel(id: 's5', slug: 'primary_humanities', displayName: 'Primary Humanities', emoji: '🌍', stage: SubjectStage.primary, description: 'History & geography fundamentals', createdAt: DateTime.now()),
  SubjectModel(id: 's6', slug: 'primary_computing', displayName: 'Primary Computing', emoji: '💻', stage: SubjectStage.primary, description: 'Intro to digital literacy & logic', createdAt: DateTime.now()),
  SubjectModel(id: 's7', slug: 'primary_art', displayName: 'Primary Art & Design', emoji: '🎨', stage: SubjectStage.primary, description: 'Creative expression & visual skills', createdAt: DateTime.now()),
  SubjectModel(id: 's8', slug: 'primary_arabic', displayName: 'Primary Arabic', emoji: '🌙', stage: SubjectStage.primary, description: 'Basic Arabic alphabet & vocabulary', createdAt: DateTime.now()),

  // 11+ (9-14)
  SubjectModel(id: 's9', slug: '11plus_maths', displayName: '11+ Maths', emoji: '📐', stage: SubjectStage.elevenPlus, description: 'Advanced problem solving for grammar school entry', createdAt: DateTime.now()),
  SubjectModel(id: 's10', slug: '11plus_english', displayName: '11+ English', emoji: '📝', stage: SubjectStage.elevenPlus, description: 'Comprehension & high-level vocabulary', createdAt: DateTime.now()),
  SubjectModel(id: 's11', slug: '11plus_verbal', displayName: '11+ Verbal Reasoning', emoji: '🧠', stage: SubjectStage.elevenPlus, description: 'Word puzzles & logical deductions', createdAt: DateTime.now()),
  SubjectModel(id: 's12', slug: '11plus_non_verbal', displayName: '11+ Non-Verbal Reasoning', emoji: '🧩', stage: SubjectStage.elevenPlus, description: 'Spatial awareness & shape patterns', createdAt: DateTime.now()),
  SubjectModel(id: 's13', slug: '11plus_mock_prep', displayName: '11+ Exam Practice', emoji: '⏱️', stage: SubjectStage.elevenPlus, description: 'Time management & mock paper technique', createdAt: DateTime.now()),
  SubjectModel(id: 's14', slug: '11plus_creative_writing', displayName: '11+ Creative Writing', emoji: '✍️', stage: SubjectStage.elevenPlus, description: 'Advanced descriptive essay writing', createdAt: DateTime.now()),

  // GCSE (15-28)
  SubjectModel(id: 's15', slug: 'gcse_maths', displayName: 'GCSE Maths (Foundation & Higher)', emoji: '📊', stage: SubjectStage.gcse, description: 'Algebra, geometry, statistics & calculus intro', createdAt: DateTime.now()),
  SubjectModel(id: 's16', slug: 'gcse_english_language', displayName: 'GCSE English Language', emoji: '📚', stage: SubjectStage.gcse, description: 'Text analysis, argumentation & writing skills', createdAt: DateTime.now()),
  SubjectModel(id: 's17', slug: 'gcse_english_literature', displayName: 'GCSE English Literature', emoji: '🎭', stage: SubjectStage.gcse, description: 'Analysis of Shakespeare, poetry & modern prose', createdAt: DateTime.now()),
  SubjectModel(id: 's18', slug: 'gcse_biology', displayName: 'GCSE Biology', emoji: '🧬', stage: SubjectStage.gcse, description: 'Cell biology, genetics, ecology & human anatomy', createdAt: DateTime.now()),
  SubjectModel(id: 's19', slug: 'gcse_chemistry', displayName: 'GCSE Chemistry', emoji: '🧪', stage: SubjectStage.gcse, description: 'Atomic structure, reactions & organic chemistry', createdAt: DateTime.now()),
  SubjectModel(id: 's20', slug: 'gcse_physics', displayName: 'GCSE Physics', emoji: '⚡', stage: SubjectStage.gcse, description: 'Forces, energy, electricity & space physics', createdAt: DateTime.now()),
  SubjectModel(id: 's21', slug: 'gcse_combined_science', displayName: 'GCSE Combined Science', emoji: '🔬', stage: SubjectStage.gcse, description: 'Trilogy & Synergy double award coverage', createdAt: DateTime.now()),
  SubjectModel(id: 's22', slug: 'gcse_computer_science', displayName: 'GCSE Computer Science', emoji: '💻', stage: SubjectStage.gcse, description: 'Python programming & computer systems', createdAt: DateTime.now()),
  SubjectModel(id: 's23', slug: 'gcse_geography', displayName: 'GCSE Geography', emoji: '🗺️', stage: SubjectStage.gcse, description: 'Physical landscapes & human geography', createdAt: DateTime.now()),
  SubjectModel(id: 's24', slug: 'gcse_history', displayName: 'GCSE History', emoji: '🏛️', stage: SubjectStage.gcse, description: 'Modern world history & thematic studies', createdAt: DateTime.now()),
  SubjectModel(id: 's25', slug: 'gcse_french', displayName: 'GCSE French', emoji: '🇫🇷', stage: SubjectStage.gcse, description: 'Listening, speaking, reading & writing', createdAt: DateTime.now()),
  SubjectModel(id: 's26', slug: 'gcse_spanish', displayName: 'GCSE Spanish', emoji: '🇪🇸', stage: SubjectStage.gcse, description: 'Conversational fluency & grammar mastery', createdAt: DateTime.now()),
  SubjectModel(id: 's27', slug: 'gcse_arabic', displayName: 'GCSE Arabic', emoji: '🕌', stage: SubjectStage.gcse, description: 'Modern Standard Arabic for GCSE exam boards', createdAt: DateTime.now()),
  SubjectModel(id: 's28', slug: 'gcse_business', displayName: 'GCSE Business Studies', emoji: '📈', stage: SubjectStage.gcse, description: 'Marketing, finance & enterprise fundamentals', createdAt: DateTime.now()),

  // A-Level (29-38)
  SubjectModel(id: 's29', slug: 'a_level_maths', displayName: 'A-Level Maths', emoji: '📐', stage: SubjectStage.aLevel, description: 'Pure maths, mechanics & statistics', createdAt: DateTime.now()),
  SubjectModel(id: 's30', slug: 'a_level_further_maths', displayName: 'A-Level Further Maths', emoji: '♾️', stage: SubjectStage.aLevel, description: 'Complex numbers, matrices & differential equations', createdAt: DateTime.now()),
  SubjectModel(id: 's31', slug: 'a_level_biology', displayName: 'A-Level Biology', emoji: '🔬', stage: SubjectStage.aLevel, description: 'Biochemistry, gene technology & physiology', createdAt: DateTime.now()),
  SubjectModel(id: 's32', slug: 'a_level_chemistry', displayName: 'A-Level Chemistry', emoji: '⚗️', stage: SubjectStage.aLevel, description: 'Physical, inorganic & organic chemistry', createdAt: DateTime.now()),
  SubjectModel(id: 's33', slug: 'a_level_physics', displayName: 'A-Level Physics', emoji: '⚛️', stage: SubjectStage.aLevel, description: 'Quantum physics, fields & nuclear physics', createdAt: DateTime.now()),
  SubjectModel(id: 's34', slug: 'a_level_economics', displayName: 'A-Level Economics', emoji: '📉', stage: SubjectStage.aLevel, description: 'Microeconomics & macroeconomics theory', createdAt: DateTime.now()),
  SubjectModel(id: 's35', slug: 'a_level_psychology', displayName: 'A-Level Psychology', emoji: '🧠', stage: SubjectStage.aLevel, description: 'Cognition, psychopathology & social influence', createdAt: DateTime.now()),
  SubjectModel(id: 's36', slug: 'a_level_sociology', displayName: 'A-Level Sociology', emoji: '👥', stage: SubjectStage.aLevel, description: 'Family, education, crime & deviance', createdAt: DateTime.now()),
  SubjectModel(id: 's37', slug: 'a_level_computer_science', displayName: 'A-Level Computer Science', emoji: '💻', stage: SubjectStage.aLevel, description: 'Algorithms, data structures & software project', createdAt: DateTime.now()),
  SubjectModel(id: 's38', slug: 'a_level_arabic', displayName: 'A-Level Arabic', emoji: '📜', stage: SubjectStage.aLevel, description: 'Advanced prose, literature & translation', createdAt: DateTime.now()),

  // BTEC (39-44)
  SubjectModel(id: 's39', slug: 'btec_applied_science', displayName: 'BTEC Applied Science', emoji: '🧪', stage: SubjectStage.btec, description: 'Practical laboratory techniques & procedures', createdAt: DateTime.now()),
  SubjectModel(id: 's40', slug: 'btec_business', displayName: 'BTEC Business & Management', emoji: '🏢', stage: SubjectStage.btec, description: 'Vocational business coursework & assignments', createdAt: DateTime.now()),
  SubjectModel(id: 's41', slug: 'btec_it', displayName: 'BTEC Information Technology', emoji: '🖥️', stage: SubjectStage.btec, description: 'Database design, cyber security & web dev', createdAt: DateTime.now()),
  SubjectModel(id: 's42', slug: 'btec_health_social_care', displayName: 'BTEC Health & Social Care', emoji: '🩺', stage: SubjectStage.btec, description: 'Human lifespan development & care values', createdAt: DateTime.now()),
  SubjectModel(id: 's43', slug: 'btec_engineering', displayName: 'BTEC Engineering', emoji: '⚙️', stage: SubjectStage.btec, description: 'Engineering principles, CAD & manufacturing', createdAt: DateTime.now()),
  SubjectModel(id: 's44', slug: 'btec_sport', displayName: 'BTEC Sport & Exercise Science', emoji: '⚽', stage: SubjectStage.btec, description: 'Anatomy, physiology & sports performance', createdAt: DateTime.now()),
];
