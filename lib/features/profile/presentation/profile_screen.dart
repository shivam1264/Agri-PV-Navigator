import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../../services/storage/mock_data_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = MockDataService().user;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F7F4),
        elevation: 0,
        title: Text('Profile', style: AppTypography.screenHeading.copyWith(fontSize: 20)),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                child: Column(
                  children: [
                    // ── Profile Header ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: const Color(0xFFE8F5E9)),
                        boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 8, offset: Offset(0, 2))],
                      ),
                      child: Column(
                        children: [
                          // Avatar
                          Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: const Color(0xFF22C55E), width: 2.5),
                              boxShadow: const [
                                BoxShadow(color: Color(0x18000000), blurRadius: 8, offset: Offset(0, 3)),
                              ],
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/farmer_avatar.jpg',
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  color: const Color(0xFF166534),
                                  child: Center(
                                    child: Text(
                                      user.initials,
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            user.name,
                            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Color(0xFF0F172A)),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            user.email,
                            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 18),
                          // Stats
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _profileStat('${user.totalFarms}', 'Farms'),
                              Container(height: 28, width: 1, color: const Color(0xFFE2E8F0)),
                              _profileStat('${user.totalAreaAcres} ac', 'Total Area'),
                              Container(height: 28, width: 1, color: const Color(0xFFE2E8F0)),
                              _profileStat('${user.designsCreated}', 'Designs'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── Menu Card ──
                    _menuSection([
                      _MenuItem(icon: Icons.person_outline_rounded, label: 'My Profile', onTap: () {}),
                      _MenuItem(icon: Icons.agriculture_outlined, label: 'My Farms', onTap: () => context.go('/farms')),
                      _MenuItem(icon: Icons.settings_outlined, label: 'App Settings', onTap: () => context.go('/settings')),
                      _MenuItem(icon: Icons.help_outline_rounded, label: 'Help & Support', onTap: () => context.go('/help-support')),
                      _MenuItem(icon: Icons.info_outline_rounded, label: 'About', onTap: () => context.go('/about')),
                    ]),
                    const SizedBox(height: 14),

                    // ── Logout Card ──
                    _menuSection([
                      _MenuItem(
                        icon: Icons.logout_rounded,
                        label: 'Logout',
                        isDestructive: true,
                        onTap: () => context.go('/login'),
                      ),
                    ]),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            BottomNavBar(
              currentIndex: 4,
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

  Widget _profileStat(String val, String label) => Column(
        children: [
          Text(val, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
          Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
        ],
      );

  Widget _menuSection(List<_MenuItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8F5E9)),
        boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: Color(0xFFF1F5F9), indent: 56),
            items[i],
          ],
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? const Color(0xFFEF4444) : const Color(0xFF1E293B);
    final iconBg = isDestructive ? const Color(0xFFFEF2F2) : const Color(0xFFF0FFF4);
    final iconColor = isDestructive ? const Color(0xFFEF4444) : AppColors.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600, color: color),
                ),
              ),
              if (!isDestructive)
                const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFFCBD5E1)),
            ],
          ),
        ),
      ),
    );
  }
}
