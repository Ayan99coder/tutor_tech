import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_colors.dart';
import '../../groups/model/group_model.dart';

class _StudentItem {
  final String id;
  final String name;
  final String email;

  const _StudentItem({
    required this.id,
    required this.name,
    required this.email,
  });
}

class StudentGroupManagement extends ConsumerStatefulWidget {
  const StudentGroupManagement({super.key});

  @override
  ConsumerState<StudentGroupManagement> createState() =>
      _StudentGroupManagementState();
}

class _StudentGroupManagementState
    extends ConsumerState<StudentGroupManagement> {
  final TextEditingController _nameCtrl = TextEditingController();

  List<StudentGroupModel> _groups = [];
  List<_StudentItem> _students = [];

  final Set<String> _selectedIds = {};

  bool _isLoading = true;
  bool _isCreating = false;
  bool _isSaving = false;

  String? _error;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;

    return Dialog(
      backgroundColor: Colors.transparent,
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
        child: Column(children: [_buildHeader()]),
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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
  Widget _loadingView() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppColors.tutorColor),
          SizedBox(height: 12),
          Text('Loading…', style: TextStyle(color: Colors.black54)),
        ],
      ),
    );
  }
  Widget _errorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 8),
            Text(_error!, textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54, fontSize: 13)),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.tutorColor),
              onPressed: (){},
              child: const Text('Retry', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
  Widget _emptyGroupsView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.group_add_rounded, size: 60, color: AppColors.tutorColor),
          const SizedBox(height: 12),
          const Text('No groups yet',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const SizedBox(height: 4),
          const Text('Tap "New Group" to create one',
              style: TextStyle(fontSize: 13, color: Colors.black45)),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => setState(() => _isCreating = true),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Create First Group',
                style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.tutorColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }
}
