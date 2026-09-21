import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/farm.dart';
import '../../../shared/widgets/farm_card.dart';
import '../../../shared/widgets/bottom_nav_bar.dart';
import 'package:provider/provider.dart';
import '../../../providers/farm_provider.dart';
import '../../../providers/report_provider.dart';

enum FarmSort { newest, areaDesc, areaAsc, scoreDesc, nameAsc }

typedef FarmFilterConfig = ({
  String? crop,
  String? soil,
  String? state,
  String? suitability,
  FarmSort sort,
});

String _sortLabel(FarmSort s) => switch (s) {
      FarmSort.newest => 'Newest',
      FarmSort.areaDesc => 'Area ↓',
      FarmSort.areaAsc => 'Area ↑',
      FarmSort.scoreDesc => 'Score',
      FarmSort.nameAsc => 'Name',
    };

/// Pure search + filter + sort over the farm list (tested in
/// test/my_farms_filter_test.dart). "newest" keeps provider order, which is
/// already newest-first.
List<Farm> filterAndSortFarms(
  List<Farm> farms, {
  String query = '',
  String? crop,
  String? soil,
  String? state,
  String? suitability,
  FarmSort sort = FarmSort.newest,
}) {
  final q = query.trim().toLowerCase();
  final result = farms.where((f) {
    if (q.isNotEmpty) {
      final matches = f.name.toLowerCase().contains(q) ||
          f.location.toLowerCase().contains(q) ||
          f.crop.toLowerCase().contains(q);
      if (!matches) return false;
    }
    if (crop != null && f.crop != crop) return false;
    if (soil != null && f.soilType != soil) return false;
    if (state != null && f.state != state) return false;
    if (suitability != null && f.suitabilityLabel != suitability) return false;
    return true;
  }).toList();

  switch (sort) {
    case FarmSort.areaDesc:
      result.sort((a, b) => b.areaAcres.compareTo(a.areaAcres));
    case FarmSort.areaAsc:
      result.sort((a, b) => a.areaAcres.compareTo(b.areaAcres));
    case FarmSort.scoreDesc:
      result.sort((a, b) => b.suitabilityScore.compareTo(a.suitabilityScore));
    case FarmSort.nameAsc:
      result.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    case FarmSort.newest:
      break;
  }
  return result;
}

class MyFarmsScreen extends StatefulWidget {
  const MyFarmsScreen({super.key});

  @override
  State<MyFarmsScreen> createState() => _MyFarmsScreenState();
}

class _MyFarmsScreenState extends State<MyFarmsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  String? _filterCrop;
  String? _filterSoil;
  String? _filterState;
  String? _filterSuitability;
  FarmSort _sort = FarmSort.newest;

  int get _activeFilterCount =>
      [_filterCrop, _filterSoil, _filterState, _filterSuitability]
          .where((f) => f != null)
          .length;

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

  String _emptyMessage() {
    if (_searchQuery.isNotEmpty) return 'No farms match "$_searchQuery"';
    if (_activeFilterCount > 0) return 'No farms match your filters.';
    return 'No farms yet.\nTap "+ Add New Farm" to begin.';
  }

  Future<void> _openFilterSheet() async {
    final theme = Theme.of(context);
    final allFarms = context.read<FarmProvider>().farms;
    final crops = allFarms.map((f) => f.crop).toSet().toList()..sort();
    final soils = allFarms.map((f) => f.soilType).toSet().toList()..sort();
    final states = allFarms.map((f) => f.state).toSet().toList()..sort();
    const suitabilities = ['Suitable', 'Moderately Suitable', 'Marginal'];

    final result = await showModalBottomSheet<FarmFilterConfig>(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      builder: (ctx) {
        var draftCrop = _filterCrop;
        var draftSoil = _filterSoil;
        var draftState = _filterState;
        var draftSuit = _filterSuitability;
        var draftSort = _sort;

        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            void clear() => setSheetState(() {
                  draftCrop = draftSoil = draftState = draftSuit = null;
                  draftSort = FarmSort.newest;
                });

            return Padding(
              padding: EdgeInsets.fromLTRB(
                20,
                16,
                20,
                MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Filter Farms', style: AppTypography.screenHeading.copyWith(fontSize: 16)),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  Flexible(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _chipGroup(
                            'Sort by',
                            FarmSort.values.map(_sortLabel).toList(),
                            _sortLabel(draftSort),
                            (v) => setSheetState(
                              () => draftSort = FarmSort.values.firstWhere((s) => _sortLabel(s) == v),
                            ),
                          ),
                          _chipGroup('Crop', crops, draftCrop, (v) => setSheetState(() => draftCrop = v)),
                          _chipGroup('Soil type', soils, draftSoil, (v) => setSheetState(() => draftSoil = v)),
                          _chipGroup('State', states, draftState, (v) => setSheetState(() => draftState = v)),
                          _chipGroup('Suitability', suitabilities, draftSuit, (v) => setSheetState(() => draftSuit = v)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: clear,
                          child: const Text('Clear all'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.of(ctx).pop((
                            crop: draftCrop,
                            soil: draftSoil,
                            state: draftState,
                            suitability: draftSuit,
                            sort: draftSort,
                          )),
                          child: const Text('Apply'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (result == null || !mounted) return;
    setState(() {
      _filterCrop = result.crop;
      _filterSoil = result.soil;
      _filterState = result.state;
      _filterSuitability = result.suitability;
      _sort = result.sort;
    });
  }

  Widget _chipGroup(
    String title,
    List<String> options,
    String? selected,
    ValueChanged<String> onSelected,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.labelSmall.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: isDark ? const Color(0xFF94A3B8) : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              for (final o in options)
                ChoiceChip(
                  label: Text(o),
                  selected: selected == o,
                  onSelected: (_) => onSelected(o),
                  showCheckmark: false,
                  visualDensity: VisualDensity.compact,
                  labelStyle: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: selected == o
                        ? (isDark ? const Color(0xFF00E676) : AppColors.primaryDark)
                        : (isDark ? Colors.white70 : const Color(0xFF475569)),
                  ),
                  selectedColor: isDark ? const Color(0xFF123520) : AppColors.primarySurface,
                  backgroundColor: isDark ? theme.cardColor : Colors.white,
                  side: BorderSide(
                    color: selected == o
                        ? (isDark ? const Color(0xFF1B5E30) : AppColors.primaryLight)
                        : (isDark ? theme.dividerColor : const Color(0xFFE2E8F0)),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
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

    final filteredFarms = filterAndSortFarms(
      farmProv.farms,
      query: _searchQuery,
      crop: _filterCrop,
      soil: _filterSoil,
      state: _filterState,
      suitability: _filterSuitability,
      sort: _sort,
    );

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
              child: SizedBox(
                width: 18,
                height: 18,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    const Positioned.fill(
                      child: Icon(
                        Icons.tune_rounded,
                        size: 18,
                      ),
                    ),
                    if (_activeFilterCount > 0)
                      Positioned(
                        right: -7,
                        top: -7,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            color: Color(0xFF16A34A),
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$_activeFilterCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 8,
                              fontWeight: FontWeight.w800,
                              height: 1,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            onPressed: _openFilterSheet,
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
                            _emptyMessage(),
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
