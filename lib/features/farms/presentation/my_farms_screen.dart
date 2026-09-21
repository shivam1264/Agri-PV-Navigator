import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/farm.dart';
import '../../../shared/widgets/farm_card.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import '../../../providers/farm_provider.dart';
import '../../../providers/report_provider.dart';

class MyFarmsScreen extends StatefulWidget {
  const MyFarmsScreen({super.key});

  @override
  State<MyFarmsScreen> createState() => _MyFarmsScreenState();
}

class _MyFarmsScreenState extends State<MyFarmsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FarmProvider>().loadFarms();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _confirmDeleteFarm(BuildContext context, Farm farm) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Farm?'),
        content: Text('Are you sure you want to delete "${farm.name}"? This action will also delete all associated reports.'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<FarmProvider>().deleteFarm(farm.id);
      if (context.mounted) {
        context.read<ReportProvider>().deleteReport('rep_prop_${farm.id}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text('Farm "${farm.name}" deleted.')),
              ],
            ),
            backgroundColor: const Color(0xFF1E293B),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final farmProv = context.watch<FarmProvider>();

    final filteredFarms = farmProv.farms.where((farm) {
      return farm.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          farm.location.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          farm.crop.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

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
        title: Text('My Farms', style: AppTypography.screenHeading.copyWith(fontSize: 20)),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isDark ? theme.cardColor : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: isDark ? theme.dividerColor : const Color(0xFFE2E8F0)),
              ),
              child: Icon(
                Icons.tune_rounded,
                size: 18,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            onPressed: () {},
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── Search + Add ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Column(
                children: [
                  // Search Bar
                  Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: isDark ? theme.cardColor : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: isDark ? theme.dividerColor : const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark ? Colors.white : const Color(0xFF1E293B),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search farms by name or crop...',
                        hintStyle: TextStyle(
                          color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                          fontSize: 14,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          size: 20,
                          color: isDark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                        ),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Add New Farm Button
                  GestureDetector(
                    onTap: () {
                      context.read<FarmProvider>().resetDraftFarm();
                      context.go('/farm-location');
                    },
                    child: Container(
                      width: double.infinity,
                      height: 44,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF123520) : const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark ? const Color(0xFF1B5E30) : const Color(0xFF86EFAC),
                          width: 1.2,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_rounded,
                            color: isDark ? const Color(0xFF00E676) : const Color(0xFF166534),
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            '+ Add New Farm',
                            style: TextStyle(
                              color: isDark ? const Color(0xFF00E676) : const Color(0xFF166534),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Farm count ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                children: [
                  Text(
                    '${filteredFarms.length} farm${filteredFarms.length == 1 ? '' : 's'}',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // ── Farm List ──
            Expanded(
              child: filteredFarms.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.agriculture_outlined, size: 48, color: Color(0xFFCBD5E1)),
                          const SizedBox(height: 12),
                          Text(
                            _searchQuery.isEmpty ? 'No farms yet.\nTap "+ Add New Farm" to begin.' : 'No farms match "$_searchQuery"',
                            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                      itemCount: filteredFarms.length,
                      itemBuilder: (context, index) {
                        final farm = filteredFarms[index];
                        return FarmCard(
                          farm: farm,
                          onTap: () {
                            farmProv.selectFarm(farm);
                            context.push('/farm-detail');
                          },
                          onDelete: () => _confirmDeleteFarm(context, farm),
                        );
                      },
                    ),
            ),

            BottomNavBar(
              currentIndex: 1,
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
}
