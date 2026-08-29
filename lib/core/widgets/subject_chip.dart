import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_text_styles.dart';

class SubjectChip extends StatelessWidget {
  final String emoji;
  final String displayName;
  final Color stageColor;
  final bool isSelected;
  final VoidCallback? onTap;

  const SubjectChip({
    super.key,
    required this.emoji,
    required this.displayName,
    this.stageColor = AppColors.primaryStage,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? stageColor.withValues(alpha: 0.15)
              : AppColors.surfaceCard,
          border: Border.all(
            color: isSelected ? stageColor : AppColors.border,
            width: isSelected ? 1.5 : 1.0,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusM),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(
              displayName,
              style: AppTextStyles.bodyMedium.copyWith(
                color: isSelected ? AppColors.textPrimary : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
