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

  // ── PagingController (infinite_scroll_pagination v5.x) ──────────────────────
  //
  // v5 mein API bilkul alag hai:
  //
  // CONSTRUCTOR:
  //   fetchPage(pageKey)  → yeh function list return karta hai directly
  //   getNextPageKey(state) → null return karo jab sab load ho jaye
  //
  // fetchPage mein hum apna Firestore call karte hain aur List<StudentModel> return karte hain.
  // PagingController khud state manage karta hai — hum AsyncNotifier nahi use karte PagingController ke saath.
  //
  // ARCHITECTURE NOTE:
  // PagingController v5 apna internal state rakhta hai.
  // Isliye hum student pagination ke liye seedha repository call karte hain yahan se.
  // StudentPaginationNotifier is case mein PagingController ke andar nahi aata —
  // dono alag approaches hain:
  //   Option A: PagingController alone (yeh implementation)
  //   Option B: AsyncNotifier alone + ScrollController (guide mein explain kiya gaya)
  late final PagingController<int, StudentModel> _pagingController;

  // Page size — yahi batch size hai
  static const int _pageSize = 20;

  @override
  void initState() {
    super.initState();
    final currentUser = ref.read(authNotifierProvider).currentUser;
    _tutorId = currentUser?.id ?? '';

    _pagingController = PagingController<int, StudentModel>(
      // ── fetchPage: yahan actual data fetch hota hai ───────────────────
      // pageKey = 0 (pehla page), 1 (doosra page), etc.
      // Hum ise use nahi karte directly — Riverpod repository se paginate karte hain
      fetchPage: _fetchStudentsPage,

      // ── getNextPageKey: kya aur pages hain? ──────────────────────────
      // state.lastPageIsEmpty = last page mein koi item nahi aaya = khatam
      // state.nextIntPageKey  = current page number + 1
      getNextPageKey: (state) =>
          state.lastPageIsEmpty ? null : state.nextIntPageKey,
    );
  }

  // ── Actual data fetch function ────────────────────────────────────────────
  // PagingController yeh call karta hai automatically jab next page chahiye
  // pageKey = 0, 1, 2... (hum cursor ke liye Riverpod notifier use karte hain)
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

  // ── Pull-to-refresh ───────────────────────────────────────────────────────
  Future<void> _onRefresh() async {
    ref.invalidate(studentPaginationProvider(_tutorId));
    _pagingController.refresh(); // pageKey = 0 se dobara shuru
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
                        CustomButton(
                          label: 'Upload Session 📚',
                          variant: ButtonVariant.primary,
                          onPressed: () => context.go('/assign-session'),
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

                // ── Students — Infinite Scroll List ──────────────────────────
                // PagedSliverList v5 signature:
                //   state          = pagingController.value (PagingState)
                //   fetchNextPage  = pagingController.fetchNextPage (method ref)
                //   builderDelegate = items/loading/error/empty builders
                PagedSliverList<int, StudentModel>(
                  state: _pagingController.value,
                  fetchNextPage: _pagingController.fetchNextPage,
                  builderDelegate: PagedChildBuilderDelegate<StudentModel>(
                    // ── Har student card ─────────────────────────────────
                    itemBuilder: (context, student, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.paddingM,
                          vertical: 4,
                        ),
                        child: _StudentListTile(student: student),
                      );
                    },

                    // ── Pehle page loading ───────────────────────────────
                    firstPageProgressIndicatorBuilder: (_) => const Padding(
                      padding: EdgeInsets.all(32),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.tutorColor,
                        ),
                      ),
                    ),

                    // ── Next page loading (list end mein) ────────────────
                    newPageProgressIndicatorBuilder: (_) => const Padding(
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

                    // ── Koi student nahi ─────────────────────────────────
                    noItemsFoundIndicatorBuilder: (_) =>
                        const _EmptyStudentsCard(),

                    // ── Error widget + Retry ─────────────────────────────
                    firstPageErrorIndicatorBuilder: (_) => Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 48,
                            color: AppColors.error,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Students load nahi ho sake',
                            style: AppTextStyles.bodyMedium,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => _pagingController.refresh(),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),

                    // ── Sab students load ho gaye ────────────────────────
                    noMoreItemsIndicatorBuilder: (_) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Center(
                        child: Text(
                          '— All students loaded —',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textHint,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // ── Bottom padding ─────────────────────────────────────────────
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
