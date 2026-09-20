import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final bool showText;
  final bool showTagline;
  final bool isHorizontal;
  final String? customTagline;
  final double? fontSize;

  const AppLogo({
    super.key,
    this.size = 48.0,
    this.showText = true,
    this.showTagline = false,
    this.isHorizontal = false,
    this.customTagline,
    this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    final logoIcon = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.28),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(size * 0.14),
      child: Image.asset(
        'assets/images/app_logo.png',
        fit: BoxFit.contain,
      ),
    );

    if (!showText) return logoIcon;

    final effectiveFontSize = fontSize ?? (isHorizontal ? 17.0 : 22.0);

    if (isHorizontal) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          logoIcon,
          const SizedBox(width: 8),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'Agri-PV ',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: effectiveFontSize,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
                TextSpan(
                  text: 'Navigator',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: effectiveFontSize,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF16A34A),
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        logoIcon,
        const SizedBox(height: 10),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Agri-PV ',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: effectiveFontSize,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
                letterSpacing: -0.3,
              ),
            ),
            Text(
              'Navigator',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: effectiveFontSize,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF16A34A),
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        if (showTagline || customTagline != null) ...[
          const SizedBox(height: 4),
          Text(
            customTagline ?? 'Farms Thrive Brighter',
            style: AppTypography.bodySmall.copyWith(
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}
