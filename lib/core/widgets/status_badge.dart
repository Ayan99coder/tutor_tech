import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
  });

  factory StatusBadge.fromStatus(String status) {
    final s = status.toLowerCase();
    Color color;
    switch (s) {
      case 'scheduled':
        color = AppColors.info; // Blue
        break;
      case 'completed':
      case 'approved':
        color = AppColors.secondary; // Emerald
        break;
      case 'cancelled':
      case 'rejected':
        color = AppColors.error; // Red
        break;
      case 'pending':
        color = AppColors.accent; // Amber
        break;
      default:
        color = AppColors.textSecondary;
    }
    return StatusBadge(
      label: status[0].toUpperCase() + status.substring(1),
      color: color,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
