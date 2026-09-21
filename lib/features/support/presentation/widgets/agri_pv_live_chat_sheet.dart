import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../providers/settings_provider.dart';
import '../../../../providers/support_provider.dart';
import '../../data/faq_knowledge_base.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime time;
  final FaqPersona? persona;
  final String? actionLabel;
  final String? actionRoute;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.time,
    this.persona,
    this.actionLabel,
    this.actionRoute,
  });
}

class AgriPvLiveChatSheet extends StatefulWidget {
  const AgriPvLiveChatSheet({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const AgriPvLiveChatSheet(),
    );
  }

  @override
  State<AgriPvLiveChatSheet> createState() => _AgriPvLiveChatSheetState();
}

class _AgriPvLiveChatSheetState extends State<AgriPvLiveChatSheet> with TickerProviderStateMixin {
  final TextEditingController _textCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  Timer? _typingTimer;

  // Prompts for instant discovery
  late final List<Map<String, String>> _quickChips;

  @override
  void initState() {
    super.initState();
    _quickChips = [
      {'en': '💰 PM-KUSUM Subsidies', 'hi': '💰 पीएम-कुसुम सब्सिडी', 'q': 'Are there government subsidies for Agri-PV?'},
      {'en': '🌾 Best crops for solar', 'hi': '🌾 सोलर के लिए उत्तम फसलें', 'q': 'What crop types are supported?'},
      {'en': '📐 Optimal tilt & spacing', 'hi': '📐 सही झुकाव व कतार दूरी', 'q': 'How to set solar panel tilt angle?'},
      {'en': '📊 Explain BCI Score', 'hi': '📊 बीसीआई स्कोर क्या है?', 'q': 'What is the BCI score?'},
      {'en': '🚜 Machinery clearance', 'hi': '🚜 ट्रैक्टर क्लीयरेंस ऊंचाई', 'q': 'What clearance height is needed for farm machinery & tractors?'},
      {'en': '💧 Water savings', 'hi': '💧 सिंचाई पानी की बचत', 'q': 'How does Agri-PV affect soil moisture and irrigation water savings?'},
      {'en': '🛠️ 3D Canvas help', 'hi': '🛠️ 3D कैनवास समस्या', 'q': '3D view is not rendering correctly'},
    ];

    // Seed initial expert greeting
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final isHindi = context.read<SettingsProvider>().isHindi;
      final greeting = isHindi
          ? "नमस्ते! मैं डॉ. अरुणा राव हूँ, एग्री-पीवी नेविगेटर की मुख्य कृषि वैज्ञानिक। आज मैं आपके खेत में सोलर और खेती के सर्वोत्तम तालमेल के लिए क्या सहायता कर सकती हूँ?"
          : "Hello! I am Dr. Aruna Rao, Lead Agronomist at Agri-PV Navigator. How can I help you optimize your dual-use solar farm today?";

      setState(() {
        _messages.add(ChatMessage(
          text: greeting,
          isUser: false,
          time: DateTime.now(),
          persona: FaqPersona.aruna,
        ));
      });
    });
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSend([String? presetText]) {
    final query = presetText ?? _textCtrl.text.trim();
    if (query.isEmpty) return;

    final isHindi = context.read<SettingsProvider>().isHindi;
    _textCtrl.clear();

    // 1. Add user message
    setState(() {
      _messages.add(ChatMessage(
        text: query,
        isUser: true,
        time: DateTime.now(),
      ));
      _isTyping = true;
    });
    _scrollToBottom();

    // 2. Simulate realistic expert typing delay (700-1100ms)
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(milliseconds: 850), () {
      if (!mounted) return;

      // Find best matching answer from knowledge base
      final matches = FaqKnowledgeBase.search(query, isHindi: isHindi);
      ChatMessage responseMsg;

      if (matches.isNotEmpty) {
        final best = matches.first;
        responseMsg = ChatMessage(
          text: best.getAnswer(isHindi),
          isUser: false,
          time: DateTime.now(),
          persona: best.persona,
          actionLabel: best.getActionLabel(isHindi),
          actionRoute: best.actionRoute,
        );
      } else {
        // Conversational fallback
        final fallback = isHindi
            ? "यह बहुत अच्छा सवाल है! आपके इस विशिष्ट सवाल के लिए मैं हमारे फील्ड इंजीनियर से संपर्क करने की सलाह देती हूँ।\n\nआप हमारे सहायता केंद्र पर टिकट जमा कर सकते हैं या नीचे दिए गए बटन से सीधे हमारे इंजीनियर से जुड़ सकते हैं।"
            : "That's an insightful question! For this specific query, I recommend having our technical field engineers review your coordinates.\n\nYou can submit a support ticket directly below and our team will get back to you within 24 hours.";

        responseMsg = ChatMessage(
          text: fallback,
          isUser: false,
          time: DateTime.now(),
          persona: FaqPersona.aruna,
          actionLabel: isHindi ? 'सपोर्ट टिकट सबमिट करें' : 'Submit Support Ticket',
          actionRoute: 'TICKET_DIALOG',
        );
      }

      setState(() {
        _isTyping = false;
        _messages.add(responseMsg);
      });
      _scrollToBottom();
    });
  }

  void _showTicketDialog() {
    final subjectCtrl = TextEditingController(text: 'Assistance requested via Live Chat');
    final messageCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Contact Support Team'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: subjectCtrl,
              decoration: const InputDecoration(labelText: 'Subject'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: messageCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Message',
                hintText: 'Describe your query for our technical team...',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            onPressed: () async {
              final msg = messageCtrl.text.trim();
              if (msg.isEmpty) return;
              Navigator.pop(ctx);
              final success = await context.read<SupportProvider>().createTicket(
                    subject: subjectCtrl.text.trim(),
                    message: msg,
                  );
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(success ? 'Ticket created successfully!' : 'Failed to create ticket'),
                    backgroundColor: success ? AppColors.primary : Colors.red,
                  ),
                );
              }
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
    final size = MediaQuery.of(context).size;

    return Container(
      height: size.height * 0.88,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Drag Handle ──
          Container(
            margin: const EdgeInsets.only(top: 10, bottom: 6),
            width: 44,
            height: 4.5,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(3),
            ),
          ),

          // ── Live Assistant Header ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
            child: Row(
              children: [
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 21,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                      child: const Icon(Icons.eco_rounded, color: AppColors.primary, size: 24),
                    ),
                    PositionedDirectional(
                      end: 0,
                      bottom: 0,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981), // Live green
                          shape: BoxShape.circle,
                          border: Border.all(color: isDark ? const Color(0xFF0F172A) : Colors.white, width: 2),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            isHindi ? 'डॉ. अरुणा राव (एग्री-पीवी विशेषज्ञ)' : 'Dr. Aruna Rao (Agri-PV Expert)',
                            style: TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Icon(Icons.verified_rounded, color: Color(0xFF0284C7), size: 16),
                        ],
                      ),
                      Text(
                        isHindi ? 'ऑनलाइन • तुरंत उत्तर देने के लिए तैयार' : 'Online • Institutional Agronomist & Solar Engineer',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: isDark ? Colors.white70 : const Color(0xFF64748B)),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: theme.dividerColor),

          // ── Quick Discovery Chips ──
          Container(
            height: 44,
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _quickChips.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, idx) {
                final chip = _quickChips[idx];
                final label = isHindi ? chip['hi']! : chip['en']!;
                return ActionChip(
                  backgroundColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                  side: BorderSide(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  label: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF334155),
                    ),
                  ),
                  onPressed: () => _handleSend(chip['q']),
                );
              },
            ),
          ),
          Divider(height: 1, color: theme.dividerColor),

          // ── Messages List ──
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, idx) {
                if (idx == _messages.length && _isTyping) {
                  return _buildTypingBubble(isDark, isHindi);
                }
                return _buildMessageBubble(_messages[idx], isDark, isHindi);
              },
            ),
          ),

          // ── Bottom Input Row ──
          Container(
            padding: EdgeInsets.only(
              left: 14,
              right: 14,
              top: 10,
              bottom: MediaQuery.of(context).viewInsets.bottom + 12,
            ),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              border: Border(top: BorderSide(color: theme.dividerColor)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: theme.dividerColor),
                    ),
                    child: TextField(
                      controller: _textCtrl,
                      style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 13.5),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _handleSend(),
                      decoration: InputDecoration(
                        hintText: isHindi ? 'डॉ. अरुणा से एग्री-पीवी संबंधी कुछ भी पूछें...' : 'Ask Dr. Aruna anything about Agri-PV...',
                        hintStyle: TextStyle(
                          color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                          fontSize: 13,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Material(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(24),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(24),
                    onTap: () => _handleSend(),
                    child: const Padding(
                      padding: EdgeInsets.all(11),
                      child: Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingBubble(bool isDark, bool isHindi) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: AppColors.primary.withValues(alpha: 0.15),
            child: const Icon(Icons.eco_rounded, color: AppColors.primary, size: 16),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  isHindi ? 'डॉ. अरुणा उत्तर तैयार कर रही हैं...' : 'Dr. Aruna is typing...',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontStyle: FontStyle.italic,
                    color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, bool isDark, bool isHindi) {
    final align = msg.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bubbleColor = msg.isUser
        ? AppColors.primary
        : (isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC));
    final textColor = msg.isUser
        ? Colors.white
        : (isDark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A));

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: align,
        children: [
          Row(
            mainAxisAlignment: msg.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!msg.isUser) ...[
                CircleAvatar(
                  radius: 14,
                  backgroundColor: (msg.persona?.badgeColor ?? AppColors.primary).withValues(alpha: 0.15),
                  child: Icon(
                    msg.persona?.icon ?? Icons.eco_rounded,
                    color: msg.persona?.badgeColor ?? AppColors.primary,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Flexible(
                child: Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.78),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                  decoration: BoxDecoration(
                    color: bubbleColor,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: Radius.circular(msg.isUser ? 16 : 4),
                      bottomRight: Radius.circular(msg.isUser ? 4 : 16),
                    ),
                    border: msg.isUser
                        ? null
                        : Border.all(color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!msg.isUser && msg.persona != null) ...[
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              msg.persona!.name,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: msg.persona!.badgeColor,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '• ${isHindi ? msg.persona!.roleHi : msg.persona!.roleEn}',
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                      ],
                      Text(
                        msg.text,
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.45,
                          color: textColor,
                        ),
                      ),
                      if (msg.actionLabel != null && msg.actionRoute != null) ...[
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.arrow_forward_rounded, size: 14),
                            label: Text(
                              msg.actionLabel!,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                            ),
                            onPressed: () {
                              if (msg.actionRoute == 'TICKET_DIALOG') {
                                _showTicketDialog();
                              } else {
                                Navigator.pop(context);
                                context.push(msg.actionRoute!);
                              }
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4, left: 36, right: 8),
            child: Text(
              '${msg.time.hour.toString().padLeft(2, '0')}:${msg.time.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 10,
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
