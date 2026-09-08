import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:tutor_tech/core/widgets/custom_textfield.dart';
import 'package:tutor_tech/features/session/provider/session_provider.dart';
import 'package:tutor_tech/features/subject/subject_model.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';

import '../../../core/widgets/custom_button.dart';
import '../modal/session_modal.dart';

class AssignSessionScreen extends ConsumerStatefulWidget {
  const AssignSessionScreen({super.key});

  @override
  ConsumerState<AssignSessionScreen> createState() =>
      _AssignSessionScreenState();
}

class _AssignSessionScreenState extends ConsumerState<AssignSessionScreen> {
  final TextEditingController _title = TextEditingController();
  final _zoomLinkController = TextEditingController();
  final _notesController = TextEditingController();
  ClassroomPlatform _platform = ClassroomPlatform.zoom;
  String _selectedSubject = 'gcse_maths';
  String _selectedLevel = 'gcse';
  String? _selectedTutorId;
  int _audienceScope = 0;
  final List<String> _selectedStudentId = [];
  DateTime _scheduledDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _scheduledTime = const TimeOfDay(hour: 16, minute: 0);

  @override
  void dispose() {
    _title.dispose();
    _zoomLinkController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _createSession() {
    final data = SessionModel(
      title: _title.text.trim(),
      tutorId: _selectedTutorId!,
      studentIds: List.from(_selectedStudentId),
      subject: _selectedSubject,
      level: _selectedLevel,
      groupSize: _selectedStudentId.length,
      audienceScope: AudienceScope.values[_audienceScope],
      platform: _platform,
      meetingLink: _zoomLinkController.text.trim(),
      scheduledAt: _scheduledDate,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      createdAt: DateTime.now(),
      id: '',
    );
    ref.read(sessionProvider.notifier).saveSession(data);
  }

  void _resetForm() {
    _title.clear();
    _zoomLinkController.clear();
    _notesController.clear();

    setState(() {
      _selectedSubject = 'gcse_maths';
      _selectedLevel = 'gcse';
      _selectedTutorId = null;
      _selectedStudentId.clear();

      _audienceScope = 0;
      _platform = ClassroomPlatform.zoom;

      _scheduledDate = DateTime.now().add(
        const Duration(days: 1),
      );

      _scheduledTime = const TimeOfDay(
        hour: 16,
        minute: 0,
      );
    });
  }
  @override
  Widget build(BuildContext context) {
    ref.listen(sessionProvider, (previous, next) {
      next.whenOrNull(
        data: (sessionState) {
          if (sessionState.isCreateSuccess &&
              previous?.valueOrNull?.isCreateSuccess != true) {
            final title = sessionState.createdSessionTitle;

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Session $title created successfully')),
            );
            _resetForm();
          }

        },
        error: (error, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Failed to create session')),
          );
        },
      );
    });

    final sessionFilteredTutor = ref.watch(sessionProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Assign Session',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        centerTitle: false,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 850),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ---------------------------------------------------------
                  // HEADER
                  // ---------------------------------------------------------
                  const Text(
                    'Create a New Session',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    'Configure the session details, assign a tutor and schedule the class.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ---------------------------------------------------------
                  // BASIC INFORMATION
                  // ---------------------------------------------------------
                  _buildSectionCard(
                    context,
                    title: 'Basic Information',
                    icon: Icons.info_outline,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Classroom Title',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 8),

                        CustomTextField(
                          label: 'e.g. Mathematics — Algebra',
                          controller: _title,
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          'Subject',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),

                        const SizedBox(height: 8),

                        DropdownButtonFormField<String>(
                          initialValue: _selectedSubject,
                          isExpanded: true,
                          decoration: _dropdownDecoration(
                            context,
                            hint: 'Select subject',
                            icon: Icons.menu_book_outlined,
                          ),
                          items: seededSubjects.map((e) {
                            return DropdownMenuItem<String>(
                              value: e.slug,
                              child: Text('${e.emoji}  ${e.displayName}'),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() {
                                _selectedSubject = val;
                                _selectedStudentId.clear();
                              });

                              final notifier = ref.read(
                                sessionProvider.notifier,
                              );

                              notifier.getTutorBySubject(val);

                              notifier.getStudentBySubject(val);
                            }
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ---------------------------------------------------------
                  // TUTOR
                  // ---------------------------------------------------------
                  _buildSectionCard(
                    context,
                    title: 'Tutor Assignment',
                    icon: Icons.person_outline,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Select a tutor based on the selected subject and availability.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurfaceVariant,
                          ),
                        ),

                        const SizedBox(height: 12),

                        sessionFilteredTutor.when(
                          data: (state) {
                            return DropdownButtonFormField<String>(
                              isExpanded: true,
                              initialValue: _selectedTutorId,
                              decoration: _dropdownDecoration(
                                context,
                                hint: 'Select tutor',
                                icon: Icons.person_search_outlined,
                              ),
                              items: state.tutors.map((tutor) {
                                return DropdownMenuItem<String>(
                                  value: tutor.id,
                                  child: Text(
                                    '${tutor.fullName}  •  '
                                    '${tutor.isAvailable ? '[Available]' : '[Unavailable]'}  •  '
                                    '${tutor.subjectExpertise.join(', ')}',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }).toList(),
                              onChanged: (val) {
                                setState(() {
                                  _selectedTutorId = val;
                                });
                              },
                            );
                          },
                          error: (e, stackTrace) {
                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusM,
                                ),
                                color: Theme.of(
                                  context,
                                ).colorScheme.errorContainer,
                              ),
                              child: Text(
                                e.toString(),
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onErrorContainer,
                                ),
                              ),
                            );
                          },
                          loading: () {
                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 17,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusM,
                                ),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: const Row(
                                children: [
                                  SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                  SizedBox(width: 12),
                                  Text('Loading tutors...'),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ---------------------------------------------------------
                  // AUDIENCE
                  // ---------------------------------------------------------
                  _buildSectionCard(
                    context,
                    title: 'Audience',
                    icon: Icons.groups_outlined,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Who should attend this session?',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        const SizedBox(height: 12),

                        SizedBox(
                          width: double.infinity,
                          child: SegmentedButton<int>(
                            segments: const [
                              ButtonSegment(
                                value: 0,
                                icon: Icon(Icons.public),
                                label: Text('Public'),
                              ),
                              ButtonSegment(
                                value: 1,
                                icon: Icon(Icons.person),
                                label: Text('Student'),
                              ),
                              ButtonSegment(
                                value: 2,
                                icon: Icon(Icons.groups),
                                label: Text('Group'),
                              ),
                            ],
                            selected: {_audienceScope},
                            onSelectionChanged: (values) {
                              final scope = values.first;

                              setState(() {
                                _audienceScope = scope;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ---------------------------------------------------------
                  // LEVEL
                  // ---------------------------------------------------------
                  _buildSectionCard(
                    context,
                    title: 'Academic Level',
                    icon: Icons.school_outlined,
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedLevel,
                      isExpanded: true,
                      decoration: _dropdownDecoration(
                        context,
                        hint: 'Select level',
                        icon: Icons.school_outlined,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'primary',
                          child: Text('Primary'),
                        ),
                        DropdownMenuItem(
                          value: 'secondary',
                          child: Text('Secondary'),
                        ),
                        DropdownMenuItem(value: 'gcse', child: Text('GCSE')),
                        DropdownMenuItem(
                          value: 'a_level',
                          child: Text('A Level'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedLevel = value;
                          });
                        }
                      },
                    ),
                  ),

                  // ---------------------------------------------------------
                  // SPECIFIC STUDENTS
                  // ---------------------------------------------------------
                  if (_audienceScope == 1) ...[
                    const SizedBox(height: 16),

                    _buildSectionCard(
                      context,
                      title: 'Select Students',
                      icon: Icons.person_add_alt_1_outlined,
                      child: sessionFilteredTutor.when(
                        loading: () {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(12),
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                        error: (error, stack) {
                          return Text(error.toString());
                        },
                        data: (students) {
                          if (students.studentsBySubject.isEmpty) {
                            return Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.radiusM,
                                ),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: const Text(
                                'No students found for this subject.',
                              ),
                            );
                          }

                          return Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: students.studentsBySubject.map((student) {
                              return FilterChip(
                                avatar: const Icon(
                                  Icons.person_outline,
                                  size: 18,
                                ),
                                label: Text(student.fullName),
                                selected: _selectedStudentId.contains(
                                  student.id,
                                ),
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _selectedStudentId.add(student.id);
                                    } else {
                                      _selectedStudentId.remove(student.id);
                                    }
                                  });
                                },
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ),
                  ],

                  const SizedBox(height: 16),

                  // ---------------------------------------------------------
                  // CLASSROOM PLATFORM
                  // ---------------------------------------------------------
                  _buildSectionCard(
                    context,
                    title: 'Classroom Platform',
                    icon: Icons.video_camera_front_outlined,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Choose how the class will be conducted.',
                          style: TextStyle(fontSize: 13),
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: [
                            Expanded(
                              child: _platformCard(
                                context: context,
                                icon: Icons.video_call_outlined,
                                title: 'Zoom',
                                selected: _platform == ClassroomPlatform.zoom,
                                onTap: () {
                                  setState(() {
                                    _platform = ClassroomPlatform.zoom;
                                  });
                                },
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: _platformCard(
                                context: context,
                                icon: Icons.school_outlined,
                                title: 'Google Classroom',
                                selected:
                                    _platform ==
                                    ClassroomPlatform.googleClassroom,
                                onTap: () {
                                  setState(() {
                                    _platform =
                                        ClassroomPlatform.googleClassroom;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        CustomTextField(
                          label: _platform == ClassroomPlatform.zoom
                              ? 'Zoom Meeting Link *'
                              : 'Google Classroom Link *',
                          controller: _zoomLinkController,
                          prefixIcon: Icons.link,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ---------------------------------------------------------
                  // SCHEDULE
                  // ---------------------------------------------------------
                  _buildSectionCard(
                    context,
                    title: 'Schedule',
                    icon: Icons.calendar_month_outlined,
                    child: Row(
                      children: [
                        Expanded(
                          child: _dateTimeCard(
                            context: context,
                            icon: Icons.calendar_today_outlined,
                            label: 'Date',
                            value: DateFormat(
                              'dd MMM yyyy',
                            ).format(_scheduledDate),
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _scheduledDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(
                                  const Duration(days: 90),
                                ),
                              );

                              if (picked != null) {
                                setState(() {
                                  _scheduledDate = picked;
                                });
                              }
                            },
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: _dateTimeCard(
                            context: context,
                            icon: Icons.access_time_outlined,
                            label: 'Time',
                            value: _scheduledTime.format(context),
                            onTap: () async {
                              final picked = await showTimePicker(
                                context: context,
                                initialTime: _scheduledTime,
                              );

                              if (picked != null) {
                                setState(() {
                                  _scheduledTime = picked;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ---------------------------------------------------------
                  // NOTES
                  // ---------------------------------------------------------
                  _buildSectionCard(
                    context,
                    title: 'Additional Information',
                    icon: Icons.notes_outlined,
                    child: CustomTextField(
                      label: 'Internal Admin Instructions (Optional)',
                      controller: _notesController,
                      maxLines: 3,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ---------------------------------------------------------
                  // SUBMIT BUTTON
                  // ---------------------------------------------------------
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: CustomButton(
                      label: 'Assign Tutor & Confirm Schedule',
                      onPressed: _createSession,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),

              const SizedBox(width: 12),

              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          child,
        ],
      ),
    );
  }

  InputDecoration _dropdownDecoration(
    BuildContext context, {
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Theme.of(context).colorScheme.surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        borderSide: BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        borderSide: BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        borderSide: BorderSide(
          color: Theme.of(context).colorScheme.primary,
          width: 1.5,
        ),
      ),
    );
  }

  Widget _platformCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(
            color: selected
                ? Theme.of(context).colorScheme.primary
                : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
          color: selected
              ? Theme.of(context).colorScheme.primaryContainer
              : AppColors.surfaceCard,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 22,
              color: selected ? Theme.of(context).colorScheme.primary : null,
            ),

            const SizedBox(width: 10),

            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),

            if (selected)
              Icon(
                Icons.check_circle,
                size: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
          ],
        ),
      ),
    );
  }

  Widget _dateTimeCard({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(AppDimensions.radiusM),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 18,
                  color: Theme.of(context).colorScheme.primary,
                ),

                const SizedBox(width: 7),

                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              value,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}
