import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../../shared/widgets/user_avatar.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../models/user_profile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final picker = ImagePicker();
      XFile? pickedFile;

      try {
        pickedFile = await picker.pickImage(
          source: source,
          maxWidth: 1024,
          maxHeight: 1024,
          imageQuality: 85,
        );
      } catch (e) {
        debugPrint('[ProfileScreen] Pick image with compression failed: $e, trying raw picker');
        try {
          pickedFile = await picker.pickImage(source: source);
        } catch (innerErr) {
          debugPrint('[ProfileScreen] Raw picker also failed: $innerErr');
          rethrow;
        }
      }

      if (pickedFile == null) {
        // User backed out / cancelled selection
        return;
      }

      // Read image bytes and store permanently in app's document storage
      final bytes = await pickedFile.readAsBytes();
      final appDir = await getApplicationDocumentsDirectory();
      final avatarsDir = Directory('${appDir.path}/avatars');
      if (!await avatarsDir.exists()) {
        await avatarsDir.create(recursive: true);
      }

      final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final permanentFile = File('${avatarsDir.path}/$fileName');
      await permanentFile.writeAsBytes(bytes);

      if (context.mounted) {
        await context.read<AuthProvider>().updateProfile(profileImage: permanentFile.path);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Row(
                children: [
                  Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                  SizedBox(width: 8),
                  Text('Profile photo updated successfully!'),
                ],
              ),
              backgroundColor: Color(0xFF10B981),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('[ProfileScreen] Error picking/saving avatar: $e');
      if (context.mounted) {
        final errorText = e.toString().toLowerCase().contains('permission') ||
                e.toString().toLowerCase().contains('denied')
            ? 'Storage/Photos permission denied. Please allow permission in Settings.'
            : 'Could not access image: Please choose another photo.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorText),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ── Avatar Picker Bottom Sheet ──────────────────────────────────────────────
  void _showAvatarPickerSheet(BuildContext context, UserProfile user) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final settings = context.read<SettingsProvider>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: Border.all(
            color: settings.highContrast ? theme.colorScheme.primary : theme.dividerColor,
            width: settings.highContrast ? 2.0 : 1.0,
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
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
            const SizedBox(height: 18),
            Text(
              'Profile Photo',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: theme.colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Upload a photo from your gallery or capture using camera',
              style: TextStyle(
                fontSize: 13,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 20),

            // Option 1: Gallery
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              tileColor: isDark ? const Color(0xFF161F1A) : const Color(0xFFF8FAFC),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.photo_library_rounded, color: AppColors.primary, size: 22),
              ),
              title: const Text('Choose from Gallery', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5)),
              subtitle: const Text('Select any picture from your device', style: TextStyle(fontSize: 12)),
              trailing: const Icon(Icons.chevron_right_rounded, size: 20),
              onTap: () {
                Navigator.pop(sheetCtx);
                _pickImage(context, ImageSource.gallery);
              },
            ),
            const SizedBox(height: 10),

            // Option 2: Camera
            ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              tileColor: isDark ? const Color(0xFF161F1A) : const Color(0xFFF8FAFC),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withValues(alpha: isDark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF3B82F6), size: 22),
              ),
              title: const Text('Take Photo', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5)),
              subtitle: const Text('Use your phone camera', style: TextStyle(fontSize: 12)),
              trailing: const Icon(Icons.chevron_right_rounded, size: 20),
              onTap: () {
                Navigator.pop(sheetCtx);
                _pickImage(context, ImageSource.camera);
              },
            ),

            if (user.profileImage.isNotEmpty) ...[
              const SizedBox(height: 10),
              ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                tileColor: isDark ? const Color(0xFF261818) : const Color(0xFFFFF1F2),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 22),
                ),
                title: const Text('Remove Photo', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.5, color: Colors.red)),
                subtitle: const Text('Revert to default initials', style: TextStyle(fontSize: 12)),
                onTap: () async {
                  Navigator.pop(sheetCtx);
                  await context.read<AuthProvider>().updateProfile(profileImage: '');
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Profile photo removed'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Edit Profile Bottom Sheet ──────────────────────────────────────────────
  void _showEditProfileSheet(BuildContext context, UserProfile user) {
    final nameCtrl = TextEditingController(text: user.name);
    final phoneCtrl = TextEditingController(text: user.phone);
    final formKey = GlobalKey<FormState>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final settings = context.read<SettingsProvider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(sheetCtx).viewInsets.bottom),
        child: Container(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: settings.highContrast ? theme.colorScheme.primary : theme.dividerColor,
              width: settings.highContrast ? 2.0 : 1.0,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Drag handle
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
                Text(
                  settings.tr('edit_profile'),
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),

                // Avatar Change Preview
                Center(
                  child: Column(
                    children: [
                      UserAvatar(
                        profileImage: user.profileImage,
                        initials: user.initials,
                        size: 72,
                        showEditBadge: true,
                        onTap: () {
                          Navigator.pop(sheetCtx);
                          _showAvatarPickerSheet(context, user);
                        },
                      ),
                      const SizedBox(height: 6),
                      TextButton.icon(
                        onPressed: () {
                          Navigator.pop(sheetCtx);
                          _showAvatarPickerSheet(context, user);
                        },
                        icon: const Icon(Icons.photo_camera_rounded, size: 16),
                        label: const Text('Change Photo', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Full Name
                Text(
                  settings.tr('full_name'),
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: nameCtrl,
                  style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: settings.tr('enter_name'),
                    prefixIcon: Icon(Icons.person_outline_rounded, size: 18, color: theme.colorScheme.primary),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF090D0B) : const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.dividerColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.dividerColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.colorScheme.primary, width: 2.0),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: settings.largeTouchTargets ? 18 : 13,
                      horizontal: 14,
                    ),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? settings.tr('name_required') : null,
                ),
                const SizedBox(height: 16),

                // Phone
                Text(
                  settings.tr('phone_number'),
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: settings.tr('phone_hint'),
                    prefixIcon: Icon(Icons.phone_outlined, size: 18, color: theme.colorScheme.primary),
                    filled: true,
                    fillColor: isDark ? const Color(0xFF090D0B) : const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.dividerColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.dividerColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: theme.colorScheme.primary, width: 2.0),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      vertical: settings.largeTouchTargets ? 18 : 13,
                      horizontal: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Save Button
                Consumer<AuthProvider>(
                  builder: (ctx, auth, _) => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: EdgeInsets.symmetric(vertical: settings.largeTouchTargets ? 18 : 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      onPressed: auth.isLoading
                          ? null
                          : () async {
                              if (!formKey.currentState!.validate()) return;
                              final success = await ctx.read<AuthProvider>().updateProfile(
                                    fullName: nameCtrl.text.trim(),
                                    phoneNumber: phoneCtrl.text.trim(),
                                  );
                              if (sheetCtx.mounted) Navigator.pop(sheetCtx);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      success ? settings.tr('profile_updated') : (auth.error ?? settings.tr('profile_update_failed')),
                                    ),
                                    backgroundColor: success ? const Color(0xFF10B981) : Colors.red,
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              }
                            },
                      child: auth.isLoading
                          ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(
                              settings.tr('save_changes'),
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final authProv = context.watch<AuthProvider>();
    final settings = context.watch<SettingsProvider>();

    final user = authProv.user ??
        const UserProfile(
          id: '',
          name: 'Farmer',
          email: 'farmer@example.com',
          phone: '',
          initials: 'SP',
          totalFarms: 0,
          totalAreaAcres: 0.0,
          designsCreated: 0,
        );

    final areaDisplay = settings.formatArea(user.totalAreaAcres);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          context.go('/home');
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          settings.tr('profile'),
          style: AppTypography.screenHeading.copyWith(
            fontSize: 21,
            color: theme.colorScheme.onSurface,
            fontWeight: FontWeight.w800,
          ),
        ),
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
                    // ── Profile Header Card ──
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: settings.highContrast ? theme.colorScheme.primary : theme.dividerColor,
                          width: settings.highContrast ? 2.0 : 1.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? Colors.black.withValues(alpha: 0.3) : const Color(0x08000000),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Editable Avatar with camera badge
                          UserAvatar(
                            profileImage: user.profileImage,
                            initials: user.initials,
                            size: 84,
                            showEditBadge: true,
                            onTap: () => _showAvatarPickerSheet(context, user),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            user.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: theme.colorScheme.onSurface,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            user.email,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (user.phone.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(
                              user.phone,
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
                          // Stats Row with crisp Obsidian separators
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _profileStat(context, '${user.totalFarms}', settings.tr('stat_farms'), settings),
                              Container(height: 28, width: 1, color: theme.dividerColor),
                              _profileStat(context, areaDisplay, settings.tr('stat_total_area'), settings),
                              Container(height: 28, width: 1, color: theme.dividerColor),
                              _profileStat(context, '${user.designsCreated}', settings.tr('stat_designs'), settings),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Quick Preferences Interactive Strip ──
                    Row(
                      children: [
                        Expanded(
                          child: _quickPill(
                            context: context,
                            icon: settings.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                            iconColor: settings.isDarkMode ? const Color(0xFF6366F1) : const Color(0xFFEAB308),
                            label: settings.isDarkMode ? settings.tr('theme_dark') : settings.tr('theme_light'),
                            settings: settings,
                            onTap: () => settings.toggleTheme(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _quickPill(
                            context: context,
                            icon: Icons.language_rounded,
                            iconColor: const Color(0xFF38BDF8),
                            label: settings.isHindi ? 'हिंदी' : 'English',
                            settings: settings,
                            onTap: () => settings.toggleLanguage(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _quickPill(
                            context: context,
                            icon: Icons.straighten_rounded,
                            iconColor: const Color(0xFFF59E0B),
                            label: settings.units.contains('Hectares')
                                ? 'Hectares'
                                : (settings.units.contains('Imperial') ? 'Imperial' : 'Metric'),
                            settings: settings,
                            onTap: () => settings.cycleUnits(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // ── Menu Section Card ──
                    _menuSection(context, settings, [
                      _MenuItem(
                        icon: Icons.person_outline_rounded,
                        label: settings.tr('my_profile'),
                        settings: settings,
                        onTap: () => _showEditProfileSheet(context, user),
                      ),
                      _MenuItem(
                        icon: Icons.agriculture_outlined,
                        label: settings.tr('my_farms'),
                        settings: settings,
                        onTap: () => context.push('/farms'),
                      ),
                      _MenuItem(
                        icon: Icons.settings_outlined,
                        label: settings.tr('app_settings'),
                        settings: settings,
                        onTap: () => context.push('/settings'),
                      ),
                      _MenuItem(
                        icon: Icons.help_outline_rounded,
                        label: settings.tr('help_support'),
                        settings: settings,
                        onTap: () => context.push('/help-support'),
                      ),
                      _MenuItem(
                        icon: Icons.info_outline_rounded,
                        label: settings.tr('about'),
                        settings: settings,
                        onTap: () => context.push('/about'),
                      ),
                    ]),
                    const SizedBox(height: 14),

                    // ── Logout Card ──
                    _menuSection(context, settings, [
                      _MenuItem(
                        icon: Icons.logout_rounded,
                        label: settings.tr('logout'),
                        isDestructive: true,
                        settings: settings,
                        onTap: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (dlgCtx) => AlertDialog(
                              backgroundColor: theme.cardColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                                side: BorderSide(
                                  color: settings.highContrast ? const Color(0xFFEF4444) : theme.dividerColor,
                                  width: settings.highContrast ? 2.0 : 1.0,
                                ),
                              ),
                              title: Text(
                                settings.tr('logout'),
                                style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold),
                              ),
                              content: Text(
                                settings.tr('logout_confirm'),
                                style: TextStyle(color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(dlgCtx, false),
                                  child: Text(settings.tr('cancel')),
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFFEF4444),
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                  ),
                                  onPressed: () => Navigator.pop(dlgCtx, true),
                                  child: Text(settings.tr('logout'), style: const TextStyle(fontWeight: FontWeight.w700)),
                                ),
                              ],
                            ),
                          );

                          if (confirmed == true && context.mounted) {
                            await context.read<AuthProvider>().logout();
                            if (context.mounted) {
                              context.go('/login');
                            }
                          }
                        },
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
    ),
    );
  }

  Widget _quickPill({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String label,
    required SettingsProvider settings,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final vPad = settings.largeTouchTargets ? 14.0 : 10.0;
    final fSize = settings.largeTouchTargets ? 13.0 : 11.5;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: vPad, horizontal: 8),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: settings.highContrast ? theme.colorScheme.primary : theme.dividerColor,
              width: settings.highContrast ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: settings.largeTouchTargets ? 18 : 15, color: iconColor),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: fSize,
                    fontWeight: FontWeight.w700,
                    color: isDark ? const Color(0xFFF1F5F9) : const Color(0xFF334155),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileStat(BuildContext context, String val, String label, SettingsProvider settings) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        Text(
          val,
          style: TextStyle(
            fontSize: settings.largeTouchTargets ? 17 : 15,
            fontWeight: FontWeight.w800,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: settings.largeTouchTargets ? 12 : 11,
            color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _menuSection(BuildContext context, SettingsProvider settings, List<_MenuItem> items) {
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
          for (int i = 0; i < items.length; i++) ...[
            if (i > 0) Divider(height: 1, color: theme.dividerColor, indent: settings.largeTouchTargets ? 64 : 56),
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
  final SettingsProvider settings;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
    required this.settings,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final color = isDestructive
        ? const Color(0xFFEF4444)
        : theme.colorScheme.onSurface;

    final iconBg = isDestructive
        ? (isDark ? const Color(0xFF3B1212) : const Color(0xFFFEF2F2))
        : (isDark ? const Color(0xFF142B1E) : const Color(0xFFF0FFF4));

    final iconColor = isDestructive
        ? const Color(0xFFEF4444)
        : (isDark ? const Color(0xFF00E676) : AppColors.primary);

    final vPadding = settings.largeTouchTargets ? 18.0 : 13.0;
    final iconBoxSize = settings.largeTouchTargets ? 42.0 : 36.0;
    final iconSize = settings.largeTouchTargets ? 21.0 : 18.0;
    final fontSize = settings.largeTouchTargets ? 16.0 : 14.5;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: vPadding),
          child: Row(
            children: [
              Container(
                width: iconBoxSize,
                height: iconBoxSize,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                  border: settings.highContrast
                      ? Border.all(color: iconColor, width: 1.0)
                      : null,
                ),
                child: Icon(icon, color: iconColor, size: iconSize),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600, color: color),
                ),
              ),
              if (!isDestructive)
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
