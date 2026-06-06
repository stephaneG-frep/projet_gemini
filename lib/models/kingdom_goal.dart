import 'package:flutter/material.dart';

enum KingdomGoalType { builtBuildings, kingdomLevel, completedSessions, upgradedBuildings }

class KingdomGoal {
  const KingdomGoal({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.target,
    required this.rewardCoins,
    required this.rewardXp,
    required this.iconName,
    this.isClaimed = false,
  });

  factory KingdomGoal.fromMap(Map<dynamic, dynamic> map) {
    return KingdomGoal(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      type: KingdomGoalType.values.firstWhere(
        (type) => type.name == map['type'],
        orElse: () => KingdomGoalType.builtBuildings,
      ),
      target: map['target'] as int,
      rewardCoins: map['rewardCoins'] as int,
      rewardXp: map['rewardXp'] as int,
      iconName: map['iconName'] as String,
      isClaimed: map['isClaimed'] as bool? ?? false,
    );
  }

  final String id;
  final String title;
  final String description;
  final KingdomGoalType type;
  final int target;
  final int rewardCoins;
  final int rewardXp;
  final String iconName;
  final bool isClaimed;

  IconData get icon {
    return switch (iconName) {
      'castle' => Icons.castle_rounded,
      'build' => Icons.construction_rounded,
      'upgrade' => Icons.upgrade_rounded,
      'timer' => Icons.timer_rounded,
      'spark' => Icons.auto_awesome_rounded,
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

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
        'type': type.name,
        'target': target,
        'rewardCoins': rewardCoins,
        'rewardXp': rewardXp,
        'iconName': iconName,
        'isClaimed': isClaimed,
      };

  KingdomGoal copyWith({bool? isClaimed}) {
    return KingdomGoal(
      id: id,
      title: title,
      description: description,
      type: type,
      target: target,
      rewardCoins: rewardCoins,
      rewardXp: rewardXp,
      iconName: iconName,
      isClaimed: isClaimed ?? this.isClaimed,
    );
  }
}
