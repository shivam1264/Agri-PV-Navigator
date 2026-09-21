import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import '../../../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // ── Privacy & Security Bottom Sheet ─────────────────────────────────────
  void _showPrivacySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PrivacySecuritySheet(),
    );
  }

  // ── Accessibility Bottom Sheet ───────────────────────────────────────────
  void _showAccessibilitySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AccessibilitySheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F7F4),
        elevation: 0,
        title: Text('Settings', style: AppTypography.screenHeading.copyWith(fontSize: 20)),
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                children: [
                  _sectionLabel('Appearance'),
                  _settingsCard([
                    _SettingRow(
                      icon: Icons.palette_outlined,
                      iconBg: const Color(0xFFF3E8FF),
                      iconColor: const Color(0xFF7C3AED),
                      title: 'Theme',
                      trailing: settings.theme,
                      onTap: () => settings.toggleTheme(),
                    ),
                    _SettingRow(
                      icon: Icons.language_rounded,
                      iconBg: const Color(0xFFE0F2FE),
                      iconColor: const Color(0xFF0284C7),
                      title: 'Language',
                      trailing: settings.language,
                      onTap: () => settings.toggleLanguage(),
                    ),
                    _SettingRow(
                      icon: Icons.straighten_rounded,
                      iconBg: const Color(0xFFFFF7ED),
                      iconColor: const Color(0xFFEA580C),
                      title: 'Units',
                      trailing: settings.units,
                      onTap: () => settings.cycleUnits(),
                    ),
                  ]),

                  const SizedBox(height: 16),
                  _sectionLabel('Notifications'),
                  _settingsCard([
                    _SettingToggleRow(
                      icon: Icons.notifications_outlined,
                      iconBg: const Color(0xFFF0FFF4),
                      iconColor: AppColors.primary,
                      title: 'Notifications',
                      value: settings.notificationsEnabled,
                      onChanged: (val) => settings.setNotificationsEnabled(val),
                    ),
                  ]),

                  const SizedBox(height: 16),
                  _sectionLabel('Security & Accessibility'),
                  _settingsCard([
                    _SettingRow(
                      icon: Icons.security_outlined,
                      iconBg: const Color(0xFFFEF2F2),
                      iconColor: const Color(0xFFDC2626),
                      title: 'Privacy & Security',
                      onTap: () => _showPrivacySheet(context),
                    ),
                    _SettingRow(
                      icon: Icons.accessibility_new_rounded,
                      iconBg: const Color(0xFFEFF6FF),
                      iconColor: const Color(0xFF2563EB),
                      title: 'Accessibility',
                      onTap: () => _showAccessibilitySheet(context),
                    ),
                  ]),

                  const SizedBox(height: 24),
                ],
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

  Widget _sectionLabel(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8, left: 4),
        child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B), letterSpacing: 0.5)),
      );

  Widget _settingsCard(List<Widget> rows) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8F5E9)),
        boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: Color(0xFFF1F5F9), indent: 56),
            rows[i],
          ],
        ],
      ),
    );
  }
}

// ── Privacy & Security Sheet ───────────────────────────────────────────────
class _PrivacySecuritySheet extends StatefulWidget {
  @override
  State<_PrivacySecuritySheet> createState() => _PrivacySecuritySheetState();
}

class _PrivacySecuritySheetState extends State<_PrivacySecuritySheet> {
  bool _locationSharing = true;
  bool _analyticsEnabled = true;
  bool _crashReporting = true;
  bool _biometricLock = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          const Row(
            children: [
              Icon(Icons.security_outlined, color: Color(0xFFDC2626), size: 22),
              SizedBox(width: 10),
              Text('Privacy & Security', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
            ],
          ),
          const SizedBox(height: 20),
          _toggleTile(
            icon: Icons.location_on_outlined,
            iconBg: const Color(0xFFF0FFF4),
            iconColor: AppColors.primary,
            title: 'Location Sharing',
            subtitle: 'Allow app to access your location for farm mapping',
            value: _locationSharing,
            onChanged: (v) => setState(() => _locationSharing = v),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9), indent: 50),
          _toggleTile(
            icon: Icons.analytics_outlined,
            iconBg: const Color(0xFFE0F2FE),
            iconColor: const Color(0xFF0284C7),
            title: 'Usage Analytics',
            subtitle: 'Help improve the app by sharing anonymous usage data',
            value: _analyticsEnabled,
            onChanged: (v) => setState(() => _analyticsEnabled = v),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9), indent: 50),
          _toggleTile(
            icon: Icons.bug_report_outlined,
            iconBg: const Color(0xFFFFF7ED),
            iconColor: const Color(0xFFEA580C),
            title: 'Crash Reporting',
            subtitle: 'Automatically send crash reports to help fix bugs',
            value: _crashReporting,
            onChanged: (v) => setState(() => _crashReporting = v),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9), indent: 50),
          _toggleTile(
            icon: Icons.fingerprint_rounded,
            iconBg: const Color(0xFFF3E8FF),
            iconColor: const Color(0xFF7C3AED),
            title: 'Biometric Lock',
            subtitle: 'Use fingerprint or face ID to unlock the app',
            value: _biometricLock,
            onChanged: (v) => setState(() => _biometricLock = v),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Privacy settings saved'),
                    backgroundColor: AppColors.primary,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Save Settings', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggleTile({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
                Text(subtitle, style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch(value: value, onChanged: onChanged, activeThumbColor: AppColors.primary),
          ),
        ],
      ),
    );
  }
}

// ── Accessibility Sheet ────────────────────────────────────────────────────
class _AccessibilitySheet extends StatefulWidget {
  @override
  State<_AccessibilitySheet> createState() => _AccessibilitySheetState();
}

class _AccessibilitySheetState extends State<_AccessibilitySheet> {
  bool _highContrast = false;
  bool _largeText = false;
  bool _reduceMotion = false;
  double _textScale = 1.0;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 20),
          const Row(
            children: [
              Icon(Icons.accessibility_new_rounded, color: Color(0xFF2563EB), size: 22),
              SizedBox(width: 10),
              Text('Accessibility', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF0F172A))),
            ],
          ),
          const SizedBox(height: 20),

          // Text Scale Slider
          const Text('Text Size', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF64748B))),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.text_fields_rounded, size: 16, color: Color(0xFF94A3B8)),
              Expanded(
                child: Slider(
                  value: _textScale,
                  min: 0.8,
                  max: 1.4,
                  divisions: 6,
                  activeColor: AppColors.primary,
                  onChanged: (v) => setState(() => _textScale = v),
                ),
              ),
              const Icon(Icons.text_fields_rounded, size: 22, color: Color(0xFF94A3B8)),
            ],
          ),
          Text(
            'Preview text at ${(_textScale * 100).round()}% scale',
            style: TextStyle(fontSize: 13 * _textScale, color: const Color(0xFF1E293B)),
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFFF1F5F9)),
          const SizedBox(height: 8),

          // Toggles
          _toggleRow(
            icon: Icons.contrast_rounded,
            title: 'High Contrast Mode',
            subtitle: 'Increase color contrast for better readability',
            value: _highContrast,
            onChanged: (v) => setState(() => _highContrast = v),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9), indent: 50),
          _toggleRow(
            icon: Icons.format_size_rounded,
            title: 'Large Touch Targets',
            subtitle: 'Make buttons and interactive elements larger',
            value: _largeText,
            onChanged: (v) => setState(() => _largeText = v),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9), indent: 50),
          _toggleRow(
            icon: Icons.animation_rounded,
            title: 'Reduce Motion',
            subtitle: 'Minimize animations and transitions',
            value: _reduceMotion,
            onChanged: (v) => setState(() => _reduceMotion = v),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Accessibility settings saved'),
                    backgroundColor: Color(0xFF2563EB),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: const Text('Save Settings', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggleRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 38, height: 38,
            decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: const Color(0xFF2563EB), size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1E293B))),
                Text(subtitle, style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch(value: value, onChanged: onChanged, activeThumbColor: const Color(0xFF2563EB)),
          ),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String? trailing;
  final VoidCallback onTap;

  const _SettingRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
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
                child: Text(title, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500, color: Color(0xFF1E293B))),
              ),
              if (trailing != null) ...[
                Text(trailing!, style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
                const SizedBox(width: 4),
              ],
              const Icon(Icons.chevron_right_rounded, size: 18, color: Color(0xFFCBD5E1)),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingToggleRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingToggleRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
            child: Text(title, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500, color: Color(0xFF1E293B))),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
