import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/saved_player.dart';
import '../../data/repositories/storage_repository.dart';
import 'settings_provider.dart';

final savedPlayersProvider =
    StateNotifierProvider<SavedPlayersNotifier, List<SavedPlayer>>((ref) {
  final repository = ref.watch(storageRepositoryProvider);
  return SavedPlayersNotifier(repository);
});

class SavedPlayersNotifier extends StateNotifier<List<SavedPlayer>> {
  final StorageRepository _repository;
  final _uuid = const Uuid();

  SavedPlayersNotifier(this._repository) : super([]) {
    _load();
  }

  void _load() {
    try {
      state = _repository.getAllSavedPlayers();
    } catch (e) {
      state = [];
    }
  }

  Future<void> savePlayer(String name, int colorIndex) async {
    try {
      final existing = _repository.findSavedPlayerByName(name);
      if (existing != null) {
        existing.usageCount++;
        existing.lastUsed = DateTime.now();
        existing.colorIndex = colorIndex;
        await _repository.updateSavedPlayer(existing);
      } else {
        final player = SavedPlayer(
          id: _uuid.v4(),
          name: name,
          colorIndex: colorIndex,
          usageCount: 1,
          lastUsed: DateTime.now(),
        );
        await _repository.saveSavedPlayer(player);
      }
      _load();
    } catch (e) {
      // Silently fail — saved players are non-critical
    }
  }

  Future<void> deletePlayer(String id) async {
    try {
      await _repository.deleteSavedPlayer(id);
      _load();
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> clearAll() async {
    try {
      await _repository.clearAllSavedPlayers();
      state = [];
    } catch (e) {
      // Silently fail
    }
  }
}
