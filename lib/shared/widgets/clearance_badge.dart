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
    final bgColor = isCompatible ? AppColors.primarySurface : AppColors.warningLight;
    final borderColor = isCompatible ? AppColors.primaryLight : AppColors.warning;
    final iconColor = isCompatible ? AppColors.primary : AppColors.warning;

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
              color: Colors.white,
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
                        color: isCompatible ? AppColors.primaryDark : AppColors.warning,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        isCompatible ? 'Compatible' : 'Warning',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isCompatible ? AppColors.primary : AppColors.warning,
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
                    color: AppColors.textPrimary,
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
