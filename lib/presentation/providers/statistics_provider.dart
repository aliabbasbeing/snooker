import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/player_statistics.dart';
import '../../data/repositories/storage_repository.dart';
import 'settings_provider.dart';

final playerStatisticsProvider =
    StateNotifierProvider<PlayerStatisticsNotifier, List<PlayerStatistics>>((ref) {
  final repository = ref.watch(storageRepositoryProvider);
  return PlayerStatisticsNotifier(repository);
});

class PlayerStatisticsNotifier extends StateNotifier<List<PlayerStatistics>> {
  final StorageRepository _repository;

  PlayerStatisticsNotifier(this._repository) : super([]) {
    reload();
  }

  void reload() {
    state = _repository.getAllPlayerStatistics();
  }

  Future<void> recordMatchResult({
    required List<String> playerNames,
    required String loserName,
  }) async {
    await _repository.recordMatchResult(
      playerNames: playerNames,
      loserName: loserName,
    );
    reload();
  }
}
