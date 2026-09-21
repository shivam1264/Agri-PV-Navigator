import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../providers/settings_provider.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final void Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final settings = context.watch<SettingsProvider>();

    final verticalPadding = settings.largeTouchTargets ? 12.0 : 8.0;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0C120E) : theme.cardColor,
        border: Border(top: BorderSide(color: theme.dividerColor, width: settings.highContrast ? 2.0 : 1.0)),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.4) : AppColors.shadow,
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: verticalPadding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(context, 0, Icons.home_rounded, settings.tr('home'), settings),
              _buildNavItem(context, 1, Icons.agriculture_rounded, settings.tr('farms'), settings),
              _buildNavItem(context, 2, Icons.solar_power_rounded, settings.tr('design'), settings),
              _buildNavItem(context, 3, Icons.insert_drive_file_rounded, settings.tr('reports'), settings),
              _buildNavItem(context, 4, Icons.person_rounded, settings.tr('profile'), settings),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, int index, IconData icon, String label, SettingsProvider settings) {
    final isSelected = currentIndex == index;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;
    final unselectedColor = isDark ? const Color(0xFF718779) : AppColors.textSecondary;
    final selectedBg = isDark
        ? const Color(0xFF133520)
        : AppColors.primarySurface;

    final iconSize = settings.largeTouchTargets ? 25.0 : 22.0;
    final fontSize = settings.largeTouchTargets ? 12.5 : 11.0;
    final hPadding = settings.largeTouchTargets ? 16.0 : 14.0;
    final vPadding = settings.largeTouchTargets ? 8.0 : 6.0;

    return Semantics(
      label: label,
      selected: isSelected,
      button: true,
      child: InkWell(
        onTap: () => onTap(index),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: settings.reduceMotion ? Duration.zero : const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(horizontal: hPadding, vertical: vPadding),
          decoration: BoxDecoration(
            color: isSelected ? selectedBg : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: isSelected && settings.highContrast
                ? Border.all(color: primaryColor, width: 1.5)
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: iconSize,
                color: isSelected ? primaryColor : unselectedColor,
              ),
              const SizedBox(height: 3),
              Text(
                label,
                style: AppTypography.labelSmall.copyWith(
                  fontSize: fontSize,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? primaryColor : unselectedColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
