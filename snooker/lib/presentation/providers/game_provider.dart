import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/models/game.dart';
import '../../data/models/player.dart';
import '../../data/models/history_action.dart';
import '../../data/models/snooker_ball.dart';
import '../../data/repositories/storage_repository.dart';
import '../../core/constants/app_constants.dart';

/// Provider for storage repository
final storageRepositoryProvider = Provider<StorageRepository>((ref) {
  return StorageRepository();
});

/// Provider for current game state
final gameProvider = StateNotifierProvider<GameNotifier, Game?>((ref) {
  final repository = ref.watch(storageRepositoryProvider);
  return GameNotifier(repository);
});

class GameNotifier extends StateNotifier<Game?> {
  final StorageRepository _repository;
  final _uuid = const Uuid();
  
  GameNotifier(this._repository) : super(null) {
    loadActiveGame();
  }
  
  /// Load the active game from storage
  Future<void> loadActiveGame() async {
    final game = await _repository.getActiveGame();
    if (game != null) {
      state = game;
    }
  }
  
  /// Create a new game
  Future<void> createNewGame({int? targetScore}) async {
    // Mark current game as inactive
    if (state != null) {
      final oldGame = state!.copyWith(isActive: false);
      await _repository.saveGame(oldGame);
    }
    
    final newGame = Game(
      id: _uuid.v4(),
      players: [],
      targetScore: targetScore ?? AppConstants.defaultTargetScore,
    );
    
    await _repository.saveGame(newGame);
    await _addHistoryAction(
      gameId: newGame.id,
      actionType: ActionType.gameReset,
      details: 'New game started with target ${newGame.targetScore}',
    );
    
    state = newGame;
  }
  
  /// Add a player to the game
  Future<void> addPlayer(String playerName) async {
    if (state == null) {
      await createNewGame();
    }
    
    final currentGame = state!;
    
    if (currentGame.players.length >= AppConstants.maxPlayers) {
      throw Exception('Maximum ${AppConstants.maxPlayers} players allowed');
    }
    
    final newPlayer = Player(
      id: _uuid.v4(),
      name: playerName.trim(),
    );
    
    final updatedPlayers = [...currentGame.players, newPlayer];
    final updatedGame = currentGame.copyWith(
      players: updatedPlayers,
      currentPlayerId: currentGame.currentPlayerId ?? newPlayer.id,
    );
    
    await _repository.saveGame(updatedGame);
    await _addHistoryAction(
      gameId: currentGame.id,
      actionType: ActionType.playerAdded,
      playerId: newPlayer.id,
      playerName: newPlayer.name,
    );
    
    state = updatedGame;
  }
  
  /// Remove a player from the game
  Future<void> removePlayer(String playerId) async {
    if (state == null) return;
    
    final currentGame = state!;
    final player = currentGame.players.firstWhere((p) => p.id == playerId);
    final updatedPlayers = currentGame.players.where((p) => p.id != playerId).toList();
    
    // Update current player if removed
    String? newCurrentPlayerId = currentGame.currentPlayerId;
    if (currentGame.currentPlayerId == playerId) {
      final activePlayers = updatedPlayers.where((p) => !p.isCompleted).toList();
      newCurrentPlayerId = activePlayers.isNotEmpty ? activePlayers.first.id : null;
    }
    
    final updatedGame = currentGame.copyWith(
      players: updatedPlayers,
      currentPlayerId: newCurrentPlayerId,
    );
    
    await _repository.saveGame(updatedGame);
    await _addHistoryAction(
      gameId: currentGame.id,
      actionType: ActionType.playerRemoved,
      playerId: playerId,
      playerName: player.name,
    );
    
    state = updatedGame;
  }
  
  /// Set the current active player
  Future<void> setCurrentPlayer(String playerId) async {
    if (state == null) return;
    
    final currentGame = state!;
    final player = currentGame.players.firstWhere((p) => p.id == playerId);
    
    if (player.isCompleted) return;
    
    final updatedGame = currentGame.copyWith(currentPlayerId: playerId);
    
    await _repository.saveGame(updatedGame);
    await _addHistoryAction(
      gameId: currentGame.id,
      actionType: ActionType.turnChanged,
      playerId: playerId,
      playerName: player.name,
    );
    
    state = updatedGame;
  }
  
  /// Move to the next active player
  Future<void> nextPlayer() async {
    if (state == null) return;
    
    final currentGame = state!;
    final activePlayers = currentGame.activePlayers;
    
    if (activePlayers.isEmpty) return;
    
    final currentIndex = activePlayers.indexWhere(
      (p) => p.id == currentGame.currentPlayerId,
    );
    
    final nextIndex = (currentIndex + 1) % activePlayers.length;
    final nextPlayer = activePlayers[nextIndex];
    
    await setCurrentPlayer(nextPlayer.id);
  }
  
  /// Add points to current player
  Future<void> scorePoints(SnookerBall ball) async {
    if (state == null || state!.currentPlayerId == null) return;
    
    final currentGame = state!;
    final currentPlayer = currentGame.currentPlayer!;
    
    if (currentPlayer.isCompleted) {
      await nextPlayer();
      return;
    }
    
    final pointsToAdd = currentGame.isSubtractMode ? -ball.points : ball.points;
    final newScore = (currentPlayer.score + pointsToAdd).clamp(0, double.infinity).toInt();
    final isCompleted = newScore >= currentGame.targetScore;
    
    // Update player
    final updatedPlayer = currentPlayer.copyWith(
      score: newScore,
      isCompleted: isCompleted,
      turnCount: currentPlayer.turnCount + 1,
    );
    
    final updatedPlayers = currentGame.players.map((p) {
      return p.id == currentPlayer.id ? updatedPlayer : p;
    }).toList();
    
    final updatedGame = currentGame.copyWith(players: updatedPlayers);
    
    await _repository.saveGame(updatedGame);
    
    // Add history
    await _addHistoryAction(
      gameId: currentGame.id,
      actionType: currentGame.isSubtractMode ? ActionType.subtract : ActionType.score,
      playerId: currentPlayer.id,
      playerName: currentPlayer.name,
      pointsChanged: ball.points,
      ballColor: ball.displayName,
    );
    
    if (isCompleted) {
      await _addHistoryAction(
        gameId: currentGame.id,
        actionType: ActionType.playerCompleted,
        playerId: currentPlayer.id,
        playerName: currentPlayer.name,
        details: 'Reached target of ${currentGame.targetScore}',
      );
    }
    
    state = updatedGame;
    
    // Auto-switch to next player if completed
    if (isCompleted) {
      await nextPlayer();
    }
  }
  
  /// Toggle subtract mode
  Future<void> toggleSubtractMode() async {
    if (state == null) return;
    
    final currentGame = state!;
    final updatedGame = currentGame.copyWith(
      isSubtractMode: !currentGame.isSubtractMode,
    );
    
    await _repository.saveGame(updatedGame);
    state = updatedGame;
  }
  
  /// Change target score
  Future<void> changeTargetScore(int newTarget) async {
    if (state == null) return;
    
    final currentGame = state!;
    final updatedGame = currentGame.copyWith(targetScore: newTarget);
    
    await _repository.saveGame(updatedGame);
    state = updatedGame;
  }
  
  /// Add a history action
  Future<void> _addHistoryAction({
    required String gameId,
    required ActionType actionType,
    String? playerId,
    String? playerName,
    int? pointsChanged,
    String? ballColor,
    String? details,
  }) async {
    final action = HistoryAction(
      id: _uuid.v4(),
      gameId: gameId,
      actionType: actionType,
      playerId: playerId,
      playerName: playerName,
      pointsChanged: pointsChanged,
      ballColor: ballColor,
      details: details,
    );
    
    await _repository.addHistoryAction(action);
  }
}
