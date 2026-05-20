import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

enum ButtonVariant { primary, secondary, outline, text }

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final bool isLoading;
  final bool isFullWidth;
  final double? width;
  final double height;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const CustomButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = ButtonVariant.primary,
    this.isLoading = false,
    this.isFullWidth = true,
    this.width,
    this.height = 52,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final bool disabled = onPressed == null || isLoading;

    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: height,
      child: _buildButton(disabled),
    );
  }

  Widget _buildButton(bool disabled) {
    switch (variant) {
      case ButtonVariant.primary:
        return ElevatedButton(
          onPressed: disabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: disabled ? AppColors.textHint : AppColors.primary,
            foregroundColor: AppColors.textOnPrimary,
            elevation: disabled ? 0 : 2,
            shadowColor: AppColors.primary.withValues(alpha: 0.3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _buildChild(AppColors.textOnPrimary),
        );

      case ButtonVariant.secondary:
        return ElevatedButton(
          onPressed: disabled ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryLight.withValues(alpha: 0.15),
            foregroundColor: AppColors.primary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _buildChild(AppColors.primary),
        );

      case ButtonVariant.outline:
        return OutlinedButton(
          onPressed: disabled ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: BorderSide(
              color: disabled ? AppColors.textHint : AppColors.primary,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _buildChild(AppColors.primary),
        );

      case ButtonVariant.text:
        return TextButton(
          onPressed: disabled ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: AppColors.primary,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: _buildChild(AppColors.primary),
        );
    }
  }

  Widget _buildChild(Color color) {
    if (isLoading) {
      return SizedBox(
        width: 22,
        height: 22,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: color,
        ),
      );
    }

    if (prefixIcon == null && suffixIcon == null) {
      return Text(
        label,
        style: AppTextStyles.labelLarge.copyWith(color: color),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (prefixIcon != null) ...[prefixIcon!, const SizedBox(width: 8)],
        Text(label, style: AppTextStyles.labelLarge.copyWith(color: color)),
        if (suffixIcon != null) ...[const SizedBox(width: 8), suffixIcon!],
      ],
    );
  }
}
