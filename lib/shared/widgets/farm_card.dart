import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/farm.dart';

class FarmCard extends StatelessWidget {
  final Farm farm;
  final VoidCallback onTap;

  const FarmCard({
    super.key,
    required this.farm,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSuitable = farm.suitabilityScore >= 75;
    final statusLabel = isSuitable ? 'Suitable' : 'At Risk';
    final statusColor = isSuitable ? const Color(0xFF16A34A) : const Color(0xFFD97706);
    final statusBg = isSuitable ? const Color(0xFFDCFCE7) : const Color(0xFFFEF3C7);
    final statusBorder = isSuitable ? const Color(0xFF86EFAC) : const Color(0xFFFCD34D);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8F5E9), width: 1.0),
        boxShadow: const [
          BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // ── Thumbnail ──
                // ── Real Farm Photo Thumbnail ──
                Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
                    boxShadow: const [
                      BoxShadow(color: Color(0x0A000000), blurRadius: 4, offset: Offset(0, 1)),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(11),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          farm.imagePath,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => CustomPaint(
                            painter: _FieldMiniPainter(),
                            child: Container(
                              color: const Color(0xFF1B5E20),
                              child: const Center(
                                child: Icon(Icons.agriculture_rounded, color: Colors.white70),
                              ),
                            ),
                          ),
                        ),
                        // Subtle gradient at bottom for badge legibility
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: 24,
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black.withValues(alpha: 0.65),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                        ),
                        // Area badge
                        Positioned(
                          bottom: 3,
                          right: 4,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 4.5, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.75),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              '${farm.areaAcres}ac',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // ── Info ──
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name + status badge row
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              farm.name,
                              style: const TextStyle(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: statusBorder, width: 1),
                            ),
                            child: Text(
                              statusLabel,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w700,
                                color: statusColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      // Area + crop
                      Row(
                        children: [
                          const Icon(Icons.eco_rounded, size: 13, color: AppColors.primary),
                          const SizedBox(width: 3),
                          Text(
                            '${farm.areaAcres.toStringAsFixed(2)} acres • ${farm.crop}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF334155),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      // Location
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 13, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              farm.location,
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Mini painter that draws a simple top-down field row pattern
class _FieldMiniPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x2264DD77)
      ..strokeWidth = 2.5;
    for (double y = 8; y < size.height; y += 10) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
