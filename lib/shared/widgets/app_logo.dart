import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showTagline;
  final bool horizontal;

  const AppLogo({
    super.key,
    this.size = 72,
    this.showTagline = false,
    this.horizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    final logoIcon = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.25),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'W',
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.5,
            fontWeight: FontWeight.w800,
            fontFamily: 'Inter',
            letterSpacing: -1,
          ),
        ),
      ),
    );

    final textContent = Column(
      crossAxisAlignment:
          horizontal ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Walisan',
          style: AppTextStyles.displayMedium.copyWith(
            color: AppColors.primary,
            letterSpacing: -0.5,
          ),
        ),
        if (showTagline) ...[
          const SizedBox(height: 2),
          Text(
            'Solusi Keuangan Anda',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );

    if (horizontal) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          logoIcon,
          const SizedBox(width: 12),
          textContent,
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        logoIcon,
        const SizedBox(height: 16),
        textContent,
      ],
    );
  }
}
