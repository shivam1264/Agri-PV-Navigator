import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/farm_card.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import '../../../services/storage/mock_data_service.dart';

class MyFarmsScreen extends StatefulWidget {
  const MyFarmsScreen({super.key});

  @override
  State<MyFarmsScreen> createState() => _MyFarmsScreenState();
}

class _MyFarmsScreenState extends State<MyFarmsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mockService = MockDataService();
    final allFarms = mockService.farms;

    final filteredFarms = allFarms.where((farm) {
      return farm.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          farm.location.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          farm.crop.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'My Farms',
          style: AppTypography.screenHeading.copyWith(fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_rounded),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Bar & Filter Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Column(
                children: [
                  // Search Input
                  Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      style: AppTypography.bodyMedium.copyWith(color: AppColors.textPrimary),
                      decoration: const InputDecoration(
                        hintText: 'Search your farms...',
                        prefixIcon: Icon(Icons.search_rounded, size: 20, color: AppColors.textTertiary),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  const SizedBox(height: 10),
                  // "+ Add New Farm" Button matching Screen 05
                  GestureDetector(
                    onTap: () => context.go('/farm-location'),
                    child: Container(
                      width: double.infinity,
                      height: 42,
                      decoration: BoxDecoration(
                        color: const Color(0xFFDCFCE7),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF86EFAC), width: 1.2),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.add_rounded, color: Color(0xFF166534), size: 18),
                          SizedBox(width: 6),
                          Text(
                            '+ Add New Farm',
                            style: TextStyle(
                              color: Color(0xFF166534),
                              fontSize: 13,
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

            // Farm Cards List
            Expanded(
              child: filteredFarms.isEmpty
                  ? Center(
                      child: Text(
                        'No farms found',
                        style: AppTypography.bodyMedium,
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
                      itemCount: filteredFarms.length,
                      itemBuilder: (context, index) {
                        final farm = filteredFarms[index];
                        return FarmCard(
                          farm: farm,
                          onTap: () => context.go('/farm-detail'),
                        );
                      },
                    ),
            ),

            // Bottom Navigation Bar
            BottomNavBar(
              currentIndex: 1,
              onTap: (index) {
                if (index == 0) context.go('/home');
                if (index == 2) context.go('/agri-pv-design');
                if (index == 3) context.go('/reports');
                if (index == 4) context.go('/profile');
              },
            ),
          ],
        ),
      ),
    );
  }
}
