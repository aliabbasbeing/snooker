import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/app_settings.dart';
import '../../data/repositories/storage_repository.dart';
import 'game_provider.dart';

/// Provider for app settings
final settingsProvider = StateNotifierProvider<SettingsNotifier, AppSettings>((ref) {
  final repository = ref.watch(storageRepositoryProvider);
  return SettingsNotifier(repository);
});

class SettingsNotifier extends StateNotifier<AppSettings> {
  final StorageRepository _repository;
  
  SettingsNotifier(this._repository) : super(AppSettings()) {
    loadSettings();
  }
  
  /// Load settings from storage
  Future<void> loadSettings() async {
    final settings = _repository.getSettings();
    state = settings;
  }
  
  /// Toggle dark mode
  Future<void> toggleDarkMode() async {
    final newSettings = state.copyWith(isDarkMode: !state.isDarkMode);
    await _repository.saveSettings(newSettings);
    state = newSettings;
  }
  
  /// Update default target score
  Future<void> updateDefaultTargetScore(int score) async {
    final newSettings = state.copyWith(defaultTargetScore: score);
    await _repository.saveSettings(newSettings);
    state = newSettings;
  }
}
