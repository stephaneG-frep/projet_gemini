import 'package:flutter/material.dart';

class KingdomBuilding {
  const KingdomBuilding({
    required this.id,
    required this.name,
    required this.description,
    required this.cost,
    required this.requiredLevel,
    required this.iconName,
    required this.bonusCoins,
    required this.bonusXp,
    required this.maxLevel,
    this.level = 0,
    this.isBuilt = false,
  });

  factory KingdomBuilding.fromMap(Map<dynamic, dynamic> map) {
    final isBuilt = map['isBuilt'] as bool? ?? false;
    final savedLevel = map['level'] as int?;
    return KingdomBuilding(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      cost: map['cost'] as int,
      requiredLevel: map['requiredLevel'] as int,
      iconName: map['iconName'] as String,
      bonusCoins: map['bonusCoins'] as int? ?? 0,
      bonusXp: map['bonusXp'] as int? ?? 0,
      maxLevel: map['maxLevel'] as int? ?? 3,
      level: savedLevel ?? (isBuilt ? 1 : 0),
      isBuilt: isBuilt,
    );
  }

  final String id;
  final String name;
  final String description;
  final int cost;
  final int requiredLevel;
  final String iconName;
  final int bonusCoins;
  final int bonusXp;
  final int maxLevel;
  final int level;
  final bool isBuilt;

  IconData get icon {
    return switch (iconName) {
      'home' => Icons.cottage_rounded,
      'desk' => Icons.desktop_windows_rounded,
      'library' => Icons.local_library_rounded,
      'garden' => Icons.park_rounded,
      'workshop' => Icons.handyman_rounded,
      'guild' => Icons.groups_rounded,
      'tower' => Icons.castle_rounded,
      _ => Icons.account_balance_rounded,
    };
  }

  String get imageAsset {
    return switch (id) {
      'focus_camp' => 'assets/images/kingdom_focus_camp.png',
      'quiet_office' => 'assets/images/kingdom_quiet_office.png',
      'library' => 'assets/images/kingdom_library.png',
      'garden' => 'assets/images/kingdom_garden.png',
      'pomodoro_workshop' => 'assets/images/kingdom_pomodoro_workshop.png',
      'habit_guild' => 'assets/images/kingdom_habit_guild.png',
      'focus_tower' => 'assets/images/kingdom_focus_tower.png',
      _ => 'assets/images/kingdom_focus_camp.png',
    };
  }

  bool get canUpgrade => isBuilt && level < maxLevel;
  int get currentBonusCoins => isBuilt ? bonusCoins * level : 0;
  int get currentBonusXp => isBuilt ? bonusXp * level : 0;
  int get nextBonusCoins => bonusCoins * (level + 1).clamp(0, maxLevel);
  int get nextBonusXp => bonusXp * (level + 1).clamp(0, maxLevel);
  int get upgradeCost => (cost * (1.05 + (level * 0.55))).round();

  bool get hasBonus => bonusCoins > 0 || bonusXp > 0;

  String get bonusLabel {
    final parts = <String>[];
    if (currentBonusXp > 0) {
      parts.add('+$currentBonusXp XP/session');
    }
    if (currentBonusCoins > 0) {
      parts.add('+$currentBonusCoins pieces/session');
    }
    return parts.join('  ');
  }

  String get nextBonusLabel {
    final parts = <String>[];
    if (nextBonusXp > currentBonusXp) {
      parts.add('+${nextBonusXp - currentBonusXp} XP/session');
    }
    if (nextBonusCoins > currentBonusCoins) {
      parts.add('+${nextBonusCoins - currentBonusCoins} pieces/session');
    }
    return parts.join('  ');
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'description': description,
    'cost': cost,
    'requiredLevel': requiredLevel,
    'iconName': iconName,
    'bonusCoins': bonusCoins,
    'bonusXp': bonusXp,
    'maxLevel': maxLevel,
    'level': level,
    'isBuilt': isBuilt,
  };

  KingdomBuilding copyWith({bool? isBuilt, int? level}) {
    return KingdomBuilding(
      id: id,
      name: name,
      description: description,
      cost: cost,
      requiredLevel: requiredLevel,
      iconName: iconName,
      bonusCoins: bonusCoins,
      bonusXp: bonusXp,
      maxLevel: maxLevel,
      level: level ?? this.level,
      isBuilt: isBuilt ?? this.isBuilt,
    );
  }
}
