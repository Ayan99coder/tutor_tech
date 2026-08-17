import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tutor_tech/core/constants/app_colors.dart';
import 'package:tutor_tech/features/auth/provider/auth_provider.dart';

import '../../features/auth/modal/usermodal.dart';
import '../constants/app_text_styles.dart';

class CustomAppbar extends ConsumerWidget implements PreferredSizeWidget {

  final String title;
  final bool showNotificationBell;
  final int notificationCount;
  final bool showBackButton;
  final bool showLogoutButton;
  final Widget? leading;
  final List<Widget>? actions;

  const CustomAppbar({
    super.key,
    required this.title,
    this.showNotificationBell = false,
    this.notificationCount = 0,
    this.showBackButton = true,
    this.showLogoutButton = false,
    this.leading,
    this.actions,
  });
  @override
  Size get preferredSize => const Size.fromHeight(80.0);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AppBar(
      toolbarHeight: 80.0,
      backgroundColor: AppColors.surfaceWhite,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      title: Padding(
        padding: const EdgeInsets.only(top: 16.0),
        child: Text(
          title,
          style: AppTextStyles.h3.copyWith(color: AppColors.textPrimary),
        ),
      ),
      leading: leading ??
          (showBackButton
              ? Padding(
            padding: const EdgeInsets.only(top: 16.0, left: 4.0),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary, size: 22),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  final role = ref.read(authViewModelProvider).currentUser?.role;
                  if (role == UserRole.student) {
                    context.go('/student-dashboard');
                  } else if (role == UserRole.tutor) {
                    context.go('/tutor-dashboard');
                  } else if (role == UserRole.parent) {
                    context.go('/parent-dashboard');
                  } else {
                    context.go('/admin');
                  }
                }
              },
            ),
          )
              : (Scaffold.maybeOf(context)?.hasDrawer == true
              ? Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: IconButton(
              icon: const Icon(Icons.menu_rounded, color: AppColors.textPrimary, size: 26),
              onPressed: () => Scaffold.of(context).openDrawer(),
            ),
          )
              : null)),
      actions: [
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (actions != null) ...actions!,
              if (showNotificationBell)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary, size: 24),
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
                  icon: const Icon(Icons.logout_rounded, color: AppColors.textPrimary),
                  tooltip: 'Logout',
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirm Sign Out'),
                        content: const Text('Are you sure you want to log out of SmartLearn Academy?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Logout', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      await ref.read(authViewModelProvider.notifier).logout();
                      if (context.mounted) {
                        context.go('/login');
                      }
                    }
                  },
                ),
            ],
          ),
        ),
      ],
    );
  }
}
