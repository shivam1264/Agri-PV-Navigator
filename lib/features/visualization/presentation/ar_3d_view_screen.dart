import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/painters/agrivoltaic_3d_painter.dart';

class Ar3dViewScreen extends StatefulWidget {
  const Ar3dViewScreen({super.key});

  @override
  State<Ar3dViewScreen> createState() => _Ar3dViewScreenState();
}

class _Ar3dViewScreenState extends State<Ar3dViewScreen> {
  bool _isArView = false;
  double _rotationAngle = 0.35;
  double _zoom = 1.0;
  double _timeOfDay = 10.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          '3D / AR Visualization',
          style: AppTypography.screenHeading.copyWith(fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/agri-pv-design'),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Segmented Mode Selector [3D View] | [AR View]
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Container(
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.surfaceSecondary,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isArView = false),
                        child: Container(
                          decoration: BoxDecoration(
                            color: !_isArView ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Center(
                            child: Text(
                              '3D View',
                              style: TextStyle(
                                color: !_isArView ? Colors.white : AppColors.textSecondary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isArView = true),
                        child: Container(
                          decoration: BoxDecoration(
                            color: _isArView ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Center(
                            child: Text(
                              'AR View',
                              style: TextStyle(
                                color: _isArView ? Colors.white : AppColors.textSecondary,
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Main Interactive 3D / AR Canvas
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: AppColors.border, width: 1.5),
                    color: Colors.white,
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
                        // If AR View mode
                        if (_isArView)
                          Container(
                            color: Colors.black87,
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.camera_alt_outlined, color: Colors.white70, size: 54),
                                  const SizedBox(height: 12),
                                  Text(
                                    'AR Camera Active',
                                    style: AppTypography.cardTitle.copyWith(color: Colors.white),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Point phone camera at your field to superimpose Agri-PV stilt pillars.',
                                    style: AppTypography.bodySmall.copyWith(color: Colors.white60),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 20),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.8),
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: const Text(
                                      'Surface Detected (Ground Plane)',
                                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        else
                          // 3D Canvas with drag rotation
                          GestureDetector(
                            onPanUpdate: (details) {
                              setState(() {
                                _rotationAngle += details.delta.dx * 0.01;
                              });
                            },
                            child: CustomPaint(
                              size: Size.infinite,
                              painter: Agrivoltaic3dPainter(
                                rotationAngle: _rotationAngle,
                                zoom: _zoom,
                                panelTiltDeg: 20,
                                rowSpacingM: 6.0,
                                timeOfDayHour: _timeOfDay,
                              ),
                            ),
                          ),

                        // Interactive 3D Canvas Controls (Rotate, Zoom, Reset)
                        if (!_isArView)
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Column(
                              children: [
                                _buildToolButton(
                                  icon: Icons.rotate_right_rounded,
                                  tooltip: 'Rotate View',
                                  onTap: () => setState(() => _rotationAngle += 0.35),
                                ),
                                const SizedBox(height: 8),
                                _buildToolButton(
                                  icon: Icons.zoom_in_rounded,
                                  tooltip: 'Zoom In',
                                  onTap: () => setState(() => _zoom = (_zoom + 0.15).clamp(0.8, 1.6)),
                                ),
                                const SizedBox(height: 6),
                                _buildToolButton(
                                  icon: Icons.zoom_out_rounded,
                                  tooltip: 'Zoom Out',
                                  onTap: () => setState(() => _zoom = (_zoom - 0.15).clamp(0.8, 1.6)),
                                ),
                                const SizedBox(height: 6),
                                _buildToolButton(
                                  icon: Icons.refresh_rounded,
                                  tooltip: 'Reset',
                                  onTap: () => setState(() {
                                    _rotationAngle = 0.35;
                                    _zoom = 1.0;
                                  }),
                                ),
                              ],
                            ),
                          ),

                        // Subtitle overlay tag at bottom left of canvas
                        Positioned(
                          bottom: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.65),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'Rotate, zoom and see shadows across crops',
                              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Time of Day Slider & Structure Specs Card
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
              child: AppCard(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    // Time of Day slider
                    Row(
                      children: [
                        const Icon(Icons.wb_sunny_rounded, color: AppColors.solar, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Time of Day:',
                          style: AppTypography.label.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        Text(
                          '${_timeOfDay.toInt()}:00 ${_timeOfDay >= 12 ? 'PM' : 'AM'}',
                          style: AppTypography.cardTitle.copyWith(
                            fontSize: 13,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                    ),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: AppColors.solar,
                        inactiveTrackColor: AppColors.borderLight,
                        thumbColor: AppColors.solar,
                        trackHeight: 3.5,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      ),
                      child: Slider(
                        value: _timeOfDay,
                        min: 6.0,
                        max: 18.0,
                        divisions: 12,
                        onChanged: (val) => setState(() => _timeOfDay = val),
                      ),
                    ),
                    // Structure metrics
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildSpecItem('2.8 m', 'Panel Height'),
                        _buildSpecItem('6.0 m', 'Row Spacing'),
                        _buildSpecItem('40%', 'Coverage'),
                        _buildSpecItem('~480', 'Panels'),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Navigation Buttons (< Previous, Next →)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: '‹ Previous',
                      variant: AppButtonVariant.outline,
                      onPressed: () => context.go('/agri-pv-design'),
                      height: 46,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      text: 'Next ›',
                      variant: AppButtonVariant.primary,
                      onPressed: () => context.go('/shadow-simulation'),
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

  Widget _buildToolButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1)),
            ],
          ),
          child: Icon(icon, size: 20, color: AppColors.textPrimary),
        ),
      ),
    );
  }

  Widget _buildSpecItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.cardTitle.copyWith(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(fontSize: 10),
        ),
      ],
    );
  }
}
