import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'About',
          style: AppTypography.screenHeading.copyWith(fontSize: 20),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/profile'),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    const AppLogo(
                      size: 64,
                      showText: true,
                      showTagline: true,
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(100),
                      ),
                      child: Text(
                        'Version 1.0.0 (Build 2026.1)',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Mission Card
                    AppCard(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Our Mission',
                            style: AppTypography.cardTitle.copyWith(fontSize: 16),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '"Empowering farmers with data-driven decisions for a greener, more prosperous tomorrow."',
                            style: AppTypography.bodyMedium.copyWith(
                              fontStyle: FontStyle.italic,
                              color: AppColors.primaryDark,
                              fontWeight: FontWeight.w600,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Agri-PV Navigator bridges agricultural agronomy with solar engineering, providing precision feasibility assessments, 3D shadow simulations, and bankable techno-economic models for dual-use land installations.',
                            style: AppTypography.bodySmall.copyWith(height: 1.4),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Legal links
                    AppCard(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Column(
                        children: [
                          _buildLegalTile('Terms of Service', () {}),
                          const Divider(height: 1, color: AppColors.borderLight),
                          _buildLegalTile('Privacy Policy', () {}),
                          const Divider(height: 1, color: AppColors.borderLight),
                          _buildLegalTile('Open Source Licenses', () {}),
                        ],
                      ),
                    ),
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
                if (index == 4) context.go('/profile');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalTile(String title, VoidCallback onTap) {
    return ListTile(
      title: Text(
        title,
        style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textTertiary),
      onTap: onTap,
      dense: true,
    );
  }
}
