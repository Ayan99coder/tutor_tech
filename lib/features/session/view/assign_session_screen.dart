import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_tech/core/widgets/custom_textfield.dart';
import 'package:tutor_tech/features/session/provider/session_provider.dart';
import 'package:tutor_tech/features/subject/subject_model.dart';
import '../../../core/constants/app_text_styles.dart';
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
  ClassroomPlatform _platform = ClassroomPlatform.zoom;
  String _selectedSubject = 'gcse_maths';
  String? _selectedTutorId;
  int _audienceScope = 0;
final List<String> _selectedStudentId=[];
  @override
  Widget build(BuildContext context) {
    final sessionFilteredTutor = ref.watch(sessionProvider);
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 80, left: 10, right: 10),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            CustomTextField(label: 'Classroom Title', controller: _title),

            const SizedBox(height: 16),
            Text('Step 1: Select Subject *', style: AppTextStyles.labelLarge),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _selectedSubject,
              items: seededSubjects.map((e) {
                return DropdownMenuItem(
                  value: e.slug,
                  child: Text('${e.emoji} ${e.displayName}'),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedSubject = val;
                    _selectedStudentId.clear();
                  });

                  final notifier = ref.read(sessionProvider.notifier);

                  notifier.getTutorBySubject(val);

                  if (_audienceScope == 1) {
                    notifier.getStudentBySubject(val);
                  }
                }
              },
            ),
            const SizedBox(height: 16),

            // Dynamic Tutor Selector SECOND
            Text(
              'Step 2: Assign Tutor (Filtered by Subject & Availability) *',
              style: AppTextStyles.labelLarge,
            ),
            const SizedBox(height: 6),
            sessionFilteredTutor.when(
              data: (state) {
                return DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: _selectedTutorId,

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
                return Center(child: Text(e.toString()));
              },
              loading: () {
                return DropdownButtonFormField(items: [], onChanged: (val) {});
              },
            ),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Public 🌐')),
                ButtonSegment(value: 1, label: Text('Specific Student 👤')),
                ButtonSegment(value: 2, label: Text('Student Group 👥')),
              ],
              selected: {_audienceScope},
              onSelectionChanged: (values) {
                final scope = values.first;

                setState(() {
                  _audienceScope = scope;
                });
              },
            ),
            const SizedBox(height: 12),
            if (_audienceScope == 1) ...[
              const SizedBox(height: 12),

              sessionFilteredTutor.when(
                loading: () => const CircularProgressIndicator(),

                error: (error, stack) => Text(
                  error.toString(),
                ),

                data: (students) => Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: students.studentsBySubject.map((student) {
                    return ChoiceChip(
                      label: Text(student.fullName),
                      selected: _selectedStudentId.contains(student.id),
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
                ),
              ),
            ],
            Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    avatar: const Icon(Icons.video_call, size: 18),
                    label: const Text('Zoom Meeting'),
                    selected: _platform == ClassroomPlatform.zoom,
                    onSelected: (sel) {
                      if (sel) setState(() => _platform = ClassroomPlatform.zoom);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ChoiceChip(
                    avatar: const Icon(Icons.school, size: 18),
                    label: const Text('Google Classroom'),
                    selected: _platform == ClassroomPlatform.googleClassroom,
                    onSelected: (sel) {
                      if (sel) setState(() => _platform = ClassroomPlatform.googleClassroom);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            CustomTextField(
              label: _platform == ClassroomPlatform.zoom ? 'Zoom Meeting Link *' : 'Google Classroom Link *',
              controller: _zoomLinkController,
              prefixIcon: Icons.link,
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
