import 'package:hive/hive.dart';

part 'player_statistics.g.dart';

@HiveType(typeId: 6)
class PlayerStatistics extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  int totalGamesPlayed;

  @HiveField(2)
  int totalWins;

  @HiveField(3)
  int totalLosses;

  @HiveField(4)
  DateTime lastUpdated;

  PlayerStatistics({
    required this.name,
    this.totalGamesPlayed = 0,
    this.totalWins = 0,
    this.totalLosses = 0,
    DateTime? lastUpdated,
  }) : lastUpdated = lastUpdated ?? DateTime.now();

  PlayerStatistics copyWith({
    String? name,
    int? totalGamesPlayed,
    int? totalWins,
    int? totalLosses,
    DateTime? lastUpdated,
  }) {
    return PlayerStatistics(
      name: name ?? this.name,
      totalGamesPlayed: totalGamesPlayed ?? this.totalGamesPlayed,
      totalWins: totalWins ?? this.totalWins,
      totalLosses: totalLosses ?? this.totalLosses,
      lastUpdated: lastUpdated ?? DateTime.now(),
    );
  }

  double get winRate {
    if (totalGamesPlayed == 0) return 0;
    return totalWins / totalGamesPlayed;
  }
}
