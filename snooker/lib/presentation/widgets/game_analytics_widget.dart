import 'package:flutter/cupertino.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../data/models/game.dart';

class GameAnalyticsWidget extends StatelessWidget {
  final Game game;

  const GameAnalyticsWidget({
    super.key,
    required this.game,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: CupertinoColors.systemGroupedBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Game Analytics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          _buildStatsGrid(),
          const SizedBox(height: 24),
          const Text(
            'Player Scores',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: _buildBarChart(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    final totalPlayers = game.players.length;
    final completedPlayers = game.completedPlayers.length;
    final activePlayers = game.activePlayers.length;
    final totalScore = game.players.fold<int>(0, (sum, p) => sum + p.score);

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Players',
            '$totalPlayers',
            CupertinoColors.systemBlue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Completed',
            '$completedPlayers',
            CupertinoColors.systemGreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Active',
            '$activePlayers',
            CupertinoColors.systemOrange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            'Total Score',
            '$totalScore',
            CupertinoColors.systemPurple,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: CupertinoColors.systemGrey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart() {
    if (game.players.isEmpty) {
      return const Center(
        child: Text(
          'No data to display',
          style: TextStyle(color: CupertinoColors.systemGrey),
        ),
      );
    }

    final List<BarChartGroupData> barGroups = [];
    
    for (int i = 0; i < game.players.length; i++) {
      final player = game.players[i];
      final progress = (player.score / game.targetScore * 100).clamp(0, 100);
      
      barGroups.add(
        BarChartGroupData(
          x: i,
          barRods: [
            BarChartRodData(
              toY: progress.toDouble(),
              color: player.isCompleted
                  ? CupertinoColors.systemGreen
                  : CupertinoColors.systemBlue,
              width: 20,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(4),
              ),
            ),
          ],
        ),
      );
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: 100,
        barGroups: barGroups,
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                if (value.toInt() >= 0 && value.toInt() < game.players.length) {
                  final player = game.players[value.toInt()];
                  final name = player.name.length > 8
                      ? '${player.name.substring(0, 8)}...'
                      : player.name;
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 10,
                        color: CupertinoColors.systemGrey,
                      ),
                    ),
                  );
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}%',
                  style: const TextStyle(
                    fontSize: 10,
                    color: CupertinoColors.systemGrey,
                  ),
                );
              },
            ),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: 25,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: CupertinoColors.systemGrey5,
              strokeWidth: 1,
            );
          },
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}
