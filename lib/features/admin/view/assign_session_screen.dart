import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_tech/core/constants/app_dimensions.dart';
import 'package:tutor_tech/core/widgets/custom_appbar.dart';
import 'package:tutor_tech/core/widgets/custom_textfield.dart';
import 'package:tutor_tech/core/widgets/loading_overlay.dart';
import 'package:tutor_tech/features/session/modal/session_model.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../subjects/subject_model.dart';
import '../../tutor/model/student_group_model.dart';
import '../../tutor/model/tutor_repository.dart';

class AssignSessionScreen extends ConsumerStatefulWidget {
  const AssignSessionScreen({super.key});

  @override
  ConsumerState<AssignSessionScreen> createState() =>
      _AssignSessionScreenState();
}

class _AssignSessionScreenState extends ConsumerState<AssignSessionScreen> {
  final _titleController = TextEditingController();
  final _zoomLinkController = TextEditingController();
  final _notesController = TextEditingController();
  ClassroomPlatform _platform = ClassroomPlatform.zoom;
  String? _selectedTutorId;
  String _selectedSubject = 'gcse_maths';
  DateTime _scheduledDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _scheduledTime = const TimeOfDay(hour: 16, minute: 0);

  int _audienceScope = 0; // 0 = Public, 1 = Specific Students, 2 = Groups
  final Set<String> _selectedStudentIds = {};
  final Set<String> _selectedGroupIds = {};

  List<StudentWithParent> _students = [];
  List<StudentGroupModel> _groups = [];
  List<DropdownMenuItem<String>> _availableTutorItems = [];
  final Map<String, String> _tutorNameMap = {};
  bool _isLoadingData = true;
void _updateFiltered(String value){

}
  @override
  Widget build(BuildContext context) {
    return LoadingOverlay(
      isLoading: true,

      child: Scaffold(
        appBar: CustomAppbar(title: ''),
        body: SingleChildScrollView(
          padding: .all(AppDimensions.paddingL),
          child: Column(
            crossAxisAlignment: .start,
            children: [
              CustomTextField(label: '', controller: _titleController),
              const SizedBox(height: 16),

              // Subject Selector FIRST
              Text('Step 1: Select Subject *', style: AppTextStyles.labelLarge),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: _selectedSubject,
                decoration: const InputDecoration(fillColor: AppColors.surfaceCard, filled: true),
                items: seededSubjects.map((s) {
                  return DropdownMenuItem(value: s.slug, child: Text('${s.emoji} ${s.displayName}'));
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedSubject = val;
                      _updateFiltered(val);
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
