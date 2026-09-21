import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/farm_card.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../services/storage/mock_data_service.dart';
import '../../../shared/painters/agrivoltaic_3d_painter.dart';
import '../../../providers/farm_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mockService = MockDataService();
    final user = mockService.user;
    final farmsAsync = ref.watch(farmsProvider);
    final farmCountAsync = ref.watch(farmCountProvider);
    final totalAreaAsync = ref.watch(totalAreaProvider);
    final designCountAsync = ref.watch(designCountProvider);
    // Use real db values if ready, else fall back to mock
    final totalFarms = farmCountAsync.value ?? user.totalFarms;
    final totalArea = totalAreaAsync.value ?? user.totalAreaAcres;
    final designCount = designCountAsync.value ?? user.designsCreated;
    final farms = farmsAsync.value ?? mockService.farms;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F4),
      body: SafeArea(
        child: Column(
          children: [
            // ── Top App Bar ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
              child: Row(
                children: [
                  const AppLogo(
                    size: 38,
                    isHorizontal: true,
                    fontSize: 18,
                  ),
                  const Spacer(),
                  // Notification bell
                  _NavIconButton(
                    icon: Icons.notifications_none_rounded,
                    badgeColor: const Color(0xFF22C55E),
                    onTap: () {},
                  ),
                  const SizedBox(width: 10),
                  // User Avatar
                  GestureDetector(
                    onTap: () => context.go('/profile'),
                    child: Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF22C55E), width: 1.5),
                        boxShadow: const [
                          BoxShadow(color: Color(0x10000000), blurRadius: 4, offset: Offset(0, 1)),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/farmer_avatar.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(
                            color: AppColors.primarySurface,
                            child: Center(
                              child: Text(
                                user.initials,
                                style: const TextStyle(
                                  color: Color(0xFF166534),
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Scrollable Body ──
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 14.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Greeting
                    RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          fontFamily: 'Inter',
                        ),
                        children: [
                          TextSpan(text: 'Good morning, ${user.firstName}!  '),
                          const TextSpan(text: '👋'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      "Let's build a sustainable future together.",
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ── Hero Banner (Realistic Agrivoltaics) ──
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        width: double.infinity,
                        height: 155,
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Image.asset(
                                'assets/images/hero_agri_pv.jpg',
                                fit: BoxFit.cover,
                              ),
                            ),
                            // Gradient overlay for readability
                            Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.72),
                                    Colors.black.withValues(alpha: 0.20),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF22C55E),
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: const Text(
                                      'AGRI-PV TECHNOLOGY',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 7),
                                  const Text(
                                    'Same Land.\nMore Possibilities.',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 19,
                                      fontWeight: FontWeight.w800,
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // ── Modern 3-Column Stats Row ──
                    Row(
                      children: [
                        _StatItem(
                          value: '$totalFarms',
                          label: 'Total Farms',
                          icon: Icons.agriculture_rounded,
                          iconColor: const Color(0xFF16A34A),
                          bgColor: const Color(0xFFDCFCE7),
                          onTap: () => context.go('/farms'),
                        ),
                        const SizedBox(width: 10),
                        _StatItem(
                          value: totalArea.toStringAsFixed(2),
                          label: 'Total Area',
                          unit: 'ac',
                          icon: Icons.crop_free_rounded,
                          iconColor: const Color(0xFFD97706),
                          bgColor: const Color(0xFFFEF3C7),
                        ),
                        const SizedBox(width: 10),
                        _StatItem(
                          value: '$designCount',
                          label: 'PV Designs',
                          icon: Icons.solar_power_rounded,
                          iconColor: const Color(0xFF0284C7),
                          bgColor: const Color(0xFFE0F2FE),
                          onTap: () => context.go('/farms'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── 4 Quick Action Circular Buttons (Add Farm, Design, 3D / AR, Reports) ──
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _QuickActionCircle(
                          icon: Icons.add_rounded,
                          label: 'Add Farm',
                          isPrimary: true,
                          onTap: () => context.go('/farm-location'),
                        ),
                        _QuickActionCircle(
                          icon: Icons.solar_power_rounded,
                          label: 'Design',
                          onTap: () => context.go('/farm-location'),
                        ),
                        _QuickActionCircle(
                          icon: Icons.view_in_ar_rounded,
                          label: '3D / AR',
                          onTap: () => context.go('/ar-3d-view'),
                        ),
                        _QuickActionCircle(
                          icon: Icons.description_rounded,
                          label: 'Reports',
                          onTap: () => context.go('/reports'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),

                    // ── Recent Farms ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Recent Farms',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.go('/farms'),
                          child: const Row(
                            children: [
                              Text(
                                'View All',
                                style: TextStyle(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              SizedBox(width: 2),
                              Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.primary),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Farm Cards
                    ...farms.take(2).map((farm) => FarmCard(
                          farm: farm,
                          onTap: () => context.go('/site-suitability'),
                        )),
                    const SizedBox(height: 16),

                    // ── Environmental Impact Card ──
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                        boxShadow: const [
                          BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: Offset(0, 2)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Environmental Impact',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _ImpactItem(
                                icon: Icons.bolt_rounded,
                                color: AppColors.solar,
                                value: '430 MWh',
                                label: 'Clean Energy/yr',
                              ),
                              _ImpactItem(
                                icon: Icons.forest_rounded,
                                color: AppColors.primary,
                                value: '420 Tons',
                                label: 'CO₂ Saved/yr',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 0: break;
            case 1: context.go('/farms'); break;
            case 2: context.go('/farm-location'); break;
            case 3: context.go('/reports'); break;
            case 4: context.go('/profile'); break;
          }
        },
      ),
    );
  }

  Widget _vertDivider() => Container(height: 32, width: 1, color: const Color(0xFFE2E8F0));
}

// ── Reusable sub-widgets ──

class _NavIconButton extends StatelessWidget {
  final IconData icon;
  final Color? badgeColor;
  final VoidCallback onTap;
  const _NavIconButton({required this.icon, this.badgeColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, size: 18, color: const Color(0xFF1E293B)),
            if (badgeColor != null)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 7,
                  height: 7,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.2),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final String? unit;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
  final VoidCallback? onTap;

  const _StatItem({
    required this.value,
    required this.label,
    this.unit,
    required this.icon,
    required this.iconColor,
    required this.bgColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.1),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon Badge Tile
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(height: 8),
              // Value + unit
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.5,
                      fontFamily: 'Inter',
                    ),
                  ),
                  if (unit != null) ...[
                    const SizedBox(width: 2),
                    Text(
                      unit!,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: iconColor,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
              // Label
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickActionCircle extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isPrimary;

  const _QuickActionCircle({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isPrimary = false,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: isPrimary ? const Color(0xFF166534) : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isPrimary ? const Color(0xFF166534) : const Color(0xFFE2E8F0),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isPrimary
                        ? const Color(0xFF166534).withValues(alpha: 0.28)
                        : Colors.black.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: isPrimary ? Colors.white : const Color(0xFF166534),
                  size: 26,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImpactItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  const _ImpactItem({required this.icon, required this.color, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: Color(0xFF0F172A))),
              Text(label, style: const TextStyle(fontSize: 10.5, color: Color(0xFF64748B))),
            ],
          ),
        ],
      ),
    );
  }
}
