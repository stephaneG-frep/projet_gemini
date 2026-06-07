import 'package:flutter/material.dart';

enum DailyQuestType { completeSessions, earnCoins, buildOrUpgrade }

class DailyQuest {
  const DailyQuest({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.target,
    required this.rewardCoins,
    required this.rewardXp,
    required this.iconName,
  });

  final String id;
  final String title;
  final String description;
  final DailyQuestType type;
  final int target;
  final int rewardCoins;
  final int rewardXp;
  final String iconName;

  IconData get icon {
    return switch (iconName) {
      'timer' => Icons.timer_rounded,
      'coins' => Icons.toll_rounded,
      'build' => Icons.construction_rounded,
      _ => Icons.flag_rounded,
    };
  }

  String get rewardLabel {
    final parts = <String>[];
    if (rewardXp > 0) {
      parts.add('+$rewardXp XP');
    }
    if (rewardCoins > 0) {
      parts.add('+$rewardCoins pieces');
    }
    return parts.join('  ');
  }
}

class DailyQuestState {
  const DailyQuestState({
    required this.dateKey,
    required this.claimedIds,
    required this.startCompletedSessions,
    required this.startCoinsEarned,
    required this.startBuiltCount,
    required this.startUpgradedCount,
  });

  factory DailyQuestState.fromMap(Map<dynamic, dynamic> map) {
    return DailyQuestState(
      dateKey: map['dateKey'] as String,
      claimedIds: (map['claimedIds'] as List? ?? const []).whereType<String>().toSet(),
      startCompletedSessions: map['startCompletedSessions'] as int? ?? 0,
      startCoinsEarned: map['startCoinsEarned'] as int? ?? 0,
      startBuiltCount: map['startBuiltCount'] as int? ?? 0,
      startUpgradedCount: map['startUpgradedCount'] as int? ?? 0,
    );
  }

  final String dateKey;
  final Set<String> claimedIds;
  final int startCompletedSessions;
  final int startCoinsEarned;
  final int startBuiltCount;
  final int startUpgradedCount;

  Map<String, dynamic> toMap() => {
        'dateKey': dateKey,
        'claimedIds': claimedIds.toList(),
        'startCompletedSessions': startCompletedSessions,
        'startCoinsEarned': startCoinsEarned,
        'startBuiltCount': startBuiltCount,
        'startUpgradedCount': startUpgradedCount,
      };

  DailyQuestState copyWith({Set<String>? claimedIds}) {
    return DailyQuestState(
      dateKey: dateKey,
      claimedIds: claimedIds ?? this.claimedIds,
      startCompletedSessions: startCompletedSessions,
      startCoinsEarned: startCoinsEarned,
      startBuiltCount: startBuiltCount,
      startUpgradedCount: startUpgradedCount,
    );
  }
}
