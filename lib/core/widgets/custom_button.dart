import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_dimensions.dart';
import '../constants/app_text_styles.dart';

enum ButtonVariant { primary, secondary, outline, danger }

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final ButtonVariant variant;
  final double? width;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.variant = ButtonVariant.primary,
    this.width,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = onPressed == null || isLoading;

    Color bgColor;
    Color textColor;
    BorderSide borderSide = BorderSide.none;

    switch (variant) {
      case ButtonVariant.primary:
        bgColor = isDisabled
            ? AppColors.secondary.withValues(alpha: 0.4)
            : AppColors.secondary;
        textColor = Colors.white;
        break;
      case ButtonVariant.secondary:
        bgColor = isDisabled
            ? AppColors.primary.withValues(alpha: 0.4)
            : AppColors.primary;
        textColor = Colors.white;
        break;
      case ButtonVariant.outline:
        bgColor = Colors.transparent;
        textColor = isDisabled
            ? AppColors.primary.withValues(alpha: 0.4)
            : AppColors.primary;
        borderSide = BorderSide(
          color: isDisabled
              ? AppColors.primary.withValues(alpha: 0.4)
              : AppColors.primary,
          width: 1.5,
        );
        break;
      case ButtonVariant.danger:
        bgColor = isDisabled
            ? AppColors.error.withValues(alpha: 0.4)
            : AppColors.error;
        textColor = Colors.white;
        break;
    }

    return SizedBox(
      width: width ?? double.infinity,
      height: AppDimensions.buttonHeight,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: textColor,
          elevation: 0,
          side: borderSide,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusM),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onPressed: isDisabled ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, size: 20, color: textColor),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      label,
                      style: AppTextStyles.button.copyWith(color: textColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
