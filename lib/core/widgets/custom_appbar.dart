import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tutor_tech/features/auth/authProvider/auth_provider.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class CustomSliverAppBar extends ConsumerWidget {
  final String title;
  final bool showNotificationBell;
  final int notificationCount;
  final bool showBackButton;
  final bool showLogoutButton;
  final Widget? leading;
  final List<Widget>? actions;

  const CustomSliverAppBar({
    super.key,
    required this.title,
    this.showNotificationBell = false,
    this.notificationCount = 0,
    this.showBackButton = true,
    this.showLogoutButton = true,
    this.leading,
    this.actions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverAppBar(
      backgroundColor: AppColors.surfaceWhite,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      pinned: true,
      floating: true,
      expandedHeight: 80.0,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: const EdgeInsets.only(bottom: 16),
        title: Text(
          title,
          style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
        ),
      ),
      leading:
          leading ??
          (showBackButton && context.canPop()
              ? IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                  onPressed: () => context.pop(),
                )
              : (Scaffold.maybeOf(context)?.hasDrawer == true
                    ? IconButton(
                        icon: const Icon(
                          Icons.menu_rounded,
                          color: AppColors.textPrimary,
                          size: 26,
                        ),
                        onPressed: () => Scaffold.of(context).openDrawer(),
                      )
                    : null)),
      actions: [
        if (actions != null) ...actions!,
        if (showNotificationBell)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: Stack(
              alignment: Alignment.center,
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.notifications_outlined,
                    color: AppColors.textPrimary,
                    size: 24,
                  ),
                  onPressed: () {},
                ),
                if (notificationCount > 0)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.error,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '$notificationCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        if (showLogoutButton)
          IconButton(
            icon: const Icon(
              Icons.logout_rounded,
              color: AppColors.textPrimary,
            ),
            tooltip: 'Logout',
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirm Sign Out'),
                  content: const Text(
                    'Are you sure you want to log out of Tutor Tutors?',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                await ref.read(authNotifierProvider.notifier).signOut();
                if (context.mounted) {
                  context.go('/login');
                }
              }
            },
          ),
      ],
    );
  }
}
