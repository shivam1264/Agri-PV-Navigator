import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Help & Support',
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
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                children: [
                  // Search Box
                  Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'Search help articles...',
                        prefixIcon: Icon(Icons.search_rounded, color: AppColors.textTertiary, size: 20),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Categories
                  AppCard(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      children: [
                        _buildHelpCategory(
                          icon: Icons.lightbulb_outline_rounded,
                          title: 'Getting Started',
                          subtitle: 'Creating your first farm & mapping boundary',
                          onTap: () {},
                        ),
                        const Divider(height: 1, color: AppColors.borderLight),
                        _buildHelpCategory(
                          icon: Icons.touch_app_outlined,
                          title: 'Using the App',
                          subtitle: 'Configuring tilts, spacing & clearance checks',
                          onTap: () {},
                        ),
                        const Divider(height: 1, color: AppColors.borderLight),
                        _buildHelpCategory(
                          icon: Icons.build_outlined,
                          title: 'Technical Support',
                          subtitle: 'Troubleshooting 3D canvas and report generation',
                          onTap: () {},
                        ),
                        const Divider(height: 1, color: AppColors.borderLight),
                        _buildHelpCategory(
                          icon: Icons.question_answer_outlined,
                          title: 'FAQs',
                          subtitle: 'Common questions on subsidies and crop yields',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Contact Support Options
                  Text(
                    'Contact Us',
                    style: AppTypography.sectionHeading.copyWith(fontSize: 16),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Opening support email client...')),
                            );
                          },
                          icon: const Icon(Icons.email_outlined, size: 18),
                          label: const Text('Email Support'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Connecting to live chat advisor...')),
                            );
                          },
                          icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                          label: const Text('Live Chat'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
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

  Widget _buildHelpCategory({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: AppColors.primary, size: 20),
      ),
      title: Text(
        title,
        style: AppTypography.cardTitle.copyWith(fontSize: 14),
      ),
      subtitle: Text(
        subtitle,
        style: AppTypography.bodySmall.copyWith(fontSize: 11),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textTertiary),
      onTap: onTap,
      dense: true,
    );
  }
}
