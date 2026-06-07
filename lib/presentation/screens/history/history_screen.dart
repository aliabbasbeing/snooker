import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/history_action.dart';
import '../../../data/models/player.dart';
import '../../providers/history_provider.dart';
import '../../providers/game_provider.dart';
import '../../providers/history_filter_provider.dart';
import '../../providers/settings_provider.dart';

// ---------------------------------------------------------------------------

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  void _confirmClear(BuildContext context) {
    final colors = AppColors.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear History'),
        content:
            const Text('This will permanently delete all history. Continue?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(historyProvider.notifier).clearHistory();
            },
            child: Text('Clear', style: TextStyle(color: colors.danger)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(historyProvider);
    final colors = ref.watch(appColorsProvider);
    final game = ref.watch(gameProvider);
    final selectedPlayerId = ref.watch(historyFilterProvider);

    final scoreEntries = history
        .where((a) =>
            a.actionType == ActionType.score ||
            a.actionType == ActionType.subtract ||
            a.actionType == ActionType.playerCompleted)
        .toList();

    final players = game?.players ?? [];
    final hasHistory = scoreEntries.isNotEmpty;

    // Filter entries for selected player
    final filtered = selectedPlayerId == null
        ? scoreEntries
            .where((a) =>
                a.actionType == ActionType.score ||
                a.actionType == ActionType.subtract)
            .toList()
        : scoreEntries
            .where((a) => a.playerId == selectedPlayerId)
            .toList();

    return Scaffold(
      backgroundColor: colors.bgPage,
      appBar: AppBar(
        backgroundColor: colors.navbar,
        centerTitle: true,
        title: Text(
          'History',
          style:
              TextStyle(fontWeight: FontWeight.bold, color: colors.textPrimary),
        ),
        actions: [
          if (hasHistory)
            IconButton(
              onPressed: () => _confirmClear(context),
              icon: Icon(Icons.delete, color: colors.danger, size: 22),
            ),
        ],
      ),
      body: SafeArea(
        child: !hasHistory
            ? const _EmptyState()
            : Column(
                children: [
                  // Filter bar
                  if (players.isNotEmpty)
                    _FilterBar(
                      players: players,
                      selectedId: selectedPlayerId,
                      onSelect: (id) {
                        ref.read(historyFilterProvider.notifier).state = id;
                      },
                    ),
                  Expanded(
                    child: selectedPlayerId != null
                        ? _PlayerHistoryView(
                            player: players.firstWhere(
                              (p) => p.id == selectedPlayerId,
                              orElse: () => players.first,
                            ),
                            entries: filtered,
                            globalTarget: game?.targetScore ?? 100,
                          )
                        : filtered.isEmpty
                            ? const _EmptyState()
                            : ListView.builder(
                                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                                itemCount: filtered.length,
                                itemBuilder: (context, index) => _HistoryRow(
                                  action: filtered[index],
                                ),
                              ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filter bar
// ---------------------------------------------------------------------------

class _FilterBar extends StatelessWidget {
  final List<Player> players;
  final String? selectedId;
  final void Function(String? id) onSelect;

  const _FilterBar({
    required this.players,
    required this.selectedId,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      height: 52,
      color: colors.navbar,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        children: [
          // "All" chip
          _FilterChip(
            label: 'All',
            isSelected: selectedId == null,
            onTap: () => onSelect(null),
          ),
          const SizedBox(width: 6),
          ...players.map((p) => Padding(
                padding: const EdgeInsets.only(right: 6),
                child: _FilterChip(
                  label: p.name,
                  isSelected: selectedId == p.id,
                  playerColor: AppColors.playerColors[p.colorIndex % 12],
                  onTap: () => onSelect(p.id),
                ),
              )),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final Color? playerColor;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    this.playerColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : colors.bgElevated,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : colors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (playerColor != null) ...[
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: playerColor!.withValues(alpha: 0.25),
                  border: Border.all(color: playerColor!, width: 1.5),
                ),
                child: Center(
                  child: Text(
                    label[0].toUpperCase(),
                    style: TextStyle(
                      color: playerColor,
                      fontSize: 8,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : colors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Per-player view
// ---------------------------------------------------------------------------

class _PlayerHistoryView extends StatelessWidget {
  final Player player;
  final List<HistoryAction> entries;
  final int globalTarget;

  const _PlayerHistoryView({
    required this.player,
    required this.entries,
    required this.globalTarget,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final color = AppColors.playerColors[player.colorIndex % 12];
    final effective = player.effectiveTarget(globalTarget);
    final progress = (player.score / effective).clamp(0.0, 1.0);

    String statusLabel;
    Color statusColor;
    if (player.isCompleted) {
      statusLabel = 'Completed ✓';
      statusColor = AppColors.warning;
    } else {
      statusLabel = 'In Progress';
      statusColor = AppColors.primary;
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      children: [
        // Header card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: colors.bgCard,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withValues(alpha: 0.4), width: 1.5),
            boxShadow: colors.cardShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _PlayerAvatarWidget(player: player, size: 44),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          player.name,
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: colors.textPrimary,
                          ),
                        ),
                        Text(
                          'Score: ${player.score} / $effective',
                          style: TextStyle(
                            fontSize: 13,
                            color: colors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor.withValues(alpha: 0.4)),
                    ),
                    child: Text(
                      statusLabel,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: colors.bgElevated,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (entries.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 32),
              child: Text(
                'No history for this player',
                style: TextStyle(color: colors.textMuted, fontStyle: FontStyle.italic),
              ),
            ),
          )
        else
          ...entries.map((a) {
            if (a.actionType == ActionType.playerCompleted) {
              return _CompletionRow(action: a);
            }
            return _HistoryRow(action: a, showRunningTotal: true);
          }),
      ],
    );
  }
}

class _CompletionRow extends StatelessWidget {
  final HistoryAction action;
  const _CompletionRow({required this.action});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: AppColors.warning, width: 4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.emoji_events, color: AppColors.warning, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              action.details ?? 'Target reached!',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.access_time,
              size: 64, color: colors.textSecondary.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          Text(
            'No History Yet',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colors.textSecondary),
          ),
          const SizedBox(height: 6),
          Text(
            'Score actions will appear here',
            style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Player avatar widget (reusable)
// ---------------------------------------------------------------------------

class _PlayerAvatarWidget extends StatelessWidget {
  final Player player;
  final double size;
  const _PlayerAvatarWidget({required this.player, this.size = 36});

  @override
  Widget build(BuildContext context) {
    final color = AppColors.playerColors[player.colorIndex % 12];
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.2),
        border: Border.all(color: color, width: 2),
      ),
      child: Center(
        child: Text(
          player.name[0].toUpperCase(),
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: size * 0.4,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// History row
// ---------------------------------------------------------------------------

class _HistoryRow extends StatelessWidget {
  final HistoryAction action;
  final bool showRunningTotal;

  const _HistoryRow({required this.action, this.showRunningTotal = false});

  static Color _borderColor(String? ballName, bool isSubtract, AppColors colors) {
    if (isSubtract) return colors.danger;
    switch ((ballName ?? '').toLowerCase()) {
      case 'yellow':
        return AppColors.ballYellow;
      case 'green':
        return AppColors.ballGreen;
      case 'brown':
        return AppColors.ballBrown;
      case 'blue':
        return AppColors.ballBlue;
      case 'pink':
        return AppColors.ballPink;
      case 'black':
        return AppColors.ballBlack;
      case 'red':
        return AppColors.ballRed;
      default:
        return colors.success;
    }
  }

  static String _ballEmoji(String? ballName) {
    switch ((ballName ?? '').toLowerCase()) {
      case 'yellow': return '🟡';
      case 'green':  return '🟢';
      case 'brown':  return '🟤';
      case 'blue':   return '🔵';
      case 'pink':   return '🌸';
      case 'black':  return '⚫';
      case 'red':    return '🔴';
      default:       return '🎱';
    }
  }

  String _formatTime(DateTime ts) {
    final h = ts.hour.toString().padLeft(2, '0');
    final m = ts.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isSubtract = action.actionType == ActionType.subtract;
    final points = action.pointsChanged ?? 0;
    final badgeColor = isSubtract ? colors.danger : colors.success;
    final border = _borderColor(action.ballColor, isSubtract, colors);
    final emoji = _ballEmoji(action.ballColor);
    final badge = isSubtract ? '−$points' : '+$points';
    final playerName = action.playerName ?? 'Unknown';
    final ballLabel = action.ballColor != null
        ? action.ballColor![0].toUpperCase() + action.ballColor!.substring(1).toLowerCase()
        : '';
    final balanceText = action.previousBalance != null && action.updatedBalance != null
      ? '${action.previousBalance} → ${action.updatedBalance} pts'
      : action.details;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: border, width: 4)),
        boxShadow: colors.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    playerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Text(
                        ballLabel.isEmpty
                            ? _formatTime(action.timestamp)
                            : '$ballLabel  •  ${_formatTime(action.timestamp)}',
                        style: TextStyle(fontSize: 12, color: colors.textSecondary),
                      ),
                    ],
                  ),
                  if (balanceText != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      balanceText,
                      style: TextStyle(fontSize: 11, color: colors.textMuted),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              constraints: const BoxConstraints(minWidth: 54),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: badgeColor.withValues(alpha: 0.40), width: 1),
              ),
              alignment: Alignment.center,
              child: Text(
                badge,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: badgeColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
