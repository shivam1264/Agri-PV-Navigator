import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import '../../../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  // ── Theme Selection Bottom Sheet ──────────────────────────────────────────
  void _showThemeSheet(BuildContext context) {
    final settings = context.read<SettingsProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: settings.highContrast ? theme.colorScheme.primary : theme.dividerColor,
            width: settings.highContrast ? 2.0 : 1.0,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2E4234) : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.palette_outlined, color: theme.colorScheme.primary, size: 22),
                const SizedBox(width: 10),
                Text(
                  settings.tr('choose_theme'),
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _themeOption(
              context: context,
              title: settings.tr('theme_light'),
              subtitle: settings.tr('theme_light_desc'),
              icon: Icons.wb_sunny_rounded,
              iconColor: const Color(0xFFEAB308),
              isSelected: settings.theme == 'Light',
              settings: settings,
              onTap: () {
                settings.setTheme('Light');
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 10),
            _themeOption(
              context: context,
              title: settings.tr('theme_dark'),
              subtitle: settings.tr('theme_dark_desc'),
              icon: Icons.nightlight_round,
              iconColor: isDark ? const Color(0xFF00E676) : const Color(0xFF6366F1),
              isSelected: settings.theme == 'Dark',
              settings: settings,
              onTap: () {
                settings.setTheme('Dark');
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 10),
            _themeOption(
              context: context,
              title: settings.tr('theme_system'),
              subtitle: settings.tr('theme_system_desc'),
              icon: Icons.settings_suggest_rounded,
              iconColor: const Color(0xFF10B981),
              isSelected: settings.theme == 'System',
              settings: settings,
              onTap: () {
                settings.setTheme('System');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _themeOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool isSelected,
    required SettingsProvider settings,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final vPad = settings.largeTouchTargets ? 18.0 : 14.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: vPad),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF14301C) : const Color(0xFFF0FDF4))
                : (isDark ? const Color(0xFF0A0F0C) : const Color(0xFFF8FAFC)),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? primaryColor : theme.dividerColor,
              width: isSelected || settings.highContrast ? 2.0 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: settings.largeTouchTargets ? 44 : 38,
                height: settings.largeTouchTargets ? 44 : 38,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: settings.largeTouchTargets ? 22 : 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: settings.largeTouchTargets ? 16 : 14.5,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: settings.largeTouchTargets ? 13 : 12,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle_rounded, color: primaryColor, size: 22)
              else
                Icon(Icons.radio_button_unchecked_rounded, color: theme.dividerColor, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  // ── Language Selection Bottom Sheet ───────────────────────────────────────
  void _showLanguageSheet(BuildContext context) {
    final settings = context.read<SettingsProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: settings.highContrast ? theme.colorScheme.primary : theme.dividerColor,
            width: settings.highContrast ? 2.0 : 1.0,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2E4234) : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.language_rounded, color: theme.colorScheme.primary, size: 22),
                const SizedBox(width: 10),
                Text(
                  settings.tr('choose_language'),
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _languageOption(
              context: context,
              title: 'English',
              subtitle: 'English (United States / India)',
              flag: '🇺🇸',
              isSelected: !settings.isHindi,
              settings: settings,
              onTap: () {
                settings.setLanguage('English');
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 10),
            _languageOption(
              context: context,
              title: 'हिंदी (Hindi)',
              subtitle: 'भारतीय किसानों के लिए हिंदी इंटरफ़ेस',
              flag: '🇮🇳',
              isSelected: settings.isHindi,
              settings: settings,
              onTap: () {
                settings.setLanguage('Hindi (हिंदी)');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _languageOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String flag,
    required bool isSelected,
    required SettingsProvider settings,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final vPad = settings.largeTouchTargets ? 18.0 : 14.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: vPad),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF14301C) : const Color(0xFFF0FDF4))
                : (isDark ? const Color(0xFF0A0F0C) : const Color(0xFFF8FAFC)),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? primaryColor : theme.dividerColor,
              width: isSelected || settings.highContrast ? 2.0 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Text(flag, style: TextStyle(fontSize: settings.largeTouchTargets ? 28 : 24)),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: settings.largeTouchTargets ? 16 : 15,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: settings.largeTouchTargets ? 13 : 12,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle_rounded, color: primaryColor, size: 22)
              else
                Icon(Icons.radio_button_unchecked_rounded, color: theme.dividerColor, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  // ── Units Selection Bottom Sheet ──────────────────────────────────────────
  void _showUnitsSheet(BuildContext context) {
    final settings = context.read<SettingsProvider>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: settings.highContrast ? theme.colorScheme.primary : theme.dividerColor,
            width: settings.highContrast ? 2.0 : 1.0,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2E4234) : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.straighten_rounded, color: const Color(0xFFF59E0B), size: 22),
                const SizedBox(width: 10),
                Text(
                  settings.tr('choose_units'),
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _unitOption(
              context: context,
              title: settings.tr('units_metric'),
              subtitle: settings.tr('units_metric_desc'),
              badge: 'm, ac, L, kW',
              isSelected: settings.units == 'Metric (SI, acres)',
              settings: settings,
              onTap: () {
                settings.setUnits('Metric (SI, acres)');
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 10),
            _unitOption(
              context: context,
              title: settings.tr('units_hectares'),
              subtitle: settings.tr('units_hectares_desc'),
              badge: 'm, ha, L, kW',
              isSelected: settings.units == 'Hectares (ha)',
              settings: settings,
              onTap: () {
                settings.setUnits('Hectares (ha)');
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 10),
            _unitOption(
              context: context,
              title: settings.tr('units_imperial'),
              subtitle: settings.tr('units_imperial_desc'),
              badge: 'ft, ac, gal, kW',
              isSelected: settings.units == 'Imperial (ft, acres)',
              settings: settings,
              onTap: () {
                settings.setUnits('Imperial (ft, acres)');
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _unitOption({
    required BuildContext context,
    required String title,
    required String subtitle,
    required String badge,
    required bool isSelected,
    required SettingsProvider settings,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final vPad = settings.largeTouchTargets ? 18.0 : 14.0;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: vPad),
          decoration: BoxDecoration(
            color: isSelected
                ? (isDark ? const Color(0xFF14301C) : const Color(0xFFF0FDF4))
                : (isDark ? const Color(0xFF0A0F0C) : const Color(0xFFF8FAFC)),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? primaryColor : theme.dividerColor,
              width: isSelected || settings.highContrast ? 2.0 : 1.0,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: settings.largeTouchTargets ? 16 : 14.5,
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF163822) : const Color(0xFFDCFCE7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            badge,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: isDark ? const Color(0xFF00E676) : AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: settings.largeTouchTargets ? 13 : 12,
                        color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle_rounded, color: primaryColor, size: 22)
              else
                Icon(Icons.radio_button_unchecked_rounded, color: theme.dividerColor, size: 22),
            ],
          ),
        ),
      ),
    );
  }

  // ── Privacy & Security Bottom Sheet ─────────────────────────────────────
  void _showPrivacySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _PrivacySecuritySheet(),
    );
  }

  // ── Accessibility Bottom Sheet ───────────────────────────────────────────
  void _showAccessibilitySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _AccessibilitySheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          settings.tr('settings'),
          style: AppTypography.screenHeading.copyWith(
            fontSize: 21,
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: theme.colorScheme.onSurface),
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
                  _sectionLabel(context, settings.tr('appearance')),
                  _settingsCard(context, settings, [
                    _SettingRow(
                      icon: Icons.palette_outlined,
                      iconBg: const Color(0xFF7C3AED).withValues(alpha: 0.15),
                      iconColor: const Color(0xFF7C3AED),
                      title: settings.tr('theme'),
                      trailing: settings.theme == 'Light'
                          ? settings.tr('theme_light')
                          : (settings.theme == 'Dark' ? settings.tr('theme_dark') : settings.tr('theme_system')),
                      settings: settings,
                      onTap: () => _showThemeSheet(context),
                    ),
                    _SettingRow(
                      icon: Icons.language_rounded,
                      iconBg: const Color(0xFF38BDF8).withValues(alpha: 0.15),
                      iconColor: const Color(0xFF38BDF8),
                      title: settings.tr('language'),
                      trailing: settings.isHindi ? 'हिंदी' : 'English',
                      settings: settings,
                      onTap: () => _showLanguageSheet(context),
                    ),
                    _SettingRow(
                      icon: Icons.straighten_rounded,
                      iconBg: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                      iconColor: const Color(0xFFF59E0B),
                      title: settings.tr('units'),
                      trailing: settings.units.contains('Hectares')
                          ? 'Hectares (ha)'
                          : (settings.units.contains('Imperial') ? 'Imperial (ft)' : 'Metric (m, ac)'),
                      settings: settings,
                      onTap: () => _showUnitsSheet(context),
                    ),
                  ]),

                  const SizedBox(height: 16),
                  _sectionLabel(context, settings.tr('notifications')),
                  _settingsCard(context, settings, [
                    _SettingToggleRow(
                      icon: Icons.notifications_outlined,
                      iconBg: theme.colorScheme.primary.withValues(alpha: 0.15),
                      iconColor: theme.colorScheme.primary,
                      title: settings.tr('notif_title'),
                      subtitle: settings.tr('notif_desc'),
                      value: settings.notificationsEnabled,
                      settings: settings,
                      onChanged: (val) => settings.setNotificationsEnabled(val),
                    ),
                  ]),

                  const SizedBox(height: 16),
                  _sectionLabel(context, settings.tr('security_accessibility')),
                  _settingsCard(context, settings, [
                    _SettingRow(
                      icon: Icons.security_outlined,
                      iconBg: const Color(0xFFDC2626).withValues(alpha: 0.15),
                      iconColor: const Color(0xFFDC2626),
                      title: settings.tr('privacy_security'),
                      settings: settings,
                      onTap: () => _showPrivacySheet(context),
                    ),
                    _SettingRow(
                      icon: Icons.accessibility_new_rounded,
                      iconBg: const Color(0xFF2563EB).withValues(alpha: 0.15),
                      iconColor: const Color(0xFF2563EB),
                      title: settings.tr('accessibility'),
                      trailing: '${(settings.textScale * 100).round()}% scale',
                      settings: settings,
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

  Widget _sectionLabel(BuildContext context, String text) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _settingsCard(BuildContext context, SettingsProvider settings, List<Widget> rows) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: settings.highContrast ? theme.colorScheme.primary : theme.dividerColor,
          width: settings.highContrast ? 2.0 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.2) : const Color(0x06000000),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          for (int i = 0; i < rows.length; i++) ...[
            if (i > 0) Divider(height: 1, color: theme.dividerColor, indent: settings.largeTouchTargets ? 64 : 56),
            rows[i],
          ],
        ],
      ),
    );
  }
}

// ── Setting Row with Trailing Value ──────────────────────────────────────────
class _SettingRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String? trailing;
  final SettingsProvider settings;
  final VoidCallback onTap;

  const _SettingRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    this.trailing,
    required this.settings,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final vPad = settings.largeTouchTargets ? 18.0 : 14.0;
    final boxSize = settings.largeTouchTargets ? 42.0 : 36.0;
    final iconSize = settings.largeTouchTargets ? 21.0 : 18.0;
    final fontSize = settings.largeTouchTargets ? 16.0 : 14.5;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: vPad),
          child: Row(
            children: [
              Container(
                width: boxSize,
                height: boxSize,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                  border: settings.highContrast ? Border.all(color: iconColor, width: 1.0) : null,
                ),
                child: Icon(icon, color: iconColor, size: iconSize),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              if (trailing != null) ...[
                Text(
                  trailing!,
                  style: TextStyle(
                    fontSize: settings.largeTouchTargets ? 14 : 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Icon(
                Icons.chevron_right_rounded,
                size: settings.largeTouchTargets ? 24 : 20,
                color: isDark ? const Color(0xFF64748B) : const Color(0xFFCBD5E1),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Setting Toggle Row ───────────────────────────────────────────────────────
class _SettingToggleRow extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final bool value;
  final SettingsProvider settings;
  final ValueChanged<bool> onChanged;

  const _SettingToggleRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.value,
    required this.settings,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final vPad = settings.largeTouchTargets ? 16.0 : 12.0;
    final boxSize = settings.largeTouchTargets ? 42.0 : 36.0;
    final iconSize = settings.largeTouchTargets ? 21.0 : 18.0;
    final fontSize = settings.largeTouchTargets ? 16.0 : 14.5;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: vPad),
      child: Row(
        children: [
          Container(
            width: boxSize,
            height: boxSize,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
              border: settings.highContrast ? Border.all(color: iconColor, width: 1.0) : null,
            ),
            child: Icon(icon, color: iconColor, size: iconSize),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: settings.largeTouchTargets ? 12.5 : 11.5,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Transform.scale(
            scale: settings.largeTouchTargets ? 1.0 : 0.85,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Privacy & Security Sheet ───────────────────────────────────────────────
class _PrivacySecuritySheet extends StatefulWidget {
  const _PrivacySecuritySheet();

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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final settings = context.watch<SettingsProvider>();

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: settings.highContrast ? theme.colorScheme.primary : theme.dividerColor,
          width: settings.highContrast ? 2.0 : 1.0,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2E4234) : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.security_outlined, color: Color(0xFFDC2626), size: 22),
              const SizedBox(width: 10),
              Text(
                settings.tr('privacy_security'),
                style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: theme.colorScheme.onSurface),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _toggleTile(
            context: context,
            icon: Icons.location_on_outlined,
            iconBg: theme.colorScheme.primary.withValues(alpha: 0.15),
            iconColor: theme.colorScheme.primary,
            title: settings.tr('location_sharing'),
            subtitle: settings.tr('location_sharing_desc'),
            value: _locationSharing,
            onChanged: (v) => setState(() => _locationSharing = v),
          ),
          Divider(height: 1, color: theme.dividerColor, indent: 50),
          _toggleTile(
            context: context,
            icon: Icons.analytics_outlined,
            iconBg: const Color(0xFF38BDF8).withValues(alpha: 0.15),
            iconColor: const Color(0xFF38BDF8),
            title: settings.tr('usage_analytics'),
            subtitle: settings.tr('usage_analytics_desc'),
            value: _analyticsEnabled,
            onChanged: (v) => setState(() => _analyticsEnabled = v),
          ),
          Divider(height: 1, color: theme.dividerColor, indent: 50),
          _toggleTile(
            context: context,
            icon: Icons.bug_report_outlined,
            iconBg: const Color(0xFFF59E0B).withValues(alpha: 0.15),
            iconColor: const Color(0xFFF59E0B),
            title: settings.tr('crash_reporting'),
            subtitle: settings.tr('crash_reporting_desc'),
            value: _crashReporting,
            onChanged: (v) => setState(() => _crashReporting = v),
          ),
          Divider(height: 1, color: theme.dividerColor, indent: 50),
          _toggleTile(
            context: context,
            icon: Icons.fingerprint_rounded,
            iconBg: const Color(0xFF7C3AED).withValues(alpha: 0.15),
            iconColor: const Color(0xFF7C3AED),
            title: settings.tr('biometric_lock'),
            subtitle: settings.tr('biometric_lock_desc'),
            value: _biometricLock,
            onChanged: (v) => setState(() => _biometricLock = v),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: EdgeInsets.symmetric(vertical: settings.largeTouchTargets ? 18 : 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(settings.tr('settings_saved')),
                    backgroundColor: const Color(0xFF10B981),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Text(
                settings.tr('save_settings'),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggleTile({
    required BuildContext context,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: 0.85,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Fully Functional Accessibility Sheet (Eye-Catchy & Real-Time) ───────────
class _AccessibilitySheet extends StatefulWidget {
  const _AccessibilitySheet();

  @override
  State<_AccessibilitySheet> createState() => _AccessibilitySheetState();
}

class _AccessibilitySheetState extends State<_AccessibilitySheet> {
  late double _textScale;
  late bool _highContrast;
  late bool _largeTouchTargets;
  late bool _reduceMotion;

  @override
  void initState() {
    super.initState();
    final settings = context.read<SettingsProvider>();
    _textScale = settings.textScale;
    _highContrast = settings.highContrast;
    _largeTouchTargets = settings.largeTouchTargets;
    _reduceMotion = settings.reduceMotion;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final settings = context.watch<SettingsProvider>();
    final primaryColor = theme.colorScheme.primary;

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(
          color: _highContrast ? primaryColor : theme.dividerColor,
          width: _highContrast ? 2.0 : 1.0,
        ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF2E4234) : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.accessibility_new_rounded, color: primaryColor, size: 24),
                  const SizedBox(width: 10),
                  Text(
                    settings.tr('accessibility_title'),
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _textScale = 1.0;
                    _highContrast = false;
                    _largeTouchTargets = false;
                    _reduceMotion = false;
                  });
                  settings.resetAccessibility();
                },
                child: Text(
                  settings.tr('reset_defaults'),
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFF00E676) : const Color(0xFF2563EB),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Text Scale Slider with live effect
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                settings.tr('text_size'),
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: primaryColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${(_textScale * 100).round()}%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: primaryColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.text_fields_rounded, size: 16, color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
              Expanded(
                child: Slider(
                  value: _textScale,
                  min: 0.8,
                  max: 1.4,
                  divisions: 6,
                  activeColor: primaryColor,
                  onChanged: (v) {
                    setState(() => _textScale = v);
                    // Live apply immediately to application
                    settings.setTextScale(v);
                  },
                ),
              ),
              Icon(Icons.text_fields_rounded, size: 24, color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF090D0B) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Row(
              children: [
                Icon(Icons.visibility_outlined, size: 16, color: primaryColor),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${settings.tr('text_preview')} (${(_textScale * 100).round()}%)',
                    style: TextStyle(
                      fontSize: 13 * _textScale,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: theme.dividerColor),
          const SizedBox(height: 6),

          // Toggles with Live Effect
          _toggleRow(
            context: context,
            icon: Icons.contrast_rounded,
            title: settings.tr('high_contrast'),
            subtitle: settings.tr('high_contrast_desc'),
            value: _highContrast,
            onChanged: (v) {
              setState(() => _highContrast = v);
              settings.setHighContrast(v);
            },
          ),
          Divider(height: 1, color: theme.dividerColor, indent: 50),
          _toggleRow(
            context: context,
            icon: Icons.format_size_rounded,
            title: settings.tr('large_targets'),
            subtitle: settings.tr('large_targets_desc'),
            value: _largeTouchTargets,
            onChanged: (v) {
              setState(() => _largeTouchTargets = v);
              settings.setLargeTouchTargets(v);
            },
          ),
          Divider(height: 1, color: theme.dividerColor, indent: 50),
          _toggleRow(
            context: context,
            icon: Icons.animation_rounded,
            title: settings.tr('reduce_motion'),
            subtitle: settings.tr('reduce_motion_desc'),
            value: _reduceMotion,
            onChanged: (v) {
              setState(() => _reduceMotion = v);
              settings.setReduceMotion(v);
            },
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: theme.colorScheme.onPrimary,
                padding: EdgeInsets.symmetric(vertical: _largeTouchTargets ? 18 : 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: () {
                settings.setTextScale(_textScale);
                settings.setHighContrast(_highContrast);
                settings.setLargeTouchTargets(_largeTouchTargets);
                settings.setReduceMotion(_reduceMotion);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(settings.tr('settings_saved')),
                    backgroundColor: const Color(0xFF10B981),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: Text(
                settings.tr('save_settings'),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _toggleRow({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: _largeTouchTargets ? 14 : 10),
      child: Row(
        children: [
          Container(
            width: _largeTouchTargets ? 44 : 38,
            height: _largeTouchTargets ? 44 : 38,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF132E20) : const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(10),
              border: _highContrast ? Border.all(color: primaryColor, width: 1.0) : null,
            ),
            child: Icon(icon, color: isDark ? primaryColor : const Color(0xFF2563EB), size: _largeTouchTargets ? 22 : 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: _largeTouchTargets ? 15.5 : 14,
                    fontWeight: FontWeight.w700,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: _largeTouchTargets ? 12.5 : 11.5,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          Transform.scale(
            scale: _largeTouchTargets ? 1.0 : 0.85,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}
