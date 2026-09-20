import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../../services/storage/mock_data_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = MockDataService().user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Profile',
          style: AppTypography.screenHeading.copyWith(fontSize: 20),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                child: Column(
                  children: [
                    // Profile Header Card
                    AppCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: AppColors.primarySurface,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.primaryLight, width: 2),
                            ),
                            child: Center(
                              child: Text(
                                user.initials,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.primaryDark,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            user.name,
                            style: AppTypography.screenHeading.copyWith(fontSize: 20),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user.email,
                            style: AppTypography.bodySmall,
                          ),
                          const SizedBox(height: 16),
                          // Stats banner inside profile
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildProfileStat('${user.totalFarms}', 'Farms'),
                              Container(height: 24, width: 1, color: AppColors.border),
                              _buildProfileStat('${user.totalAreaAcres} ac', 'Total Area'),
                              Container(height: 24, width: 1, color: AppColors.border),
                              _buildProfileStat('${user.designsCreated}', 'Designs'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Menu Options
                    AppCard(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        children: [
                          _buildMenuItem(
                            icon: Icons.person_outline_rounded,
                            title: 'My Profile',
                            onTap: () {},
                          ),
                          const Divider(height: 1, color: AppColors.borderLight),
                          _buildMenuItem(
                            icon: Icons.agriculture_outlined,
                            title: 'My Farms',
                            onTap: () => context.go('/farms'),
                          ),
                          const Divider(height: 1, color: AppColors.borderLight),
                          _buildMenuItem(
                            icon: Icons.settings_outlined,
                            title: 'App Settings',
                            onTap: () => context.go('/settings'),
                          ),
                          const Divider(height: 1, color: AppColors.borderLight),
                          _buildMenuItem(
                            icon: Icons.help_outline_rounded,
                            title: 'Help & Support',
                            onTap: () => context.go('/help-support'),
                          ),
                          const Divider(height: 1, color: AppColors.borderLight),
                          _buildMenuItem(
                            icon: Icons.info_outline_rounded,
                            title: 'About',
                            onTap: () => context.go('/about'),
                          ),
                          const Divider(height: 1, color: AppColors.borderLight),
                          _buildMenuItem(
                            icon: Icons.logout_rounded,
                            title: 'Logout',
                            isDestructive: true,
                            onTap: () => context.go('/login'),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Bottom Navigation Bar
            BottomNavBar(
              currentIndex: 4,
              onTap: (index) {
                if (index == 0) context.go('/home');
                if (index == 1) context.go('/farms');
                if (index == 2) context.go('/agri-pv-design');
                if (index == 3) context.go('/reports');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStat(String val, String title) {
    return Column(
      children: [
        Text(
          val,
          style: AppTypography.cardTitle.copyWith(fontWeight: FontWeight.w700, fontSize: 15),
        ),
        Text(
          title,
          style: AppTypography.labelSmall.copyWith(fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppColors.error : AppColors.textPrimary,
        size: 20,
      ),
      title: Text(
        title,
        style: AppTypography.cardTitle.copyWith(
          fontSize: 14,
          fontWeight: isDestructive ? FontWeight.w600 : FontWeight.w500,
          color: isDestructive ? AppColors.error : AppColors.textPrimary,
        ),
      ),
      trailing: isDestructive
          ? null
          : const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textTertiary),
      onTap: onTap,
      dense: true,
    );
  }
}
