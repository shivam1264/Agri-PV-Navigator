import 'dart:io';
import 'package:flutter/material.dart';

class UserAvatar extends StatelessWidget {
  final String profileImage;
  final String initials;
  final double size;
  final double borderWidth;
  final Color? borderColor;
  final VoidCallback? onTap;
  final bool showEditBadge;

  const UserAvatar({
    super.key,
    required this.profileImage,
    required this.initials,
    this.size = 80,
    this.borderWidth = 3.0,
    this.borderColor,
    this.onTap,
    this.showEditBadge = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveBorder = borderColor ?? (isDark ? const Color(0xFF00E676) : const Color(0xFF22C55E));

    Widget imageWidget;
    if (profileImage.startsWith('http://') || profileImage.startsWith('https://')) {
      imageWidget = Image.network(
        profileImage,
        fit: BoxFit.cover,
        width: size,
        height: size,
        errorBuilder: (ctx, err, stack) => _buildInitialsFallback(isDark),
      );
    } else if (profileImage.startsWith('assets/')) {
      imageWidget = Image.asset(
        profileImage,
        fit: BoxFit.cover,
        width: size,
        height: size,
        errorBuilder: (ctx, err, stack) => _buildInitialsFallback(isDark),
      );
    } else if (profileImage.isNotEmpty) {
      final file = File(profileImage);
      bool isLocal = false;
      try {
        isLocal = file.existsSync() ||
            profileImage.startsWith('/') ||
            profileImage.contains(':\\') ||
            profileImage.contains('avatar_') ||
            profileImage.contains('image_picker');
      } catch (_) {
        isLocal = false;
      }

      if (isLocal) {
        imageWidget = Image.file(
          file,
          fit: BoxFit.cover,
          width: size,
          height: size,
          errorBuilder: (ctx, err, stack) => _buildInitialsFallback(isDark),
        );
      } else {
        imageWidget = _buildInitialsFallback(isDark);
      }
    } else {
      imageWidget = _buildInitialsFallback(isDark);
    }

    final avatarCircle = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: effectiveBorder, width: borderWidth),
        boxShadow: [
          BoxShadow(
            color: isDark ? effectiveBorder.withValues(alpha: 0.25) : const Color(0x18000000),
            blurRadius: size > 50 ? 12 : 4,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ClipOval(child: imageWidget),
    );

    if (!showEditBadge && onTap == null) {
      return avatarCircle;
    }

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          avatarCircle,
          if (showEditBadge)
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: effectiveBorder,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.cardColor,
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt_rounded,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInitialsFallback(bool isDark) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF0F3B20), const Color(0xFF042012)]
              : [const Color(0xFF166534), const Color(0xFF15803D)],
        ),
      ),
      child: Center(
        child: Text(
          initials.isNotEmpty ? initials : 'F',
          style: TextStyle(
            fontSize: size * 0.36,
            fontWeight: FontWeight.w800,
            color: isDark ? const Color(0xFF00E676) : Colors.white,
          ),
        ),
      ),
    );
  }
}
