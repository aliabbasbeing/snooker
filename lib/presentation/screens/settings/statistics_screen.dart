import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/statistics_provider.dart';

class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(playerStatisticsProvider);
    final colors = AppColors.of(context);

    final sorted = [...stats]
      ..sort((a, b) {
        final wins = b.totalWins.compareTo(a.totalWins);
        if (wins != 0) return wins;
        return b.totalGamesPlayed.compareTo(a.totalGamesPlayed);
      });

    final totalGames = stats.fold<int>(0, (sum, item) => sum + item.totalGamesPlayed);
    final totalWins = stats.fold<int>(0, (sum, item) => sum + item.totalWins);
    final totalLosses = stats.fold<int>(0, (sum, item) => sum + item.totalLosses);

    return Scaffold(
      backgroundColor: colors.bgPage,
      appBar: AppBar(
        backgroundColor: colors.navbar,
        centerTitle: true,
        title: Text(
          'Statistics',
          style: TextStyle(fontWeight: FontWeight.bold, color: colors.textPrimary),
        ),
      ),
      body: SafeArea(
        child: stats.isEmpty
            ? Center(
                child: Text(
                  'No statistics yet',
                  style: TextStyle(color: colors.textSecondary, fontSize: 15),
                ),
              )
            : ListView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                children: [
                  Row(
                    children: [
                      Expanded(child: _SummaryCard(title: 'Games', value: totalGames.toString())),
                      const SizedBox(width: 10),
                      Expanded(child: _SummaryCard(title: 'Wins', value: totalWins.toString())),
                      const SizedBox(width: 10),
                      Expanded(child: _SummaryCard(title: 'Losses', value: totalLosses.toString())),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Top 3 Players',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...sorted.take(3).toList().asMap().entries.map((entry) {
                    final rank = entry.key + 1;
                    final player = entry.value;
                    return _LeaderboardRow(rank: rank, player: player);
                  }),
                  const SizedBox(height: 20),
                  Text(
                    'All Players',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                      color: colors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...sorted.map((player) => _StatsTile(player: player)),
                ],
              ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final String value;

  const _SummaryCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
        boxShadow: colors.cardShadow,
      ),
      child: Column(
        children: [
          Text(title, style: TextStyle(fontSize: 12, color: colors.textSecondary)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: colors.textPrimary)),
        ],
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final int rank;
  final dynamic player;

  const _LeaderboardRow({required this.rank, required this.player});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final accent = rank == 1
        ? AppColors.warning
        : rank == 2
            ? colors.accent
            : colors.success;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
        boxShadow: colors.cardShadow,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: accent.withValues(alpha: 0.18),
            child: Text(
              '#$rank',
              style: TextStyle(color: accent, fontWeight: FontWeight.w700, fontSize: 12),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              player.name,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: colors.textPrimary),
            ),
          ),
          Text(
            '${player.totalWins} W',
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: accent),
          ),
        ],
      ),
    );
  }
}

class _StatsTile extends StatelessWidget {
  final dynamic player;

  const _StatsTile({required this.player});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.bgCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.border),
        boxShadow: colors.cardShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              player.name,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: colors.textPrimary),
            ),
          ),
          _Metric(label: 'G', value: player.totalGamesPlayed.toString()),
          const SizedBox(width: 10),
          _Metric(label: 'W', value: player.totalWins.toString()),
          const SizedBox(width: 10),
          _Metric(label: 'L', value: player.totalLosses.toString()),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  final String label;
  final String value;

  const _Metric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(label, style: TextStyle(fontSize: 10, color: colors.textMuted)),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: colors.textPrimary)),
      ],
    );
  }
}
