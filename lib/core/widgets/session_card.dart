import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../features/session/modal/session_modal.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_text_styles.dart';

import '../utils/utils/date_formatter.dart';
import 'status_badge.dart';

class SessionCard extends StatefulWidget {
  final SessionModel session;
  final String tutorName;
  final String studentName;
  final bool isTutor;

  final VoidCallback? onTap;
  final VoidCallback? onStartSession;
  final VoidCallback? onMarkCompleted;
  final VoidCallback? onMarkDismissed;

  const SessionCard({
    super.key,
    required this.session,
    this.tutorName = '',
    this.studentName = '',
    this.isTutor = false,
    this.onTap,
    this.onStartSession,
    this.onMarkCompleted,
    this.onMarkDismissed,
  });

  @override
  State<SessionCard> createState() => _SessionCardState();
}

class _SessionCardState extends State<SessionCard> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(
      const Duration(seconds: 30),
          (_) {
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  Color _getStatusColor(SessionStatus status) {
    switch (status) {
      case SessionStatus.scheduled:
        return AppColors.info;

      case SessionStatus.inProgress:
        return AppColors.success;

      case SessionStatus.completed:
        return AppColors.textSecondary;

      case SessionStatus.cancelled:
        return AppColors.error;

      case SessionStatus.noShow:
        return AppColors.warning;
    }
  }

  String _getStatusLabel(SessionStatus status) {
    switch (status) {
      case SessionStatus.scheduled:
        return 'Scheduled';

      case SessionStatus.inProgress:
        return 'Live';

      case SessionStatus.completed:
        return 'Completed';

      case SessionStatus.cancelled:
        return 'Cancelled';

      case SessionStatus.noShow:
        return 'No Show';
    }
  }

  String _formatSubject(String subject) {
    return subject
        .replaceAll('_', ' ')
        .split(' ')
        .map(
          (word) => word.isEmpty
          ? ''
          : '${word[0].toUpperCase()}${word.substring(1)}',
    )
        .join(' ');
  }

  String _getPlatformName(ClassroomPlatform platform) {
    switch (platform) {
      case ClassroomPlatform.zoom:
        return 'Zoom';

      case ClassroomPlatform.googleClassroom:
        return 'Google Classroom';
    }
  }

  String _getPersonName() {
    if (widget.isTutor) {
      return widget.studentName.trim().isEmpty
          ? 'Student'
          : widget.studentName;
    }

    return widget.tutorName.trim().isEmpty
        ? 'Pending Tutor'
        : widget.tutorName;
  }

  bool get _isCompleted =>
      widget.session.sessionStatus == SessionStatus.completed;

  bool get _isCancelled =>
      widget.session.sessionStatus == SessionStatus.cancelled;

  bool get _isSessionStarted {
    return DateTime.now().isAfter(
      widget.session.scheduledAt,
    );
  }

  bool get _canJoin {
    final now = DateTime.now();

    final startTime = widget.session.scheduledAt;

    final endTime = startTime.add(
      Duration(
        minutes: widget.session.durationMinutes,
      ),
    );

    final unlockTime = startTime.subtract(
      const Duration(minutes: 10),
    );

    return now.isAfter(unlockTime) &&
        now.isBefore(endTime) &&
        !_isCompleted &&
        !_isCancelled;
  }

  int get _minutesUntilStart {
    final difference = widget.session.scheduledAt.difference(
      DateTime.now(),
    );

    return difference.inMinutes;
  }

  Future<void> _openMeetingLink() async {
    final link = widget.session.meetingLink.trim();

    if (link.isEmpty) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Meeting link is not available.',
          ),
        ),
      );

      return;
    }

    final uri = Uri.tryParse(link);

    if (uri == null) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Invalid meeting link.',
          ),
        ),
      );

      return;
    }

    final success = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Could not open meeting link.',
          ),
        ),
      );
    }
  }

  Widget _buildActionButton() {
    if (_isCompleted || _isCancelled) {
      return const SizedBox.shrink();
    }

    if (!_canJoin) {
      final minutes = _minutesUntilStart;

      String label;

      if (minutes > 0) {
        label = 'Join in $minutes min';
      } else {
        label = 'Session Starting Soon';
      }

      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: null,
              icon: const Icon(
                Icons.lock_clock,
              ),
              label: Text(label),
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Meeting link unlocks 10 minutes before the session.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.textHint,
            ),
          ),
        ],
      );
    }

    if (widget.isTutor) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed:
          widget.onStartSession ?? _openMeetingLink,
          icon: const Icon(
            Icons.video_call,
          ),
          label: const Text(
            'Start Session',
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _openMeetingLink,
        icon: const Icon(
          Icons.video_call,
        ),
        label: Text(
          widget.session.platform ==
              ClassroomPlatform.zoom
              ? 'Join Zoom Session'
              : 'Open Classroom',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = widget.session;

    final statusColor = _getStatusColor(
      session.sessionStatus,
    );

    final statusLabel = _getStatusLabel(
      session.sessionStatus,
    );

    final endTime = session.scheduledAt.add(
      Duration(
        minutes: session.durationMinutes,
      ),
    );

    final hasEnded = DateTime.now().isAfter(endTime);

    return RepaintBoundary(
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.only(
            bottom: 12,
          ),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(
              AppDimensions.radiusCard,
            ),
            border: Border.all(
              color: AppColors.border,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [

              // =========================
              // TOP ROW
              // =========================

              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Text(
                          '📚',
                          style: TextStyle(
                            fontSize: 24,
                          ),
                        ),

                        const SizedBox(width: 8),

                        Expanded(
                          child: Text(
                            _formatSubject(
                              session.subject,
                            ),
                            style: AppTextStyles.h4,
                            overflow:
                            TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),

                  StatusBadge(
                    label: statusLabel,
                    color: statusColor,
                  ),

                  const SizedBox(width: 6),

                  IconButton(
                    icon: const Icon(
                      Icons.flag_outlined,
                      color: AppColors.textHint,
                      size: 20,
                    ),
                    onPressed: () {
                      context.push(
                        '/report-issue',
                        extra: session.id,
                      );
                    },
                    tooltip: 'Report Issue',
                    padding: EdgeInsets.zero,
                    constraints:
                    const BoxConstraints(),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // =========================
              // PERSON
              // =========================

              Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 17,
                    color: AppColors.textSecondary,
                  ),

                  const SizedBox(width: 7),

                  Expanded(
                    child: Text(
                      'with ${_getPersonName()}',
                      style: AppTextStyles.bodyMedium,
                      overflow:
                      TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // =========================
              // DATE + TIME
              // =========================

              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),

                  const SizedBox(width: 7),

                  Text(
                    DateFormatter.formatDate(
                      session.scheduledAt,
                    ),
                    style:
                    AppTextStyles.bodySmall,
                  ),

                  const SizedBox(width: 16),

                  const Icon(
                    Icons.access_time_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),

                  const SizedBox(width: 7),

                  Text(
                    DateFormatter.formatSessionRange(
                      session.scheduledAt,
                      session.durationMinutes,
                    ),
                    style:
                    AppTextStyles.bodySmall,
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // =========================
              // GROUP + PLATFORM
              // =========================

              Row(
                children: [
                  const Icon(
                    Icons.groups_outlined,
                    size: 17,
                    color: AppColors.textSecondary,
                  ),

                  const SizedBox(width: 7),

                  Text(
                    'Group: ${session.groupSize}',
                    style:
                    AppTextStyles.bodySmall,
                  ),

                  const SizedBox(width: 16),

                  const Icon(
                    Icons.video_camera_front_outlined,
                    size: 17,
                    color: AppColors.textSecondary,
                  ),

                  const SizedBox(width: 7),

                  Text(
                    _getPlatformName(
                      session.platform,
                    ),
                    style:
                    AppTextStyles.bodySmall,
                  ),
                ],
              ),

              // =========================
              // NOTES
              // =========================

              if (session.notes != null &&
                  session.notes!.trim().isNotEmpty) ...[
                const SizedBox(height: 10),

                Container(
                  width: double.infinity,
                  padding:
                  const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    borderRadius:
                    BorderRadius.circular(8),
                  ),
                  child: Row(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.notes_outlined,
                        size: 17,
                        color:
                        AppColors.textSecondary,
                      ),

                      const SizedBox(width: 7),

                      Expanded(
                        child: Text(
                          session.notes!,
                          style:
                          AppTextStyles.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // =========================
              // ACTION BUTTON
              // =========================

              const SizedBox(height: 14),

              _buildActionButton(),

              // =========================
              // MARK COMPLETED
              // =========================

              if (widget.isTutor &&
                  (hasEnded ||
                      session.sessionStatus ==
                          SessionStatus.inProgress) &&
                  session.sessionStatus !=
                      SessionStatus.completed &&
                  widget.onMarkCompleted != null) ...[
                const SizedBox(height: 8),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed:
                    widget.onMarkCompleted,
                    icon: const Icon(
                      Icons.check_circle_outline,
                      size: 18,
                    ),
                    label: const Text(
                      'Mark as Completed',
                    ),
                  ),
                ),
              ],

              // =========================
              // MARK DISMISSED
              // =========================

              if (widget.isTutor &&
                  session.sessionStatus ==
                      SessionStatus.scheduled &&
                  widget.onMarkDismissed != null) ...[
                const SizedBox(height: 8),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed:
                    widget.onMarkDismissed,
                    icon: const Icon(
                      Icons.cancel_outlined,
                      size: 18,
                    ),
                    label: const Text(
                      'Mark as Dismissed',
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}