import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/saved_player.dart';

final savedPlayersProvider =
    StateNotifierProvider<SavedPlayersNotifier, List<SavedPlayer>>((ref) {
  return SavedPlayersNotifier();
});

class SavedPlayersNotifier extends StateNotifier<List<SavedPlayer>> {
  final _uuid = const Uuid();

  SavedPlayersNotifier() : super([]) {
    _load();
  }

  void _load() {
    final box = Hive.box<SavedPlayer>('savedPlayers');
    final players = box.values.toList()
      ..sort((a, b) => b.lastUsed.compareTo(a.lastUsed));
    state = players;
  }

  Future<void> savePlayer(String name, int colorIndex) async {
    final box = Hive.box<SavedPlayer>('savedPlayers');
    final existing = box.values
        .where((p) => p.name.toLowerCase() == name.toLowerCase())
        .firstOrNull;
    if (existing != null) {
      existing.usageCount++;
      existing.lastUsed = DateTime.now();
      existing.colorIndex = colorIndex;
      await existing.save();
    } else {
      final player = SavedPlayer(
        id: _uuid.v4(),
        name: name,
        colorIndex: colorIndex,
        usageCount: 1,
        lastUsed: DateTime.now(),
      );
      await box.put(player.id, player);
    }
    _load();
  }

  Future<void> deletePlayer(String id) async {
    await Hive.box<SavedPlayer>('savedPlayers').delete(id);
    _load();
  }

  Future<void> clearAll() async {
    await Hive.box<SavedPlayer>('savedPlayers').clear();
    state = [];
  }
}
