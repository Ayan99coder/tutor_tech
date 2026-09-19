import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tutor_tech/features/groups/provider/providers.dart';

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
  final String tutorId;

  const StudentGroupManagement({super.key, required this.tutorId});

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
  bool _isCreating = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    final state = ref.watch(groupByTutorIdProvider(widget.tutorId));
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
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: _isCreating
                  ? _createGroupView()
                  : state.when(
                      data: (group) {
                        if (group.isEmpty) return _emptyGroupsView();
                        return _groupsListView(group);
                      },
                      error: (error, t) {
                        return _errorView(error.toString());
                      },
                      loading: () {
                        return _loadingView();
                      },
                    ),
            ),
          ],
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

  Widget _errorView(String? error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 8),
            Text(
              error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.tutorColor,
              ),
              onPressed: () {},
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
          const Icon(
            Icons.group_add_rounded,
            size: 60,
            color: AppColors.tutorColor,
          ),
          const SizedBox(height: 12),
          const Text(
            'No groups yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Tap "New Group" to create one',
            style: TextStyle(fontSize: 13, color: Colors.black45),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => setState(() => _isCreating = true),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Create First Group',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.tutorColor,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _createGroupView() {
    return Column();
  }

  Widget _groupsListView(List<StudentGroupModel> groups) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 12, 6),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  groups.length == 1
                      ? 'Group (${groups.length})'
                      : 'Groups (${groups.length})',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              TextButton.icon(
                onPressed: () => setState(() => _isCreating = true),
                icon: const Icon(Icons.add, color: AppColors.tutorColor, size: 18),
                label: const Text('New Group',
                    style: TextStyle(color: AppColors.tutorColor,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
        ListView.separated( itemBuilder: (_, i) => _groupCard(_groups[i]), separatorBuilder:(_, __) => const SizedBox(height: 8), itemCount: groups.length)
      ],
    );
  }
  Widget _groupCard(StudentGroupModel g) {
    final count = g.studentIds.length;
    final namesList = g.studentNames.isNotEmpty
        ? g.studentNames.join(', ')
        : (count > 0 ? '$count student(s)' : 'No students');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.tutorColor.withValues(alpha: 0.25)),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: CircleAvatar(
          backgroundColor: AppColors.tutorColor.withValues(alpha: 0.12),
          child: const Icon(Icons.groups_rounded,
              color: AppColors.tutorColor, size: 20),
        ),
        title: Text(g.groupName,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87)),
        subtitle: Text(
          '$count student(s) • $namesList',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 12, color: Colors.black45),
        ),
        trailing: OutlinedButton.icon(
          onPressed: () {
          },
          icon: const Icon(Icons.chat_bubble_outline,
              size: 14, color: AppColors.tutorColor),
          label: const Text('Chat',
              style: TextStyle(color: AppColors.tutorColor,
                  fontSize: 12, fontWeight: FontWeight.bold)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.tutorColor),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ),
    );
  }

}
