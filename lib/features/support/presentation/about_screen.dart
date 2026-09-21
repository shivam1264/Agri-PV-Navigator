import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  // Opens a URL in the browser; falls back to in-app dialog if can't launch
  Future<void> _launchUrl(BuildContext context, String url, String title, String fallbackContent) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (context.mounted) _showLegalDialog(context, title, fallbackContent);
    }
  }

  void _showLegalDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
        content: SingleChildScrollView(
          child: Text(content, style: const TextStyle(fontSize: 13.5, color: Color(0xFF334155), height: 1.6)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'About',
          style: AppTypography.screenHeading.copyWith(
            fontSize: 20,
            color: isDark ? Colors.white : null,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: isDark ? Colors.white : null),
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
                        color: isDark ? const Color(0xFF133520) : AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(100),
                        border: isDark ? Border.all(color: AppColors.primary.withValues(alpha: 0.3)) : null,
                      ),
                      child: Text(
                        'Version 1.0.0 (Build 2026.1)',
                        style: AppTypography.labelSmall.copyWith(
                          color: isDark ? AppColors.primaryLight : AppColors.primaryDark,
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
                              color: isDark ? AppColors.accent : AppColors.primaryDark,
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
                          _buildLegalTile(
                            context,
                            'Terms of Service',
                            () => _launchUrl(
                              context,
                              'https://agri-pv-navigator.example.com/terms',
                              'Terms of Service',
                              '''Terms of Service

Last updated: January 1, 2026

1. ACCEPTANCE OF TERMS
By using Agri-PV Navigator, you agree to these Terms of Service. If you do not agree, please discontinue use immediately.

2. USE OF SERVICE
You may use this application to assess Agri-PV feasibility for your farms. You must not misuse the service or use it for unlawful purposes.

3. DATA ACCURACY
Results provided are estimates based on available data. Always consult a certified solar engineer before making investment decisions.

4. INTELLECTUAL PROPERTY
All content, algorithms, and designs are the intellectual property of Agri-PV Navigator and its licensors.

5. LIMITATION OF LIABILITY
We are not liable for any losses arising from reliance on the application's outputs.

6. CONTACT
For queries, contact support@agri-pv-navigator.example.com''',
                            ),
                          ),
                          Divider(height: 1, color: theme.dividerColor),
                          _buildLegalTile(
                            context,
                            'Privacy Policy',
                            () => _launchUrl(
                              context,
                              'https://agri-pv-navigator.example.com/privacy',
                              'Privacy Policy',
                              '''Privacy Policy

Last updated: January 1, 2026

1. DATA WE COLLECT
We collect farm location data, device information, and usage statistics to provide our services.

2. HOW WE USE YOUR DATA
Your data is used to calculate Agri-PV suitability scores, generate reports, and improve our algorithms. We do not sell your personal data to third parties.

3. DATA STORAGE
Your farm data is stored securely on encrypted servers. We retain data for the duration of your account and 30 days after deletion.

4. YOUR RIGHTS
You may request data export or deletion at any time by contacting support@agri-pv-navigator.example.com.

5. COOKIES
We use cookies for session management and analytics. You can opt out in App Settings.

6. CONTACT
For privacy concerns, email: privacy@agri-pv-navigator.example.com''',
                            ),
                          ),
                          Divider(height: 1, color: theme.dividerColor),
                          _buildLegalTile(
                            context,
                            'Open Source Licenses',
                            () => _showLegalDialog(
                              context,
                              'Open Source Licenses',
                              '''This application is built with the following open-source packages:

• Flutter SDK (BSD 3-Clause)
• go_router (BSD 3-Clause)
• provider (MIT)
• flutter_map (BSD 2-Clause)
• geolocator (MIT)
• shared_preferences (BSD 3-Clause)
• flutter_secure_storage (BSD 3-Clause)
• url_launcher (BSD 3-Clause)
• http (BSD 3-Clause)
• google_fonts (Apache 2.0)

Full license texts are available at: https://pub.dev''',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Contact support
                    AppCard(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(color: AppColors.primarySurface, borderRadius: BorderRadius.circular(12)),
                            child: const Icon(Icons.email_outlined, color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text('Contact Us', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                                Text('support@agri-pv-navigator.com', style: AppTypography.bodySmall.copyWith(color: AppColors.primary)),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => launchUrl(Uri.parse('mailto:support@agri-pv-navigator.com')),
                            icon: const Icon(Icons.open_in_new_rounded, size: 18, color: AppColors.primary),
                          ),
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
                if (index == 2) context.go('/farm-location');
                if (index == 3) context.go('/reports');
                if (index == 4) context.go('/profile');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegalTile(BuildContext context, String title, VoidCallback onTap) {
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
