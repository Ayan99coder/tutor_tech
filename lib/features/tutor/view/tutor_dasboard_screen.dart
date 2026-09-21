import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:tutor_tech/features/auth/authProvider/auth_provider.dart';
import 'package:tutor_tech/features/session/provider/session_provider.dart';
import 'package:tutor_tech/features/student/model/student_model.dart';
import 'package:tutor_tech/features/student/provider/student_provider.dart';
import 'package:tutor_tech/features/tutor/provider/tutor_provider.dart';
import 'package:tutor_tech/features/tutor/view/show_groups_alert_box.dart';

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
  late final String _tutorId;

  late final PagingController<int, StudentModel> _pagingController;
  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    final currentUser = ref.read(authNotifierProvider).currentUser;
    _tutorId = currentUser?.id ?? '';

    _pagingController = PagingController<int, StudentModel>(

      fetchPage: _fetchStudentsPage,
      getNextPageKey: (state) =>
          state.lastPageIsEmpty ? null : state.nextIntPageKey,
    );
  }
  Future<List<StudentModel>> _fetchStudentsPage(int pageKey) async {
    // Riverpod notifier se next page lo
    // pageKey == 0 → pehla page (notifier fresh build() chalega)
    // pageKey > 0  → next page (notifier apna cursor remember karta hai)
    if (pageKey == 0) {
      // Fresh start: Riverpod state reset karo
      ref.invalidate(studentPaginationProvider(_tutorId));
    }

    // Notifier se page load karo aur wait karo
    await ref
        .read(studentPaginationProvider(_tutorId).notifier)
        .loadNextPage();

    // Riverpod state se students nikalo
    final paginationState =
        ref.read(studentPaginationProvider(_tutorId)).valueOrNull;

    if (paginationState == null) return [];

    // Is page ke naye students nikalo
    // Total students mein se pehle wale pageKey * _pageSize skip karo
    final startIndex = pageKey * _pageSize;
    final allStudents = paginationState.students;

    if (startIndex >= allStudents.length) return [];

    return allStudents.sublist(startIndex);
  }


  Future<void> _onRefresh() async {ref.invalidate(tutorProvider(_tutorId));
    ref.invalidate(studentPaginationProvider(_tutorId));
    _pagingController.refresh();
  }

  @override
  Widget build(BuildContext context) {
    final tutorAsync = ref.watch(tutorProvider(_tutorId));
    final sessionState = ref.watch(tutorSessions(_tutorId));

    return Scaffold(
      body: tutorAsync.when(
        data: (tutor) {
          return RefreshIndicator(
            color: AppColors.tutorColor,
            backgroundColor: AppColors.surfaceWhite,
            onRefresh: _onRefresh,
            child: CustomScrollView(
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
                        // ── Greeting card ────────────────────────────────
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

                        // ── Quick actions ────────────────────────────────
                        Row(
                          children: [
                            // Upload Session Button
                            Expanded(
                              child: CustomButton(
                                label: 'Upload Session 📚',
                                variant: ButtonVariant.primary,
                                onPressed: () => context.go('/assign-session'),
                              ),
                            ),

                            const SizedBox(width: 12),

                            // Create Group Button
                            Expanded(
                              child: CustomButton(
                                label: 'Create Group 👥',
                                variant: ButtonVariant.primary,
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return StudentGroupManagement(
                                        tutorId: _tutorId,
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // ── Today's Sessions ─────────────────────────────
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
                                final matchedStudent = tutor.stdByTutor
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
                                  onMarkCompleted: () {},
                                  onMarkDismissed: () {},
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

                        // ── Pending Reports ──────────────────────────────
                        Text(
                          'Pending Lesson Reports',
                          style: AppTextStyles.h3,
                        ),
                        const SizedBox(height: 24),

                        // ── My Students header ───────────────────────────
                        Text('My Students', style: AppTextStyles.h3),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),


                PagingListener<int, StudentModel>(
                  controller: _pagingController,
                  builder: (context, state, fetchNextPage) {
                    return PagedSliverList<int, StudentModel>(
                      state: state,
                      fetchNextPage: fetchNextPage,

                      builderDelegate: PagedChildBuilderDelegate<StudentModel>(
                        itemBuilder: (context, student, index) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppDimensions.paddingM,
                              vertical: 4,
                            ),
                            child: _StudentListTile(student: student),
                          );
                        },

                        firstPageProgressIndicatorBuilder: (_) =>
                        const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.tutorColor,
                          ),
                        ),

                        noItemsFoundIndicatorBuilder: (_) =>
                        const _EmptyStudentsCard(),

                        firstPageErrorIndicatorBuilder: (_) => Center(
                          child: ElevatedButton(
                            onPressed: _pagingController.refresh,
                            child: const Text('Retry'),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 140)),
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

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }
}

// ─── Individual Student List Tile ──────────────────────────────────────────────
class _StudentListTile extends StatelessWidget {
  const _StudentListTile({required this.student});

  final StudentModel student;

  @override
  Widget build(BuildContext context) {
    final initial = student.fullName.trim().isNotEmpty
        ? student.fullName.trim()[0].toUpperCase()
        : 'S';

    return Container(
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
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.studentColor,
            child: Text(
              initial,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student.fullName,
                  style: AppTextStyles.labelLarge,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (student.selectedSubjects.isNotEmpty)
                  Text(
                    student.selectedSubjects.join(', '),
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.tutorColor,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Empty State ───────────────────────────────────────────────────────────────
class _EmptyStudentsCard extends StatelessWidget {
  const _EmptyStudentsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(AppDimensions.paddingM),
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
            'No students assigned yet',
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
