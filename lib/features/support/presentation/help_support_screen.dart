import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final _expandedMap = <int, bool>{};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F7F4),
        elevation: 0,
        title: Text('Help & Support', style: AppTypography.screenHeading.copyWith(fontSize: 20)),
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
                  // ── Search ──
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 6, offset: Offset(0, 2))],
                    ),
                    child: const TextField(
                      decoration: InputDecoration(
                        hintText: 'Search help articles...',
                        hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                        prefixIcon: Icon(Icons.search_rounded, color: Color(0xFF94A3B8), size: 20),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ── Categories ──
                  _sectionLabel('Browse Topics'),
                  _expandableCategory(
                    index: 0,
                    icon: Icons.play_circle_outline_rounded,
                    iconBg: const Color(0xFFE0F2FE),
                    iconColor: const Color(0xFF0284C7),
                    title: 'Getting Started',
                    subtitle: 'Creating your first farm & mapping boundary',
                    faqs: const [
                      'How do I add a new farm?',
                      'How to draw farm boundary on the map?',
                      'What crop types are supported?',
                    ],
                  ),
                  _expandableCategory(
                    index: 1,
                    icon: Icons.touch_app_outlined,
                    iconBg: const Color(0xFFF0FFF4),
                    iconColor: AppColors.primary,
                    title: 'Using the App',
                    subtitle: 'Configuring tilts, spacing & clearance',
                    faqs: const [
                      'How to set solar panel tilt angle?',
                      'How do I configure row spacing?',
                      'What is the BCI score?',
                    ],
                  ),
                  _expandableCategory(
                    index: 2,
                    icon: Icons.build_outlined,
                    iconBg: const Color(0xFFFFF7ED),
                    iconColor: const Color(0xFFEA580C),
                    title: 'Technical Support',
                    subtitle: 'Troubleshooting 3D canvas & report generation',
                    faqs: const [
                      '3D view is not rendering correctly',
                      'PDF report is not generating',
                      'The app crashes on AR mode',
                    ],
                  ),
                  _expandableCategory(
                    index: 3,
                    icon: Icons.quiz_outlined,
                    iconBg: const Color(0xFFF3E8FF),
                    iconColor: const Color(0xFF7C3AED),
                    title: 'FAQs',
                    subtitle: 'Common questions on subsidies and yields',
                    faqs: const [
                      'Are there government subsidies for Agri-PV?',
                      'How much crop yield reduction to expect?',
                      'Can I integrate with existing solar systems?',
                    ],
                  ),

                  const SizedBox(height: 20),
                  _sectionLabel('Contact Us'),
                  Row(
                    children: [
                      Expanded(
                        child: _contactButton(
                          icon: Icons.email_outlined,
                          label: 'Email Support',
                          isPrimary: false,
                          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Opening support email...')),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _contactButton(
                          icon: Icons.chat_bubble_outline_rounded,
                          label: 'Live Chat',
                          isPrimary: true,
                          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Connecting to live chat...')),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
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
        padding: const EdgeInsets.only(bottom: 10, left: 2),
        child: Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B), letterSpacing: 0.5)),
      );

  Widget _expandableCategory({
    required int index,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required List<String> faqs,
  }) {
    final expanded = _expandedMap[index] ?? false;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8F5E9)),
        boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 6, offset: Offset(0, 2))],
      ),
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: [
            InkWell(
              onTap: () => setState(() => _expandedMap[index] = !expanded),
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 38,
                      height: 38,
                      decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(10)),
                      child: Icon(icon, color: iconColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Color(0xFF0F172A))),
                          Text(subtitle, style: const TextStyle(fontSize: 11.5, color: Color(0xFF64748B))),
                        ],
                      ),
                    ),
                    Icon(
                      expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      color: const Color(0xFF94A3B8),
                      size: 22,
                    ),
                  ],
                ),
              ),
            ),
            if (expanded) ...[
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              ...faqs.map((faq) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.arrow_forward_ios_rounded, size: 11, color: AppColors.primary),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(faq, style: const TextStyle(fontSize: 13, color: Color(0xFF334155), fontWeight: FontWeight.w500)),
                        ),
                      ],
                    ),
                  )),
              const SizedBox(height: 4),
            ],
          ],
        ),
      ),
    );
  }

  Widget _contactButton({
    required IconData icon,
    required String label,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isPrimary ? AppColors.primary : const Color(0xFFE2E8F0)),
          boxShadow: const [BoxShadow(color: Color(0x08000000), blurRadius: 6, offset: Offset(0, 2))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: isPrimary ? Colors.white : AppColors.primary),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: isPrimary ? Colors.white : AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
