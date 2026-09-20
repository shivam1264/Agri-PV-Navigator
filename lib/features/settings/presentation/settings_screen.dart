import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _language = 'English';
  final String _units = 'Metric (kW, m, acres)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Settings',
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
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                children: [
                  AppCard(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      children: [
                        _buildSettingTile(
                          icon: Icons.palette_outlined,
                          title: 'Theme',
                          trailingValue: 'Light',
                          onTap: () {},
                        ),
                        const Divider(height: 1, color: AppColors.borderLight),
                        _buildSettingTile(
                          icon: Icons.language_rounded,
                          title: 'Language',
                          trailingValue: _language,
                          onTap: () {
                            setState(() {
                              _language = _language == 'English' ? 'Hindi (हिंदी)' : 'English';
                            });
                          },
                        ),
                        const Divider(height: 1, color: AppColors.borderLight),
                        _buildSettingTile(
                          icon: Icons.straighten_rounded,
                          title: 'Units',
                          trailingValue: _units,
                          onTap: () {},
                        ),
                        const Divider(height: 1, color: AppColors.borderLight),
                        SwitchListTile(
                          secondary: const Icon(Icons.notifications_outlined, color: AppColors.textPrimary, size: 20),
                          title: Text(
                            'Notifications',
                            style: AppTypography.cardTitle.copyWith(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          value: _notificationsEnabled,
                          activeThumbColor: AppColors.primary,
                          onChanged: (val) => setState(() => _notificationsEnabled = val),
                        ),
                        const Divider(height: 1, color: AppColors.borderLight),
                        _buildSettingTile(
                          icon: Icons.security_outlined,
                          title: 'Privacy & Security',
                          onTap: () {},
                        ),
                        const Divider(height: 1, color: AppColors.borderLight),
                        _buildSettingTile(
                          icon: Icons.accessibility_new_rounded,
                          title: 'Accessibility',
                          onTap: () {},
                        ),
                      ],
                    ),
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

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? trailingValue,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary, size: 20),
      title: Text(
        title,
        style: AppTypography.cardTitle.copyWith(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailingValue != null) ...[
            Text(
              trailingValue,
              style: AppTypography.bodySmall.copyWith(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(width: 4),
          ],
          const Icon(Icons.chevron_right_rounded, size: 20, color: AppColors.textTertiary),
        ],
      ),
      onTap: onTap,
      dense: true,
    );
  }
}
