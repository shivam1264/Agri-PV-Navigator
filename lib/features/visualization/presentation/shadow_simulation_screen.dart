import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/painters/shadow_simulation_painter.dart';

class ShadowSimulationScreen extends StatefulWidget {
  const ShadowSimulationScreen({super.key});

  @override
  State<ShadowSimulationScreen> createState() => _ShadowSimulationScreenState();
}

class _ShadowSimulationScreenState extends State<ShadowSimulationScreen> {
  double _timeOfDayHour = 10.0; // 6.0 to 18.0

  // Calculate dynamic shaded area % based on time of day
  // Noon has lowest shadow, morning and late afternoon have longest shadows
  int get _shadedAreaPercent {
    final distFromNoon = (_timeOfDayHour - 12.0).abs();
    final pct = 15.0 + (distFromNoon * 4.5);
    return pct.round().clamp(14, 45);
  }

  String get _timeFormatted {
    final hour = _timeOfDayHour.toInt();
    if (hour == 12) return '12:00 PM';
    if (hour > 12) return '${hour - 12}:00 PM';
    return '$hour:00 AM';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Shadow Simulation',
          style: AppTypography.screenHeading.copyWith(fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/ar-3d-view'),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Dynamic Solar & Crop Shadow Visual Canvas
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border, width: 1.5),
                    boxShadow: const [
                      BoxShadow(
                        color: AppColors.shadow,
                        blurRadius: 10,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(17),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: CustomPaint(
                            painter: ShadowSimulationPainter(
                              timeOfDayHour: _timeOfDayHour,
                              rowSpacing: 6.0,
                            ),
                          ),
                        ),

                        // Time pill overlay on top left
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.wb_sunny_rounded, color: AppColors.solar, size: 14),
                                const SizedBox(width: 5),
                                Text(
                                  'Sun Position: $_timeFormatted',
                                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Shaded area percentage pill on top right
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: AppColors.primaryDark.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              'Crop Shaded: $_shadedAreaPercent%',
                              style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Time-of-Day Slider Controls & Impact Metrics
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 6.0),
              child: AppCard(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.schedule_rounded, size: 18, color: AppColors.textSecondary),
                            const SizedBox(width: 6),
                            Text(
                              'Time of Day',
                              style: AppTypography.cardTitle.copyWith(fontSize: 14),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primarySurface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.primaryLight.withValues(alpha: 0.3)),
                          ),
                          child: Text(
                            _timeFormatted,
                            style: AppTypography.cardTitle.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Slider
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.primary,
                        inactiveTrackColor: AppColors.borderLight,
                        thumbColor: AppColors.primary,
                        trackHeight: 4.0,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                      ),
                      child: Slider(
                        value: _timeOfDayHour,
                        min: 6.0,
                        max: 18.0,
                        divisions: 12,
                        onChanged: (val) => setState(() => _timeOfDayHour = val),
                      ),
                    ),

                    // Slider Tick Labels (6 AM, 9 AM, 12 PM, 3 PM, 6 PM)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('6 AM', style: TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                          Text('9 AM', style: TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                          Text('12 PM', style: TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                          Text('3 PM', style: TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                          Text('6 PM', style: TextStyle(fontSize: 10, color: AppColors.textTertiary)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1, color: AppColors.borderLight),
                    const SizedBox(height: 12),

                    // Microclimate benefits row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildBenefitItem('94%', 'PAR Light Retained'),
                        Container(height: 24, width: 1, color: AppColors.border),
                        _buildBenefitItem('-22%', 'Water Evaporation'),
                        Container(height: 24, width: 1, color: AppColors.border),
                        _buildBenefitItem('+2.5°C', 'Summer Cooling'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Instruction subtitle
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 4.0),
              child: Text(
                'See how shadows move throughout the day and their impact on crops.',
                style: AppTypography.labelSmall.copyWith(
                  fontSize: 11,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            // Navigation Buttons (< Previous, Next →)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: '‹ Previous',
                      variant: AppButtonVariant.outline,
                      onPressed: () => context.go('/ar-3d-view'),
                      height: 46,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      text: 'Next ›',
                      variant: AppButtonVariant.primary,
                      onPressed: () => context.go('/compare-designs'),
                      height: 46,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.cardTitle.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(fontSize: 10),
        ),
      ],
    );
  }
}
