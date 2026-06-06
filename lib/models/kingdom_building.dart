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
    this.isBuilt = false,
  });

  factory KingdomBuilding.fromMap(Map<dynamic, dynamic> map) {
    return KingdomBuilding(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      cost: map['cost'] as int,
      requiredLevel: map['requiredLevel'] as int,
      iconName: map['iconName'] as String,
      bonusCoins: map['bonusCoins'] as int? ?? 0,
      bonusXp: map['bonusXp'] as int? ?? 0,
      isBuilt: map['isBuilt'] as bool? ?? false,
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

  bool get hasBonus => bonusCoins > 0 || bonusXp > 0;

  String get bonusLabel {
    final parts = <String>[];
    if (bonusXp > 0) {
      parts.add('+$bonusXp XP/session');
    }
    if (bonusCoins > 0) {
      parts.add('+$bonusCoins pieces/session');
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
        'isBuilt': isBuilt,
      };

  KingdomBuilding copyWith({bool? isBuilt}) {
    return KingdomBuilding(
      id: id,
      name: name,
      description: description,
      cost: cost,
      requiredLevel: requiredLevel,
      iconName: iconName,
      bonusCoins: bonusCoins,
      bonusXp: bonusXp,
      isBuilt: isBuilt ?? this.isBuilt,
    );
  }
}
