import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../data/models/snooker_ball.dart';
import '../../providers/game_provider.dart';
import '../../widgets/snooker_ball_button.dart';
import '../../widgets/player_card.dart';
import '../../widgets/add_player_dialog.dart';
import '../../widgets/game_analytics_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final game = ref.watch(gameProvider);

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('Snooker Score'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _showNewGameDialog(context, ref),
          child: const Icon(CupertinoIcons.add_circled),
        ),
      ),
      child: game == null
          ? _buildEmptyState(context, ref)
          : _buildGameView(context, ref, game),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.circle_grid_3x3,
            size: 80,
            color: CupertinoColors.systemGrey,
          ),
          const SizedBox(height: 16),
          const Text(
            'No Active Game',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Start a new game to begin',
            style: TextStyle(
              color: CupertinoColors.systemGrey,
            ),
          ),
          const SizedBox(height: 24),
          CupertinoButton.filled(
            onPressed: () => _showNewGameDialog(context, ref),
            child: const Text('Start New Game'),
          ),
        ],
      ),
    );
  }

  Widget _buildGameView(BuildContext context, WidgetRef ref, game) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildGameHeader(context, ref, game),
              const SizedBox(height: 20),
              _buildPlayersSection(context, ref, game),
              const SizedBox(height: 20),
              _buildCurrentPlayerInfo(game),
              const SizedBox(height: 20),
              _buildControlsSection(ref, game),
              const SizedBox(height: 20),
              _buildScoringBalls(ref, game),
              const SizedBox(height: 20),
              if (game.players.isNotEmpty) 
                GameAnalyticsWidget(game: game),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameHeader(BuildContext context, WidgetRef ref, game) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGroupedBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Target Score',
                style: TextStyle(
                  fontSize: 14,
                  color: CupertinoColors.systemGrey,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${game.targetScore}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            onPressed: () => _showTargetScoreDialog(context, ref, game),
            child: const Icon(CupertinoIcons.settings),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayersSection(BuildContext context, WidgetRef ref, game) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Players',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (game.players.length < AppConstants.maxPlayers)
              CupertinoButton(
                padding: EdgeInsets.zero,
                onPressed: () => _showAddPlayerDialog(context, ref),
                child: const Icon(CupertinoIcons.add_circled_solid),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (game.players.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text(
                'No players yet. Add players to start!',
                style: TextStyle(color: CupertinoColors.systemGrey),
              ),
            ),
          )
        else
          ...game.players.map((player) => PlayerCard(
                player: player,
                isActive: player.id == game.currentPlayerId,
                targetScore: game.targetScore,
                onTap: () {
                  if (!player.isCompleted) {
                    ref.read(gameProvider.notifier).setCurrentPlayer(player.id);
                  }
                },
                onRemove: () {
                  _showRemovePlayerDialog(context, ref, player.id, player.name);
                },
              )),
      ],
    );
  }

  Widget _buildCurrentPlayerInfo(game) {
    final currentPlayer = game.currentPlayer;
    
    if (currentPlayer == null) {
      return const SizedBox.shrink();
    }

    final remaining = game.targetScore - currentPlayer.score;
    final showWarning = remaining > 0 && 
        remaining <= (game.targetScore * AppConstants.warningThreshold);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [CupertinoColors.systemBlue, CupertinoColors.activeBlue],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'Current Player',
            style: TextStyle(
              color: CupertinoColors.white,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            currentPlayer.name,
            style: const TextStyle(
              color: CupertinoColors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Score: ${currentPlayer.score}',
            style: const TextStyle(
              color: CupertinoColors.white,
              fontSize: 20,
            ),
          ),
          if (showWarning) ...[
            const SizedBox(height: 8),
            Text(
              '⚠️ $remaining points to target',
              style: const TextStyle(
                color: CupertinoColors.systemYellow,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildControlsSection(WidgetRef ref, game) {
    return Row(
      children: [
        Expanded(
          child: CupertinoButton(
            color: game.isSubtractMode
                ? CupertinoColors.destructiveRed
                : CupertinoColors.systemGrey5,
            onPressed: () {
              ref.read(gameProvider.notifier).toggleSubtractMode();
            },
            child: Text(
              game.isSubtractMode ? 'Subtract Mode ON' : 'Subtract Mode OFF',
              style: TextStyle(
                color: game.isSubtractMode
                    ? CupertinoColors.white
                    : CupertinoColors.black,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: CupertinoButton(
            color: CupertinoColors.systemBlue,
            onPressed: () {
              ref.read(gameProvider.notifier).nextPlayer();
            },
            child: const Text('Next Player'),
          ),
        ),
      ],
    );
  }

  Widget _buildScoringBalls(WidgetRef ref, game) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Score',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: SnookerBall.values.map((ball) {
            return SnookerBallButton(
              ball: ball,
              onTap: () {
                if (game.currentPlayer != null) {
                  ref.read(gameProvider.notifier).scorePoints(ball);
                }
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  void _showNewGameDialog(BuildContext context, WidgetRef ref) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Start New Game'),
        content: const Text('This will end the current game. Continue?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              ref.read(gameProvider.notifier).createNewGame();
            },
            child: const Text('Start New Game'),
          ),
        ],
      ),
    );
  }

  void _showAddPlayerDialog(BuildContext context, WidgetRef ref) {
    showCupertinoDialog(
      context: context,
      builder: (context) => AddPlayerDialog(
        onAdd: (name) {
          ref.read(gameProvider.notifier).addPlayer(name);
        },
      ),
    );
  }

  void _showRemovePlayerDialog(
    BuildContext context,
    WidgetRef ref,
    String playerId,
    String playerName,
  ) {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        title: const Text('Remove Player'),
        content: Text('Remove $playerName from the game?'),
        actions: [
          CupertinoDialogAction(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              ref.read(gameProvider.notifier).removePlayer(playerId);
            },
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _showTargetScoreDialog(BuildContext context, WidgetRef ref, game) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Select Target Score'),
        actions: AppConstants.targetScores.map((score) {
          return CupertinoActionSheetAction(
            isDefaultAction: score == game.targetScore,
            onPressed: () {
              Navigator.pop(context);
              ref.read(gameProvider.notifier).changeTargetScore(score);
            },
            child: Text('$score'),
          );
        }).toList(),
        cancelButton: CupertinoActionSheetAction(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }
}
