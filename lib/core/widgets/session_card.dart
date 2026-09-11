import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tutor_tech/core/widgets/status_badge.dart';

import '../../features/session/modal/session_modal.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_text_styles.dart';
import '../utils/utils/date_formatter.dart';
import '../utils/utils/session_status_helper.dart';
import 'custom_button.dart';

class SessionCard extends StatefulWidget {
  final SessionModel session;
  final String tutorName;
  final String studentName;
  final String subjectEmoji;
  final VoidCallback? onTap;
  final VoidCallback? onJoinZoom;
  final VoidCallback? onStartSession;
  final VoidCallback? onMarkCompleted;
  final VoidCallback? onMarkDismissed;
  final bool showJoinButton;
  final bool isTutor;

  const SessionCard({
    super.key,
    required this.session,
    required this.tutorName,
    required this.studentName,
    this.subjectEmoji = '📚',
    this.onTap,
    this.onJoinZoom,
    this.onStartSession,
    this.onMarkCompleted,
    this.onMarkDismissed,
    this.showJoinButton = false,
    this.isTutor = false,
  });

  @override
  State<SessionCard> createState() => _SessionCardState();
}

class _SessionCardState extends State<SessionCard> {
  Timer? _countdownTimer;

  @override
  void initState() {
    super.initState();

    if (widget.showJoinButton) {
      _startTimer();
    }
  }

  @override
  void didUpdateWidget(SessionCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.showJoinButton && _countdownTimer == null) {
      _startTimer();
    } else if (!widget.showJoinButton && _countdownTimer != null) {
      _stopTimer();
    }
  }

  void _startTimer() {
    _countdownTimer?.cancel();

    _countdownTimer = Timer.periodic(
      const Duration(seconds: 30),
          (_) {
        if (mounted) {
          setState(() {});
        }
      },
    );
  }

  void _stopTimer() {
    _countdownTimer?.cancel();
    _countdownTimer = null;
  }

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
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

  String get _displayTutorName {
    final name = widget.tutorName.trim();

    if (name.isEmpty ||
        name == 'Assigned Tutor' ||
        name.contains('Sarah Ahmed') ||
        name.contains('Tariq Mansoor')) {
      return 'Pending Tutor';
    }

    return name;
  }

  @override
  Widget build(BuildContext context) {
    // Status is calculated from the current time.
    final currentStatus = calculateSessionStatus(widget.session);

    final statusColor = _getStatusColor(currentStatus);
    final statusLabel = _getStatusLabel(currentStatus);

    return RepaintBoundary(
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceWhite,
            borderRadius: BorderRadius.circular(
              AppDimensions.radiusCard,
            ),
            border: Border.all(
              color: AppColors.border,
              width: 1.0,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --------------------------------------------------
              // TOP ROW
              // --------------------------------------------------
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.subjectEmoji,
                        style: const TextStyle(fontSize: 24),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.session.subject
                            .toUpperCase()
                            .replaceAll('_', ' '),
                        style: AppTextStyles.h4,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      StatusBadge(
                        label: statusLabel,
                        color: statusColor,
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(
                          Icons.flag_outlined,
                          color: AppColors.textHint,
                          size: 20,
                        ),
                        onPressed: () => context.push(
                          '/report-issue',
                          extra: widget.session.id,
                        ),
                        tooltip: 'Report Issue',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // --------------------------------------------------
              // TUTOR / STUDENT
              // --------------------------------------------------
              Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    widget.isTutor
                        ? 'with ${widget.studentName.isEmpty ? "Student" : widget.studentName}'
                        : 'with $_displayTutorName',
                    style: AppTextStyles.bodyMedium,
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // --------------------------------------------------
              // DATE + TIME
              // --------------------------------------------------
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    DateFormatter.formatDate(
                      widget.session.scheduledAt,
                    ),
                    style: AppTextStyles.bodySmall,
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.access_time_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    DateFormatter.formatSessionRange(
                      widget.session.scheduledAt,
                      90,
                    ),
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // --------------------------------------------------
              // GROUP SIZE
              // --------------------------------------------------
              Row(
                children: [
                  const Icon(
                    Icons.groups_outlined,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Group: ${widget.session.groupSize}',
                    style: AppTextStyles.bodySmall,
                  ),
                ],
              ),

              // --------------------------------------------------
              // ACTION BUTTONS
              // --------------------------------------------------
              if (widget.showJoinButton) ...[
                const SizedBox(height: 14),
                Builder(
                  builder: (context) {
                    final now = DateTime.now();

                    final startTime = widget.session.scheduledAt;

                    // Session duration is currently fixed at 90 minutes.
                    final endTime = startTime.add(
                      const Duration(minutes: 90),
                    );

                    final minutesRemaining =
                        startTime.difference(now).inMinutes;

                    // Join becomes available 10 minutes before
                    // the scheduled start time.
                    final canJoin =
                        now.isAfter(
                          startTime.subtract(
                            const Duration(minutes: 10),
                          ),
                        ) &&
                            now.isBefore(
                              endTime.add(
                                const Duration(hours: 1),
                              ),
                            );

                    final hasEnded = now.isAfter(endTime);

                    // --------------------------------------------------
                    // TUTOR: MARK COMPLETED AFTER SESSION ENDS
                    // --------------------------------------------------
                    if (hasEnded &&
                        widget.isTutor &&
                        currentStatus != SessionStatus.completed) {
                      return CustomButton(
                        label: 'Mark as Completed',
                        onPressed: widget.onMarkCompleted,
                        variant: ButtonVariant.outline,
                        icon: Icons.check_circle_outline,
                      );
                    }

                    // --------------------------------------------------
                    // COMPLETED / CANCELLED
                    // --------------------------------------------------
                    if (currentStatus == SessionStatus.completed ||
                        currentStatus == SessionStatus.cancelled) {
                      return const SizedBox.shrink();
                    }

                    // --------------------------------------------------
                    // JOIN BUTTON LABEL
                    // --------------------------------------------------
                    String buttonLabel;

                    if (canJoin) {
                      buttonLabel = widget.isTutor
                          ? 'Start Session (Host)'
                          : 'Join Zoom Session 📹';
                    } else {
                      buttonLabel =
                      'Join Zoom (Opens in ${minutesRemaining > 0 ? "$minutesRemaining mins" : "10 mins"}) 🔒';
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // --------------------------------------------------
                        // JOIN / START BUTTON
                        // --------------------------------------------------
                        CustomButton(
                          label: buttonLabel,
                          onPressed: canJoin
                              ? (widget.isTutor
                              ? (widget.onStartSession ??
                              widget.onJoinZoom)
                              : widget.onJoinZoom)
                              : null,
                          variant: canJoin
                              ? ButtonVariant.primary
                              : ButtonVariant.outline,
                          icon: canJoin
                              ? Icons.video_call
                              : Icons.lock_clock,
                        ),

                        // --------------------------------------------------
                        // LOCKED MESSAGE
                        // --------------------------------------------------
                        if (!canJoin) ...[
                          const SizedBox(height: 4),
                          const Text(
                            'ℹ️ Zoom meeting link unlocks 10 minutes before scheduled start time.',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textHint,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],

                        // --------------------------------------------------
                        // TUTOR: MARK COMPLETE / DISMISSED
                        // --------------------------------------------------
                        if (widget.isTutor &&
                            currentStatus == SessionStatus.scheduled &&
                            (widget.onMarkCompleted != null ||
                                widget.onMarkDismissed != null)) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              if (widget.onMarkCompleted != null)
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: widget.onMarkCompleted,
                                    icon: const Icon(
                                      Icons.check_circle,
                                      size: 16,
                                      color: AppColors.success,
                                    ),
                                    label: const Text(
                                      'Mark Complete',
                                      style: TextStyle(
                                        color: AppColors.success,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: AppColors.success,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                    ),
                                  ),
                                ),

                              if (widget.onMarkCompleted != null &&
                                  widget.onMarkDismissed != null)
                                const SizedBox(width: 8),

                              if (widget.onMarkDismissed != null)
                                Expanded(
                                  child: OutlinedButton.icon(
                                    onPressed: widget.onMarkDismissed,
                                    icon: const Icon(
                                      Icons.cancel,
                                      size: 16,
                                      color: AppColors.error,
                                    ),
                                    label: const Text(
                                      'Mark Dismissed',
                                      style: TextStyle(
                                        color: AppColors.error,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: AppColors.error,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ],
                    );
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}