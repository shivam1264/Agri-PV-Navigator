import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../engine/sun_simulation_controller.dart';

class SunTimeSlider extends StatefulWidget {
  final SunSimulationController sunController;
  final bool showPlayButton;

  const SunTimeSlider({
    super.key,
    required this.sunController,
    this.showPlayButton = true,
  });

  @override
  State<SunTimeSlider> createState() => _SunTimeSliderState();
}

class _SunTimeSliderState extends State<SunTimeSlider> {
  Timer? _playbackTimer;

  @override
  void initState() {
    super.initState();
    widget.sunController.addListener(_onSunUpdated);
  }

  @override
  void didUpdateWidget(covariant SunTimeSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sunController != widget.sunController) {
      oldWidget.sunController.removeListener(_onSunUpdated);
      widget.sunController.addListener(_onSunUpdated);
    }
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    widget.sunController.removeListener(_onSunUpdated);
    super.dispose();
  }

  void _onSunUpdated() {
    if (mounted) setState(() {});
  }

  void _togglePlayback() {
    setState(() {
      widget.sunController.isPlaying = !widget.sunController.isPlaying;
      if (widget.sunController.isPlaying) {
        _playbackTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
          var nextTime = widget.sunController.timeOfDayHour + 0.1;
          if (nextTime > 18.0) nextTime = 6.0;
          widget.sunController.timeOfDayHour = nextTime;
        });
      } else {
        _playbackTimer?.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final sun = widget.sunController;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border, width: 1.2),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Time Header & Irradiance Metric
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.wb_sunny_rounded,
                    color: sun.timeOfDayHour < 8 || sun.timeOfDayHour > 16
                        ? const Color(0xFFFF9800)
                        : const Color(0xFFFBC02D),
                    size: 20,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    sun.formattedTime,
                    style: AppTypography.cardTitle.copyWith(fontSize: 14, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.primarySurface,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      '${sun.solarIrradianceWm2.toInt()} W/m²',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '| Alt: ${sun.solarAltitudeDeg.toInt()}°',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Slider + Play Button Row
          Row(
            children: [
              if (widget.showPlayButton) ...[
                IconButton(
                  onPressed: _togglePlayback,
                  icon: Icon(
                    sun.isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
                    color: AppColors.primary,
                    size: 32,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 5,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 9),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
                    activeTrackColor: AppColors.primary,
                    inactiveTrackColor: AppColors.border,
                    thumbColor: AppColors.primary,
                  ),
                  child: Slider(
                    value: sun.timeOfDayHour,
                    min: 6.0,
                    max: 18.0,
                    divisions: 48, // 15-minute intervals
                    onChanged: (val) {
                      sun.timeOfDayHour = val;
                    },
                  ),
                ),
              ),
            ],
          ),

          // Quick Time Chips
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [6.0, 9.0, 12.0, 15.0, 18.0].map((hour) {
              final isSelected = (sun.timeOfDayHour - hour).abs() < 0.75;
              final label = hour == 6.0
                  ? '6 AM'
                  : hour == 9.0
                      ? '9 AM'
                      : hour == 12.0
                          ? '12 PM'
                          : hour == 15.0
                              ? '3 PM'
                              : '6 PM';

              return GestureDetector(
                onTap: () {
                  sun.timeOfDayHour = hour;
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : AppColors.surfaceSecondary,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : AppColors.textSecondary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
