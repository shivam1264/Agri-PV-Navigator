import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/settings_provider.dart';
import '../../../providers/support_provider.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../data/faq_knowledge_base.dart';
import 'widgets/agri_pv_live_chat_sheet.dart';

class HelpSupportScreen extends StatefulWidget {
  const HelpSupportScreen({super.key});

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  final Map<int, bool> _categoryExpandedMap = {0: true, 1: false, 2: false, 3: false};
  final Map<String, bool> _questionExpandedMap = {};
  final Map<String, bool?> _feedbackMap = {}; // questionId -> true (helpful), false (unhelpful)
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchCtrl.addListener(() {
      setState(() {
        _searchQuery = _searchCtrl.text.trim();
      });
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SupportProvider>().loadFaqs();
    });
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  void _showTicketDialog(BuildContext context) {
    final subjectCtrl = TextEditingController();
    final messageCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Contact Support'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: subjectCtrl,
              decoration: const InputDecoration(
                labelText: 'Subject',
                hintText: 'e.g. Question about solar clearance',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: messageCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Message',
                hintText: 'Describe your issue or request...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              final subject = subjectCtrl.text.trim();
              final msg = messageCtrl.text.trim();
              if (subject.isEmpty || msg.isEmpty) return;

              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(ctx);

              final success = await context.read<SupportProvider>().createTicket(
                    subject: subject,
                    message: msg,
                  );

              messenger.showSnackBar(
                SnackBar(
                  content: Text(success ? 'Support ticket submitted successfully!' : 'Failed to submit ticket'),
                  backgroundColor: success ? AppColors.primary : Colors.red,
                ),
              );
            },
            child: const Text('Submit', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isHindi = context.watch<SettingsProvider>().isHindi;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          isHindi ? 'सहायता एवं समर्थन' : 'Help & Support',
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
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                children: [
                  // ── Search Bar ──
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: isDark ? theme.cardColor : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: theme.dividerColor),
                      boxShadow: [
                        BoxShadow(
                          color: isDark ? Colors.black54 : const Color(0x06000000),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchCtrl,
                      style: TextStyle(color: isDark ? Colors.white : null, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: isHindi ? 'प्रश्न या समाधान खोजें...' : 'Search questions, tilts, subsidies...',
                        hintStyle: TextStyle(
                          color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(Icons.search_rounded, color: isDark ? AppColors.accent : const Color(0xFF94A3B8), size: 20),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 18),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ── Live Search Results or Category Accordions ──
                  if (_searchQuery.isNotEmpty) ...[
                    _buildSearchResults(isDark, isHindi),
                  ] else ...[
                    _sectionLabel(isHindi ? 'विषय ब्राउज़ करें' : 'Browse Topics'),

                    // 1. Getting Started
                    _buildCategoryTile(
                      index: 0,
                      categoryName: 'Getting Started',
                      icon: Icons.play_circle_outline_rounded,
                      iconBg: const Color(0xFFE0F2FE),
                      iconColor: const Color(0xFF0284C7),
                      title: isHindi ? 'शुरुआत कैसे करें' : 'Getting Started',
                      subtitle: isHindi ? 'खेत जोड़ना एवं सीमांकन' : 'Creating your first farm & mapping boundary',
                      isDark: isDark,
                      isHindi: isHindi,
                    ),

                    // 2. Using the App
                    _buildCategoryTile(
                      index: 1,
                      categoryName: 'Using the App',
                      icon: Icons.touch_app_outlined,
                      iconBg: const Color(0xFFF0FFF4),
                      iconColor: AppColors.primary,
                      title: isHindi ? 'ऐप का उपयोग' : 'Using the App',
                      subtitle: isHindi ? 'झुकाव, कतार दूरी व क्लीयरेंस' : 'Configuring tilts, spacing & clearance',
                      isDark: isDark,
                      isHindi: isHindi,
                    ),

                    // 3. Technical Support
                    _buildCategoryTile(
                      index: 2,
                      categoryName: 'Technical Support',
                      icon: Icons.build_outlined,
                      iconBg: const Color(0xFFFFF7ED),
                      iconColor: const Color(0xFFEA580C),
                      title: isHindi ? 'तकनीकी सहायता' : 'Technical Support',
                      subtitle: isHindi ? '3D कैनवास व रिपोर्ट का समाधान' : 'Troubleshooting 3D canvas & report generation',
                      isDark: isDark,
                      isHindi: isHindi,
                    ),

                    // 4. FAQs
                    _buildCategoryTile(
                      index: 3,
                      categoryName: 'FAQs',
                      icon: Icons.quiz_outlined,
                      iconBg: const Color(0xFFF3E8FF),
                      iconColor: const Color(0xFF7C3AED),
                      title: isHindi ? 'सामान्य प्रश्न (FAQs)' : 'FAQs',
                      subtitle: isHindi ? 'सब्सिडी, उपज व वित्तीय लाभ' : 'Common questions on subsidies and yields',
                      isDark: isDark,
                      isHindi: isHindi,
                    ),
                  ],

                  const SizedBox(height: 20),

                  // ── Contact Us ──
                  _sectionLabel(isHindi ? 'हमसे संपर्क करें' : 'Contact Us'),
                  Row(
                    children: [
                      Expanded(
                        child: _contactButton(
                          icon: Icons.email_outlined,
                          label: isHindi ? 'ईमेल सहायता' : 'Email Support',
                          isPrimary: false,
                          onTap: () => _showTicketDialog(context),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _contactButton(
                          icon: Icons.chat_bubble_outline_rounded,
                          label: isHindi ? 'लाइव चैट' : 'Live Chat',
                          isPrimary: true,
                          onTap: () => AgriPvLiveChatSheet.show(context),
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
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF64748B),
            letterSpacing: 0.5,
          ),
        ),
      );

  Widget _buildSearchResults(bool isDark, bool isHindi) {
    final matches = FaqKnowledgeBase.search(_searchQuery, isHindi: isHindi);

    if (matches.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? Theme.of(context).cardColor : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Theme.of(context).dividerColor),
        ),
        child: Column(
          children: [
            Icon(Icons.search_off_rounded, size: 44, color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
            const SizedBox(height: 12),
            Text(
              isHindi ? 'कोई उत्तर नहीं मिला' : 'No direct matches found',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              isHindi
                  ? 'चिंता न करें! आप सीधे लाइव चैट में डॉ. अरुणा राव (कृषि विशेषज्ञ) से पूछ सकते हैं।'
                  : "Don't worry! You can ask Dr. Aruna Rao directly in Live Chat for personalized guidance.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.5,
                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              ),
            ),
            const SizedBox(height: 14),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
              label: Text(isHindi ? 'लाइव चैट में पूछें' : 'Ask in Live Chat'),
              onPressed: () => AgriPvLiveChatSheet.show(context),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10, left: 2),
          child: Text(
            isHindi ? 'खोज परिणाम (${matches.length})' : 'Search Results (${matches.length})',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF64748B)),
          ),
        ),
        ...matches.map((item) => _buildQuestionItem(item, isDark, isHindi)),
      ],
    );
  }

  Widget _buildCategoryTile({
    required int index,
    required String categoryName,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isDark,
    required bool isHindi,
  }) {
    final theme = Theme.of(context);
    final isExpanded = _categoryExpandedMap[index] ?? false;
    final categoryItems = FaqKnowledgeBase.getByCategory(categoryName);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: isDark ? theme.cardColor : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black54 : const Color(0x06000000),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Column(
          children: [
            InkWell(
              onTap: () => setState(() => _categoryExpandedMap[index] = !isExpanded),
              borderRadius: BorderRadius.circular(16),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: isDark ? iconColor.withValues(alpha: 0.15) : iconBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: iconColor, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
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
                    Icon(
                      isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                      color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded) ...[
              Divider(height: 1, color: theme.dividerColor),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  children: categoryItems.map((item) => _buildQuestionItem(item, isDark, isHindi)).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionItem(FaqItem item, bool isDark, bool isHindi) {
    final theme = Theme.of(context);
    final isOpen = _questionExpandedMap[item.id] ?? false;
    final feedback = _feedbackMap[item.id];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isOpen
            ? (isDark ? const Color(0xFF131D26) : const Color(0xFFF8FAFC))
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: isOpen ? Border.all(color: AppColors.primary.withValues(alpha: 0.3)) : null,
      ),
      child: Column(
        children: [
          // Question Row
          InkWell(
            onTap: () => setState(() => _questionExpandedMap[item.id] = !isOpen),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
              child: Row(
                children: [
                  Icon(
                    isOpen ? Icons.keyboard_arrow_down_rounded : Icons.arrow_forward_ios_rounded,
                    size: isOpen ? 16 : 11,
                    color: isDark ? AppColors.accent : AppColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item.getQuestion(isHindi),
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: isOpen ? FontWeight.w700 : FontWeight.w600,
                        color: isOpen
                            ? (isDark ? AppColors.accent : AppColors.primary)
                            : (isDark ? const Color(0xFFCBD5E1) : const Color(0xFF1E293B)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Expanded Human Expert Answer Card
          if (isOpen) ...[
            Padding(
              padding: const EdgeInsets.only(left: 14, right: 14, bottom: 14, top: 4),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: theme.dividerColor),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black45 : const Color(0x06000000),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Expert Persona Header
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: item.persona.badgeColor.withValues(alpha: 0.15),
                          child: Icon(item.persona.icon, color: item.persona.badgeColor, size: 18),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    item.persona.name,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w700,
                                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(Icons.verified_rounded, size: 14, color: item.persona.badgeColor),
                                ],
                              ),
                              Text(
                                item.getRole(isHindi),
                                style: TextStyle(
                                  fontSize: 10.5,
                                  color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Divider(height: 1, color: theme.dividerColor),
                    const SizedBox(height: 12),

                    // Conversational Answer Text
                    Text(
                      item.getAnswer(isHindi),
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.5,
                        color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                      ),
                    ),

                    // Action Shortcut Button
                    if (item.actionRoute != null && item.getActionLabel(isHindi) != null) ...[
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.arrow_forward_rounded, size: 16),
                          label: Text(
                            item.getActionLabel(isHindi)!,
                            style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
                          ),
                          onPressed: () => context.push(item.actionRoute!),
                        ),
                      ),
                    ],

                    const SizedBox(height: 12),
                    Divider(height: 1, color: theme.dividerColor),
                    const SizedBox(height: 8),

                    // Was this helpful feedback
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          feedback == null
                              ? (isHindi ? 'क्या यह उत्तर उपयोगी था?' : 'Was this helpful?')
                              : (feedback
                                  ? (isHindi ? 'धन्यवाद! हमें खुशी है कि मदद मिली।' : 'Thanks! Glad it helped.')
                                  : (isHindi ? 'प्रतिक्रिया के लिए धन्यवाद।' : 'Thanks for letting us know.')),
                          style: TextStyle(
                            fontSize: 11,
                            fontStyle: feedback != null ? FontStyle.italic : FontStyle.normal,
                            color: feedback != null
                                ? AppColors.primary
                                : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
                          ),
                        ),
                        if (feedback == null) ...[
                          Row(
                            children: [
                              InkWell(
                                onTap: () => setState(() => _feedbackMap[item.id] = true),
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.thumb_up_alt_outlined, size: 14, color: AppColors.primary),
                                      const SizedBox(width: 4),
                                      Text(
                                        isHindi ? 'हाँ' : 'Yes',
                                        style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600, color: AppColors.primary),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              InkWell(
                                onTap: () => setState(() => _feedbackMap[item.id] = false),
                                borderRadius: BorderRadius.circular(8),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                  child: Row(
                                    children: [
                                      Icon(Icons.thumb_down_alt_outlined, size: 14, color: isDark ? Colors.white54 : Colors.grey),
                                      const SizedBox(width: 4),
                                      Text(
                                        isHindi ? 'नहीं' : 'No',
                                        style: TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w600,
                                          color: isDark ? Colors.white54 : Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _contactButton({
    required IconData icon,
    required String label,
    required bool isPrimary,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primary : (isDark ? theme.cardColor : Colors.white),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isPrimary ? AppColors.primary : theme.dividerColor,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black54 : const Color(0x08000000),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isPrimary ? Colors.white : (isDark ? AppColors.accent : AppColors.primary),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: isPrimary ? Colors.white : (isDark ? Colors.white : AppColors.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
