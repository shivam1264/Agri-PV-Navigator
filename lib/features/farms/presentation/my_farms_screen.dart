import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/farm_card.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../../providers/farm_provider.dart';

class MyFarmsScreen extends ConsumerStatefulWidget {
  const MyFarmsScreen({super.key});

  @override
  ConsumerState<MyFarmsScreen> createState() => _MyFarmsScreenState();
}

class _MyFarmsScreenState extends ConsumerState<MyFarmsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final farmsAsync = ref.watch(farmsProvider);
    final allFarms = farmsAsync.value ?? [];

    final filteredFarms = allFarms.where((farm) {
      return farm.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          farm.location.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          farm.crop.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    if (farmsAsync.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF4F7F4),
        elevation: 0,
        title: Text('My Farms', style: AppTypography.screenHeading.copyWith(fontSize: 20)),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: const Icon(Icons.tune_rounded, size: 18, color: Color(0xFF1E293B)),
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
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: const [BoxShadow(color: Color(0x06000000), blurRadius: 6, offset: Offset(0, 2))],
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      style: const TextStyle(fontSize: 14, color: Color(0xFF1E293B)),
                      decoration: const InputDecoration(
                        hintText: 'Search farms by name or crop...',
                        hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                        prefixIcon: Icon(Icons.search_rounded, size: 20, color: Color(0xFF94A3B8)),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Add New Farm Button
                  GestureDetector(
                    onTap: () => context.go('/farm-location'),
                    child: Container(
                      width: double.infinity,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF86EFAC), width: 1.2),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_rounded, color: Color(0xFF166534), size: 20),
                          SizedBox(width: 6),
                          Text(
                            '+ Add New Farm',
                            style: TextStyle(
                              color: Color(0xFF166534),
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
                    style: const TextStyle(fontSize: 13, color: Color(0xFF64748B), fontWeight: FontWeight.w500),
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
                          onTap: () => context.go('/site-suitability'),
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
    );
  }
}
