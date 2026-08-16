import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_tech/core/widgets/custom_textfield.dart';
import 'package:tutor_tech/features/admin/provider/admin_provider.dart';
import 'package:tutor_tech/features/group/provider/provider.dart';
import 'package:tutor_tech/features/subjects/subject_model.dart';

import '../../../core/constants/app_text_styles.dart';

class AssignSessionScreen extends ConsumerStatefulWidget {
  const AssignSessionScreen({super.key});

  @override
  ConsumerState<AssignSessionScreen> createState() =>
      _AssignSessionScreenState();
}

class _AssignSessionScreenState extends ConsumerState<AssignSessionScreen> {
  final _titleController = TextEditingController();
  String? _selectedTutorId;
  String _selectedSubject = 'gcse_maths';
  int _audienceScope = 0;
  final List<String> _selectedStudentsIds = [];
  final List<String> _selectedGroupIds = [];

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminProvider);
    final groupState = _selectedTutorId == null
        ? null
        : ref.watch(studentGroupProvider(_selectedTutorId!));
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Text('Assign Tutor & Classroom Details', style: AppTextStyles.h2),
            const SizedBox(height: 16),

            CustomTextField(
              label: 'Classroom Title *',
              controller: _titleController,
            ),
            const SizedBox(height: 16),

            // Subject Selector FIRST
            Text('Step 1: Select Subject *', style: AppTextStyles.labelLarge),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              onChanged: (val) {
                setState(() {
                  if (val != null) {
                    _selectedSubject = val;
                    ref.read(adminProvider.notifier).loadAllFilteredTutors(val);
                  }
                });
              },
              initialValue: _selectedSubject,
              items: seededSubjects.map((e) {
                return DropdownMenuItem(
                  value: e.slug,
                  child: Text('${e.emoji} ${e.displayName}'),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Dynamic Tutor Selector SECOND
            Text(
              'Step 2: Assign Tutor (Filtered by Subject & Availability) *',
              style: AppTextStyles.labelLarge,
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              initialValue: _selectedTutorId,
              decoration: const InputDecoration(
                labelText: 'Select Tutor',
                filled: true,
              ),
              hint: const Text('Select a tutor...'),
              items: adminState.filteredTutors.map((tutor) {
                return DropdownMenuItem<String>(
                  value: tutor.id,
                  child: Text(tutor.fullName),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;

                setState(() {
                  _selectedTutorId = value;
                  _selectedStudentsIds.clear();
                  _selectedGroupIds.clear();
                  _audienceScope = 0;
                  _selectedTutorId = null;
                });

                ref.read(adminProvider.notifier).loadAllFilteredStudent(value);

                ref.read(studentGroupProvider(value).notifier).getGroup();
              },
            ),
            const SizedBox(height: 16),

            // AUDIENCE TARGETING SELECTOR
            Text('Target Audience Scope', style: AppTextStyles.labelLarge),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('Public 🌐')),
                ButtonSegment(value: 1, label: Text('Specific Student 👤')),
                ButtonSegment(value: 2, label: Text('Student Group 👥')),
              ],
              selected: {_audienceScope},
              onSelectionChanged: (val) =>
                  setState(() => _audienceScope = val.first),
            ),
            const SizedBox(height: 12),
            if (_audienceScope == 0) ...[
              Text('All Students:', style: AppTextStyles.bodyMedium),
              const SizedBox(height: 6),
            ],
            if (_audienceScope == 1) ...[
              Text('Select Target Students:', style: AppTextStyles.bodyMedium),
              const SizedBox(height: 6),
              Wrap(
                children: adminState.filteredStudents.map((e) {
                  final isSelect = _selectedStudentsIds.contains(e.id);
                  return FilterChip(
                    label: Text(e.fullName),
                    selected: isSelect,
                    onSelected: (val) {
                      setState(() {
                        if (val) {
                          _selectedStudentsIds.add(e.id);
                        } else {
                          _selectedStudentsIds.remove(e.id);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ],
            if (_audienceScope == 2 && groupState != null) ...[
              if (groupState.isLoading)
                const CircularProgressIndicator()
              else
                Wrap(
                  spacing: 8,
                  children: groupState.groups.map((group) {
                    final isSelected = _selectedGroupIds.contains(group.id);

                    return FilterChip(
                      label: Text(group.groupName),
                      selected: isSelected,
                      onSelected: (value) {
                        setState(() {
                          if (value) {
                            _selectedGroupIds.add(group.id!);
                          } else {
                            _selectedGroupIds.remove(group.id);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
