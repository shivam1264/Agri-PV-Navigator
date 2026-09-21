import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class ClearanceBadge extends StatelessWidget {
  final bool isCompatible;
  final String title;
  final String details;

  const ClearanceBadge({
    super.key,
    required this.isCompatible,
    this.title = 'Machinery Clearance Check',
    this.details = 'Tractor (2.5 m) | Harvester (3.0 m)',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isCompatible
        ? (isDark ? const Color(0xFF133520) : AppColors.primarySurface)
        : (isDark ? const Color(0xFF332510) : AppColors.warningLight);
    final borderColor = isCompatible
        ? (isDark ? const Color(0xFF1B5E30) : AppColors.primaryLight)
        : (isDark ? const Color(0xFF6E4E10) : AppColors.warning);
    final iconColor = isCompatible
        ? (isDark ? const Color(0xFF00E676) : AppColors.primary)
        : (isDark ? const Color(0xFFFBBF24) : AppColors.warning);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor.withValues(alpha: 0.4), width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF0C130F) : Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: borderColor.withValues(alpha: 0.3)),
            ),
            child: Icon(
              isCompatible ? Icons.check_rounded : Icons.warning_amber_rounded,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: AppTypography.cardTitle.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isCompatible
                            ? (isDark ? const Color(0xFFB9F6CA) : AppColors.primaryDark)
                            : (isDark ? const Color(0xFFFDE68A) : AppColors.warning),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF0C130F) : Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isCompatible ? 'Compatible' : 'Warning',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: iconColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  details,
                  style: AppTypography.bodySmall.copyWith(
                    fontSize: 12,
                    color: isDark ? const Color(0xFFCBD5E1) : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
