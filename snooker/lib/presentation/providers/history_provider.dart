import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/history_action.dart';
import '../../data/repositories/storage_repository.dart';
import 'game_provider.dart';

/// Provider for history actions
final historyProvider = StateNotifierProvider<HistoryNotifier, List<HistoryAction>>((ref) {
  final repository = ref.watch(storageRepositoryProvider);
  return HistoryNotifier(repository);
});

class HistoryNotifier extends StateNotifier<List<HistoryAction>> {
  final StorageRepository _repository;
  
  HistoryNotifier(this._repository) : super([]) {
    loadHistory();
  }
  
  /// Load all history
  Future<void> loadHistory() async {
    final history = _repository.getAllHistory();
    state = history;
  }
  
  /// Load history for a specific game
  Future<void> loadGameHistory(String gameId) async {
    final history = _repository.getGameHistory(gameId);
    state = history;
  }
  
  /// Filter history
  Future<void> filterHistory({
    String? gameId,
    ActionType? actionType,
    DateTime? fromDate,
    DateTime? toDate,
  }) async {
    final history = _repository.getFilteredHistory(
      gameId: gameId,
      actionType: actionType,
      fromDate: fromDate,
      toDate: toDate,
    );
    state = history;
  }
  
  /// Clear all history
  Future<void> clearHistory() async {
    await _repository.clearHistory();
    state = [];
  }
}

/// Provider for filtered history by action type
final filteredHistoryProvider = Provider.family<List<HistoryAction>, ActionType?>((ref, actionType) {
  final history = ref.watch(historyProvider);
  if (actionType == null) return history;
  return history.where((h) => h.actionType == actionType).toList();
});
