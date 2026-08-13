import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutor_tech/core/constants/app_dimensions.dart';
import 'package:tutor_tech/core/widgets/custom_textfield.dart';

import 'package:tutor_tech/features/group/provider/provider.dart';
import 'package:tutor_tech/features/student/model/student_model.dart';

import '../../../core/constants/app_colors.dart';

import '../modal/student_group_model.dart';

class StudentGroupDialogue extends ConsumerStatefulWidget {
  final String tutorId;
  final String tutorName;
  final List<StudentModel> assignedStudents;

  const StudentGroupDialogue({
    super.key,
    required this.tutorId,
    required this.assignedStudents,
    required this.tutorName,
  });

  @override
  ConsumerState<StudentGroupDialogue> createState() =>
      _StudentGroupDialogueState();
}

class _StudentGroupDialogueState extends ConsumerState<StudentGroupDialogue> {
  final _nameCtrl = TextEditingController();
  bool _isCreating = false;
  final Set<String> _selectedStudentIds = {};

  String? nameError;

  void saveNewGroup() {
    if (_nameCtrl.text.isEmpty) {
      setState(() {
        nameError = 'Please enter the Group name';
      });
      return;
    }
    final stdId = _selectedStudentIds.toList();
    final name = stdId.map((id) {
      final match = widget.assignedStudents.where((s) => s.id == id);
      return match.isNotEmpty ? match.first.fullName : 'Student';
    }).toList();

    final newGroup = StudentGroupModel(
      tutorId: widget.tutorId,
      groupName: _nameCtrl.text,
      studentIds: stdId,
      studentNames: name,
      createdAt: DateTime.now(),
    );
    ref.read(studentGroupProvider(widget.tutorId).notifier).saveGroup(newGroup);
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
      child: Container(
        width: double.maxFinite,
        height: screenH * 0.80,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Column(children: [_buildHeader()]),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 8, 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.tutorColor, Color(0xFF1E5B3E)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white24,
            child: Icon(Icons.groups_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _isCreating ? 'Create New Group' : 'Custom Student Groups',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _isCreating
                      ? 'Name the group & select students'
                      : 'Organise students into study batches',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Widget _createGroupView() {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(AppDimensions.paddingL),
            child: Column(
              crossAxisAlignment: .start,
              children: [
                CustomTextField(
                  label: 'Group Name',
                  controller: _nameCtrl,
                  errorText: nameError,
                ),
                const SizedBox(height: 20),

                Row(
                  children: [
                    if (_selectedStudentIds.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.tutorColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${_selectedStudentIds.length} selected',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                widget.assignedStudents.isEmpty
                    ? Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: const Center(
                          child: Text(
                            'No students found in the system.',
                            style: TextStyle(
                              color: Colors.black45,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      )
                    : Container(
                        constraints: const BoxConstraints(maxHeight: 280),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade200),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade50,
                        ),
                        child: ListView.separated(
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          itemCount: widget.assignedStudents.length,
                          separatorBuilder: (_, __) =>
                              Divider(height: 1, color: Colors.grey.shade200),
                          itemBuilder: (_, i) {
                            final s = widget.assignedStudents[i];
                            final isSelected = _selectedStudentIds.contains(
                              s.id,
                            );
                            return InkWell(
                              onTap: () => setState(() {
                                isSelected
                                    ? _selectedStudentIds.remove(s.id)
                                    : _selectedStudentIds.add(s.id);
                              }),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 10,
                                ),
                                child: Row(
                                  children: [
                                    // Checkbox indicator
                                    AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 150,
                                      ),
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? AppColors.tutorColor
                                            : Colors.transparent,
                                        border: Border.all(
                                          color: isSelected
                                              ? AppColors.tutorColor
                                              : Colors.grey.shade400,
                                          width: 2,
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: isSelected
                                          ? const Icon(
                                              Icons.check,
                                              size: 14,
                                              color: Colors.white,
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 12),
                                    // Avatar
                                    CircleAvatar(
                                      radius: 16,
                                      backgroundColor: AppColors.tutorColor
                                          .withValues(alpha: 0.12),
                                      child: Text(
                                        s.fullName.isNotEmpty
                                            ? s.fullName[0].toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                          color: AppColors.tutorColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    // Name + email
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            s.fullName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14,
                                              color: Colors.black87,
                                            ),
                                          ),
                                          if (s.email.isNotEmpty)
                                            Text(
                                              s.email,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: Colors.black38,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ],
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey.shade200)),
          ),
          child: Row(
            children: [
              // Cancel
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _isCreating = false;

                      // Local selection clear
                      _selectedStudentIds.clear();

                      // Group name clear
                      _nameCtrl.clear();
                    });
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  child: const Text('Cancel'),
                ),
              ),

              const SizedBox(width: 12),

              // Save Group
              Expanded(
                child: ElevatedButton(
                  onPressed: _selectedStudentIds.isEmpty ? null : saveNewGroup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.tutorColor,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                  child: Text(
                    _selectedStudentIds.isEmpty
                        ? 'Save Group'
                        : 'Save Group (${_selectedStudentIds.length})',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
