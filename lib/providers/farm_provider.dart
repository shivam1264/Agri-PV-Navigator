import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/farm.dart';
import '../models/proposal_report.dart';
import '../services/storage/local_db_service.dart';
import 'draft_farm_notifier.dart';
import 'settings_notifier.dart';

// ── Database ─────────────────────────────────────────────────────────────────

final localDbProvider = Provider<LocalDbService>((ref) {
  return LocalDbService();
});

// ── Farms ─────────────────────────────────────────────────────────────────────

/// Loads all farms from SQLite. Refreshable via ref.invalidate(farmsProvider).
final farmsProvider = FutureProvider<List<Farm>>((ref) async {
  final db = ref.watch(localDbProvider);
  return db.getAllFarms();
});

/// Total farm count from DB
final farmCountProvider = FutureProvider<int>((ref) async {
  final db = ref.watch(localDbProvider);
  return db.getFarmCount();
});

/// Total area across all farms
final totalAreaProvider = FutureProvider<double>((ref) async {
  final db = ref.watch(localDbProvider);
  return db.getTotalAreaAcres();
});

/// Total design count from DB
final designCountProvider = FutureProvider<int>((ref) async {
  final db = ref.watch(localDbProvider);
  return db.getDesignCount();
});

// ── Draft Farm (Wizard State) ─────────────────────────────────────────────────

final draftFarmProvider = StateNotifierProvider<DraftFarmNotifier, DraftFarm>((ref) {
  return DraftFarmNotifier();
});

// ── Reports ──────────────────────────────────────────────────────────────────

final reportsProvider = FutureProvider<List<ProposalReport>>((ref) async {
  final db = ref.watch(localDbProvider);
  return db.getAllReports();
});

// ── Settings ─────────────────────────────────────────────────────────────────

final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('Override in ProviderScope');
});

final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return SettingsNotifier(prefs);
});

// ── Onboarding ────────────────────────────────────────────────────────────────

final onboardingSeenProvider = Provider<bool>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return prefs.getBool('onboarding_seen') ?? false;
});
