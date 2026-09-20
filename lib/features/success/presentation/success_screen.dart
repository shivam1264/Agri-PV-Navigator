import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';

class SuccessScreen extends StatelessWidget {
  const SuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F4),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 28.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),

                      // ── High Quality 3D Success Graphic ──
                      Container(
                        width: 170,
                        height: 170,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Color(0x2022C55E), blurRadius: 24, spreadRadius: 4, offset: Offset(0, 6)),
                          ],
                        ),
                        child: ClipOval(
                          child: Image.asset(
                            'assets/images/success_celebration.jpg',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const SizedBox(height: 36),

                      // ── Text ──
                      const Text(
                        "You're All Set! 🌱",
                        style: TextStyle(
                          fontSize: 27,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'Your Agri-PV journey has begun.\nTogether for sustainable farms and\na brighter tomorrow.',
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF64748B),
                            height: 1.55,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // ── Stats Summary ──
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE8F5E9)),
                          boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 8, offset: Offset(0, 2))],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _successStat('250 kW', 'PV Capacity'),
                            Container(height: 32, width: 1, color: const Color(0xFFE2E8F0)),
                            _successStat('400 MWh', 'Energy/yr'),
                            Container(height: 32, width: 1, color: const Color(0xFFE2E8F0)),
                            _successStat('420 Tons', 'CO₂ Saved'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 36),

                      // ── CTA Button ──
                      AppButton(
                        text: 'Back to Home',
                        onPressed: () => context.go('/home'),
                        variant: AppButtonVariant.primary,
                        height: 52,
                      ),
                      const SizedBox(height: 14),
                      TextButton(
                        onPressed: () => context.go('/reports'),
                        child: const Text(
                          'View My Report →',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),

            BottomNavBar(
              currentIndex: 0,
              onTap: (i) {
                if (i == 0) context.go('/home');
                if (i == 1) context.go('/farms');
                if (i == 2) context.go('/farm-location');
                if (i == 3) context.go('/reports');
                if (i == 4) context.go('/profile');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _successStat(String val, String label) => Column(
        children: [
          Text(val, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
          Text(label, style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
        ],
      );
}
