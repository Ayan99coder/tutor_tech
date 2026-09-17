import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tutor_tech/features/auth/authProvider/auth_provider.dart';
import 'package:tutor_tech/features/session/provider/session_provider.dart';
import 'package:tutor_tech/features/student/model/student_model.dart';
import 'package:tutor_tech/features/tutor/provider/tutor_provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/custom_appbar.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/session_card.dart';

class TutorDashboardScreen extends ConsumerStatefulWidget {
  const TutorDashboardScreen({super.key});

  @override
  ConsumerState<TutorDashboardScreen> createState() =>
      _TutorDashboardScreenState();
}

class _TutorDashboardScreenState extends ConsumerState<TutorDashboardScreen> {
  late final ScrollController _scrollController;
  late final String _tutorId;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
    final currentUser = ref.read(authNotifierProvider).currentUser;
    _tutorId = currentUser?.id ?? '';
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  /// Triggered when the user scrolls within 200px of the bottom.
  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final current = _scrollController.position.pixels;
    if (current >= maxScroll - 200) {
      ref.read(tutorProvider(_tutorId).notifier).loadNextPage();
    }
  }

  /// Pull-to-refresh: resets pagination and re-fetches everything.
  Future<void> _onRefresh() async {
    ref.invalidate(tutorProvider(_tutorId));
    try {
      await ref.read(tutorProvider(_tutorId).future);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(tutorProvider(_tutorId));
    final sessionState = ref.watch(tutorSessions(_tutorId));

    return Scaffold(
      body: state.when(
        data: (tutor) {
          final students = tutor.students;
          final isLoadingMore = tutor.isLoadingMore;
          final hasMore = tutor.hasMore;

          return RefreshIndicator(
            color: AppColors.tutorColor,
            backgroundColor: AppColors.surfaceWhite,
            onRefresh: _onRefresh,
            child: CustomScrollView(
              controller: _scrollController,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                CustomSliverAppBar(
                  title: 'Welcome, ${tutor.tutor?.fullName ?? 'Tutor'}',
                  showBackButton: false,
                  showNotificationBell: true,
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimensions.paddingM),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Greeting card ──────────────────────────────
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.tutorColor,
                                Color(0xFF2E8B60),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusL,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Good day, ${tutor.tutor?.fullName ?? ''} 👋',
                                style: AppTextStyles.h2.copyWith(
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                'You have ${sessionState.value?.length ?? 0}'
                                ' active sessions scheduled.',
                                style: AppTextStyles.bodyMedium.copyWith(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // ── Quick actions ──────────────────────────────
                        CustomButton(
                          label: 'Upload Session 📚',
                          variant: ButtonVariant.primary,
                          onPressed: () => context.go('/assign-session'),
                        ),
                        const SizedBox(height: 24),

                        // ── Today's Sessions ───────────────────────────
                        Text("Today's Sessions", style: AppTextStyles.h3),
                        const SizedBox(height: 8),
                        sessionState.when(
                          data: (sessions) {
                            if (sessions.isEmpty) {
                              return const Text('No sessions scheduled.');
                            }
                            return Column(
                              children: sessions.map((s) {
                                final firstStudentId =
                                    s.studentIds.isNotEmpty
                                        ? s.studentIds.first
                                        : '';
                                final matchedStudent = tutor.students
                                    .where(
                                      (st) => st.userId == firstStudentId,
                                    )
                                    .firstOrNull;
                                final studentName =
                                    matchedStudent?.fullName ??
                                        (s.studentIds.length > 1
                                            ? '${s.studentIds.length} students'
                                            : '');

                                return SessionCard(
                                  session: s,
                                  isTutor: true,
                                  tutorName: tutor.tutor?.fullName ?? '',
                                  studentName: studentName,
                                  onMarkCompleted: () {
                                    // TODO: implement mark completed
                                  },
                                  onMarkDismissed: () {
                                    // TODO: implement mark dismissed
                                  },
                                );
                              }).toList(),
                            );
                          },
                          loading: () => const Center(
                            child: CircularProgressIndicator(),
                          ),
                          error: (e, _) => Text(e.toString()),
                        ),
                        const SizedBox(height: 24),

                        // ── Pending Reports ────────────────────────────
                        Text(
                          'Pending Lesson Reports',
                          style: AppTextStyles.h3,
                        ),
                        const SizedBox(height: 24),

                        // ── My Students header ─────────────────────────
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('My Students', style: AppTextStyles.h3),
                            if (students.isNotEmpty)
                              Text(
                                '${students.length}${hasMore ? '+' : ''} students',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // ── Students list ──────────────────────────────
                        if (students.isEmpty && !isLoadingMore)
                          _EmptyStudentsCard()
                        else
                          _StudentCardRow(
                            students: students,
                            tutorSubjects:
                                tutor.tutor?.subjectExpertise ?? [],
                          ),

                        // ── Pagination loading indicator ───────────────
                        if (isLoadingMore)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.tutorColor,
                                ),
                              ),
                            ),
                          ),

                        // ── End of list indicator ──────────────────────
                        if (!hasMore && students.isNotEmpty)
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: Text(
                                '— All students loaded —',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textHint,
                                ),
                              ),
                            ),
                          ),

                        const SizedBox(height: 140),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
              .animate()
              .fade(duration: const Duration(milliseconds: 500))
              .scale(
                begin: const Offset(0.95, 0.95),
                end: const Offset(1.0, 1.0),
                curve: Curves.easeOutCubic,
                duration: const Duration(milliseconds: 500),
              );
        },
        error: (error, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.error,
              ),
              const SizedBox(height: 12),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.invalidate(tutorProvider(_tutorId)),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

// ─── Student Card Row ──────────────────────────────────────────────────────────
class _StudentCardRow extends StatelessWidget {
  const _StudentCardRow({
    required this.students,
    required this.tutorSubjects,
  });

  final List<StudentModel> students;
  final List<String> tutorSubjects;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 155,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: students.length,
        itemBuilder: (context, index) {
          final student = students[index];
          final matchedSubjects = student.selectedSubjects
              .where(
                (subj) => tutorSubjects.any(
                  (exp) =>
                      exp.toLowerCase().trim() == subj.toLowerCase().trim(),
                ),
              )
              .toList();

          return _StudentAvatarCard(
            fullName: student.fullName,
            subjectLabel: matchedSubjects.join(', '),
          );
        },
      ),
    );
  }
}

// ─── Individual Student Card ───────────────────────────────────────────────────
class _StudentAvatarCard extends StatelessWidget {
  const _StudentAvatarCard({
    required this.fullName,
    required this.subjectLabel,
  });

  final String fullName;
  final String subjectLabel;

  @override
  Widget build(BuildContext context) {
    final initial =
        fullName.trim().isNotEmpty ? fullName.trim()[0].toUpperCase() : 'S';

    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surfaceWhite,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.studentColor,
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            fullName,
            style: AppTextStyles.labelLarge,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subjectLabel,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.tutorColor,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── Empty State ───────────────────────────────────────────────────────────────
class _EmptyStudentsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Icon(Icons.people_outline, size: 40, color: AppColors.textHint),
          const SizedBox(height: 8),
          Text(
            'No students found for your subjects',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
