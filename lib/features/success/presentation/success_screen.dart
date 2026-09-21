import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/farm_provider.dart';
import '../../../providers/design_provider.dart';
import '../../../providers/report_provider.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';

class SuccessScreen extends StatefulWidget {
  const SuccessScreen({super.key});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final farm = context.read<FarmProvider>().currentOrDraftFarm;
      final design = context.read<DesignProvider>().activeDesign;

      // Auto-generate proposal report for the completed farm & design
      context.read<ReportProvider>().generateReport(
        farmId: farm.id,
        designId: design?.id ?? 'design_primary',
        farmName: farm.name,
        type: 'proposal',
      );

      // Refresh farms and dashboard metrics
      context.read<FarmProvider>().loadFarms();
      context.read<DashboardProvider>().loadDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final farm = context.watch<FarmProvider>().currentOrDraftFarm;
    final design = context.watch<DesignProvider>().activeDesign;

    final capacity = design != null
        ? '${design.pvCapacityKw.toStringAsFixed(0)} kW'
        : '${(farm.areaAcres * 110).round()} kW';
    final energy = design != null
        ? '${design.annualEnergyMwh.toStringAsFixed(0)} MWh'
        : '${(farm.areaAcres * 165).round()} MWh';
    final co2 = design != null
        ? '${design.co2SavedTons.toStringAsFixed(0)} Tons'
        : '${(farm.areaAcres * 140).round()} Tons';

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
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'Your Agri-PV project for ${farm.name} is configured.\nTogether for sustainable farms and\na brighter tomorrow.',
                          style: const TextStyle(
                            fontSize: 15,
                            color: Color(0xFF64748B),
                            height: 1.55,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // ── Real Stats Summary ──
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
                            _successStat(capacity, 'PV Capacity'),
                            Container(height: 32, width: 1, color: const Color(0xFFE2E8F0)),
                            _successStat(energy, 'Energy/yr'),
                            Container(height: 32, width: 1, color: const Color(0xFFE2E8F0)),
                            _successStat(co2, 'CO₂ Saved'),
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
