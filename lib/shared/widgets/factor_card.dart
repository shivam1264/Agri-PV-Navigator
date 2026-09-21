import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/suitability_factor.dart';

class FactorCard extends StatefulWidget {
  final SuitabilityFactor factor;
  final int? weightPercent;

  const FactorCard({
    super.key,
    required this.factor,
    this.weightPercent,
  });

  @override
  State<FactorCard> createState() => _FactorCardState();
}

class _FactorCardState extends State<FactorCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final factor = widget.factor;
    final weight = widget.weightPercent;

    Widget expandedBody; // hoisted only to satisfy the widget tree layout below
    expandedBody = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        Divider(color: isDark ? theme.dividerColor : AppColors.borderLight, height: 1),
        const SizedBox(height: 10),
        _detailRow('Measured', factor.metricValue, isDark),
        _detailRow('Assessment', factor.fullAssessment, isDark),
        _detailRow('Impact', factor.impact, isDark),
        if (weight != null) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.tune_rounded, size: 13, color: AppColors.textSecondary),
              const SizedBox(width: 6),
              Text(
                'Weight: $weight% of overall score',
                style: AppTypography.labelSmall.copyWith(
                  fontSize: 11,
                  color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ],
    );

    return Material(
      color: isDark ? theme.cardColor : AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => setState(() => _expanded = !_expanded),
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isDark ? theme.dividerColor : AppColors.border,
              width: 1.0,
            ),
          ),
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
                    // Score e.g. 85 / 100 + expand chevron
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
                    const SizedBox(width: 6),
                    Icon(
                      _expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: isDark ? const Color(0xFF94A3B8) : AppColors.textTertiary,
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
                if (_expanded) expandedBody,
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 78,
            child: Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                fontSize: 11,
                color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodySmall.copyWith(fontSize: 12.5),
            ),
          ),
        ],
      ),
    );
  }
}