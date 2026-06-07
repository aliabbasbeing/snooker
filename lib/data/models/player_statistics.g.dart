// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_statistics.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlayerStatisticsAdapter extends TypeAdapter<PlayerStatistics> {
  @override
  final int typeId = 6;

  @override
  PlayerStatistics read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlayerStatistics(
      name: fields[0] as String,
      totalGamesPlayed: (fields[1] as int?) ?? 0,
      totalWins: (fields[2] as int?) ?? 0,
      totalLosses: (fields[3] as int?) ?? 0,
      lastUpdated: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, PlayerStatistics obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.totalGamesPlayed)
      ..writeByte(2)
      ..write(obj.totalWins)
      ..writeByte(3)
      ..write(obj.totalLosses)
      ..writeByte(4)
      ..write(obj.lastUpdated);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlayerStatisticsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
