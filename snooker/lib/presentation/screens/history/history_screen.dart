import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/history_action.dart';
import '../../providers/history_provider.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  ActionType? _selectedFilter;

  @override
  void initState() {
    super.initState();
    // Load history when screen is shown
    Future.microtask(() {
      ref.read(historyProvider.notifier).loadHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final history = _selectedFilter == null
        ? ref.watch(historyProvider)
        : ref.watch(filteredHistoryProvider(_selectedFilter));

    return CupertinoPageScaffold(
      navigationBar: CupertinoNavigationBar(
        middle: const Text('History'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => _showFilterOptions(context),
          child: const Icon(CupertinoIcons.line_horizontal_3_decrease),
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            if (_selectedFilter != null) _buildFilterChip(),
            Expanded(
              child: history.isEmpty
                  ? _buildEmptyState()
                  : _buildHistoryList(history),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: CupertinoColors.systemBlue,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _getFilterName(_selectedFilter!),
                  style: const TextStyle(
                    color: CupertinoColors.white,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedFilter = null;
                    });
                  },
                  child: const Icon(
                    CupertinoIcons.clear_circled_solid,
                    color: CupertinoColors.white,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            CupertinoIcons.clock,
            size: 80,
            color: CupertinoColors.systemGrey.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'No History Yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: CupertinoColors.systemGrey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Game actions will appear here',
            style: TextStyle(
              color: CupertinoColors.systemGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(List<HistoryAction> history) {
    return ListView.builder(
      itemCount: history.length,
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        final action = history[index];
        return _buildHistoryItem(action);
      },
    );
  }

  Widget _buildHistoryItem(HistoryAction action) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGrey6,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildActionIcon(action.actionType),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  action.actionDescription,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormatter.formatRelative(action.timestamp),
                  style: const TextStyle(
                    fontSize: 14,
                    color: CupertinoColors.systemGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon(ActionType type) {
    IconData icon;
    Color color;

    switch (type) {
      case ActionType.score:
        icon = CupertinoIcons.arrow_up_circle_fill;
        color = CupertinoColors.systemGreen;
        break;
      case ActionType.subtract:
        icon = CupertinoIcons.arrow_down_circle_fill;
        color = CupertinoColors.destructiveRed;
        break;
      case ActionType.playerAdded:
        icon = CupertinoIcons.person_add_solid;
        color = CupertinoColors.systemBlue;
        break;
      case ActionType.playerRemoved:
        icon = CupertinoIcons.person_badge_minus;
        color = CupertinoColors.systemOrange;
        break;
      case ActionType.playerCompleted:
        icon = CupertinoIcons.checkmark_seal_fill;
        color = CupertinoColors.systemPurple;
        break;
      case ActionType.gameReset:
        icon = CupertinoIcons.restart;
        color = CupertinoColors.systemIndigo;
        break;
      case ActionType.turnChanged:
        icon = CupertinoIcons.arrow_right_arrow_left_circle_fill;
        color = CupertinoColors.systemTeal;
        break;
    }

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: color,
        size: 24,
      ),
    );
  }

  void _showFilterOptions(BuildContext context) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Filter History'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _selectedFilter = null;
              });
            },
            child: const Text('Show All'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _selectedFilter = ActionType.score;
              });
            },
            child: const Text('Scoring Actions Only'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _selectedFilter = ActionType.playerAdded;
              });
            },
            child: const Text('Player Actions Only'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _selectedFilter = ActionType.playerCompleted;
              });
            },
            child: const Text('Completions Only'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text('Cancel'),
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  String _getFilterName(ActionType type) {
    switch (type) {
      case ActionType.score:
        return 'Scoring Actions';
      case ActionType.subtract:
        return 'Subtractions';
      case ActionType.playerAdded:
        return 'Player Actions';
      case ActionType.playerRemoved:
        return 'Player Removals';
      case ActionType.playerCompleted:
        return 'Completions';
      case ActionType.gameReset:
        return 'Game Resets';
      case ActionType.turnChanged:
        return 'Turn Changes';
    }
  }
}
