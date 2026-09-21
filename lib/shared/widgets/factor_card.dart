import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/suitability_factor.dart';

class FactorCard extends StatelessWidget {
  final SuitabilityFactor factor;
  final bool showDetails;
  final VoidCallback? onTap;

  const FactorCard({
    super.key,
    required this.factor,
    this.showDetails = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? theme.dividerColor : AppColors.border,
          width: 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Icon with tinted circular container
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(
                        color: factor.accentColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        factor.icon,
                        color: factor.accentColor,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Factor name & short reason
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            factor.name,
                            style: AppTypography.cardTitle.copyWith(fontSize: 15),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            factor.shortReason,
                            style: AppTypography.bodySmall.copyWith(
                              fontSize: 12,
                              color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Score e.g. 85 / 100
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: '${factor.score}',
                                style: AppTypography.cardTitle.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: isDark ? Colors.white : AppColors.textPrimary,
                                ),
                              ),
                              TextSpan(
                                text: ' / 100',
                                style: AppTypography.labelSmall.copyWith(
                                  color: isDark ? const Color(0xFF64748B) : AppColors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF133520) : AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            factor.assessmentLevel,
                            style: AppTypography.labelSmall.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: isDark ? const Color(0xFF00E676) : AppColors.primaryDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                // Progress bar
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: factor.score / 100.0,
                    backgroundColor: isDark ? const Color(0xFF1E2B23) : AppColors.borderLight,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      factor.score >= 80
                          ? (isDark ? const Color(0xFF00E676) : AppColors.primary)
                          : factor.score >= 65
                              ? AppColors.warning
                              : AppColors.error,
                    ),
                    minHeight: 5,
                  ),
                ),
                // Detailed data if expanded
                if (showDetails) ...[
                  const SizedBox(height: 12),
                  Divider(color: isDark ? theme.dividerColor : AppColors.borderLight, height: 1),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Measured Value:',
                        style: AppTypography.label.copyWith(fontSize: 12),
                      ),
                      Text(
                        factor.metricValue,
                        style: AppTypography.cardTitle.copyWith(fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    factor.fullAssessment,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    factor.impact,
                    style: AppTypography.labelSmall.copyWith(
                      fontSize: 11,
                      color: AppColors.primaryLight,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
