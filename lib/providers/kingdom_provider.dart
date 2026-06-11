import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/kingdom_building.dart';
import '../services/storage_service.dart';
import 'player_provider.dart';

final kingdomProvider =
    NotifierProvider<KingdomNotifier, List<KingdomBuilding>>(
      KingdomNotifier.new,
    );

final kingdomStrategyProvider =
    NotifierProvider<KingdomStrategyNotifier, KingdomStrategy>(
      KingdomStrategyNotifier.new,
    );

enum KingdomStrategy { balanced, scholar, merchant, recovery }

extension KingdomStrategyDetails on KingdomStrategy {
  String get title {
    return switch (this) {
      KingdomStrategy.balanced => 'Equilibre',
      KingdomStrategy.scholar => 'Etude',
      KingdomStrategy.merchant => 'Commerce',
      KingdomStrategy.recovery => 'Recuperation',
    };
  }

  String get description {
    return switch (this) {
      KingdomStrategy.balanced => 'Un petit bonus partout.',
      KingdomStrategy.scholar => 'Plus d XP pour monter de niveau.',
      KingdomStrategy.merchant => 'Plus de pieces pour construire vite.',
      KingdomStrategy.recovery => 'Plus de HP pour tenir le rythme.',
    };
  }

  IconData get icon {
    return switch (this) {
      KingdomStrategy.balanced => Icons.balance_rounded,
      KingdomStrategy.scholar => Icons.school_rounded,
      KingdomStrategy.merchant => Icons.paid_rounded,
      KingdomStrategy.recovery => Icons.favorite_rounded,
    };
  }

  int get bonusXp {
    return switch (this) {
      KingdomStrategy.balanced => 3,
      KingdomStrategy.scholar => 10,
      KingdomStrategy.merchant => 0,
      KingdomStrategy.recovery => 0,
    };
  }

  int get bonusCoins {
    return switch (this) {
      KingdomStrategy.balanced => 2,
      KingdomStrategy.scholar => 0,
      KingdomStrategy.merchant => 6,
      KingdomStrategy.recovery => 0,
    };
  }

  int get bonusHpRecovery {
    return switch (this) {
      KingdomStrategy.balanced => 1,
      KingdomStrategy.scholar => 0,
      KingdomStrategy.merchant => 0,
      KingdomStrategy.recovery => 7,
    };
  }
}

class KingdomBonus {
  const KingdomBonus({
    required this.xp,
    required this.coins,
    required this.hpRecovery,
    required this.streakCoins,
  });

  final int xp;
  final int coins;
  final int hpRecovery;
  final int streakCoins;
}

final kingdomBonusProvider = Provider<KingdomBonus>((ref) {
  final buildings = ref.watch(kingdomProvider);
  final strategy = ref.watch(kingdomStrategyProvider);
  final gardenLevel = buildings
      .where((building) => building.id == 'garden' && building.isBuilt)
      .fold(0, (total, building) => total + building.level);
  final guildLevel = buildings
      .where((building) => building.id == 'habit_guild' && building.isBuilt)
      .fold(0, (total, building) => total + building.level);

  return KingdomBonus(
    xp:
        buildings
            .where((building) => building.isBuilt)
            .fold(0, (total, building) => total + building.currentBonusXp) +
        strategy.bonusXp,
    coins:
        buildings
            .where((building) => building.isBuilt)
            .fold(0, (total, building) => total + building.currentBonusCoins) +
        strategy.bonusCoins,
    hpRecovery: (gardenLevel * 3) + strategy.bonusHpRecovery,
    streakCoins: guildLevel * 15,
  );
});

class KingdomStrategyNotifier extends Notifier<KingdomStrategy> {
  StorageService get _storage => StorageService.instance;

  @override
  KingdomStrategy build() {
    final savedName = _storage.loadKingdomStrategyName();
    return KingdomStrategy.values.firstWhere(
      (strategy) => strategy.name == savedName,
      orElse: () => KingdomStrategy.balanced,
    );
  }

  Future<void> setStrategy(KingdomStrategy strategy) async {
    state = strategy;
    await _storage.saveKingdomStrategyName(strategy.name);
  }
}

class KingdomNotifier extends Notifier<List<KingdomBuilding>> {
  StorageService get _storage => StorageService.instance;

  static const defaultBuildings = [
    KingdomBuilding(
      id: 'focus_camp',
      name: 'Camp du Focus',
      description:
          'Le premier feu de camp du royaume. Chaque grande aventure commence ici.',
      cost: 0,
      requiredLevel: 1,
      iconName: 'home',
      bonusCoins: 0,
      bonusXp: 0,
      maxLevel: 3,
      level: 1,
      isBuilt: true,
    ),
    KingdomBuilding(
      id: 'quiet_office',
      name: 'Bureau calme',
      description:
          'Un lieu stable pour transformer les intentions en vraies sessions.',
      cost: 45,
      requiredLevel: 1,
      iconName: 'desk',
      bonusCoins: 2,
      bonusXp: 0,
      maxLevel: 3,
    ),
    KingdomBuilding(
      id: 'library',
      name: 'Bibliotheque',
      description: 'Les livres du royaume renforcent chaque session terminee.',
      cost: 120,
      requiredLevel: 2,
      iconName: 'library',
      bonusCoins: 0,
      bonusXp: 6,
      maxLevel: 3,
    ),
    KingdomBuilding(
      id: 'garden',
      name: 'Jardin de recuperation',
      description:
          'Un espace doux pour garder le rythme sans se bruler les ailes.',
      cost: 190,
      requiredLevel: 3,
      iconName: 'garden',
      bonusCoins: 1,
      bonusXp: 2,
      maxLevel: 3,
    ),
    KingdomBuilding(
      id: 'pomodoro_workshop',
      name: 'Atelier Pomodoro',
      description:
          'Les artisans du temps ameliorent les recompenses de chaque quete.',
      cost: 320,
      requiredLevel: 4,
      iconName: 'workshop',
      bonusCoins: 3,
      bonusXp: 6,
      maxLevel: 3,
    ),
    KingdomBuilding(
      id: 'habit_guild',
      name: 'Guilde des habitudes',
      description: 'Une guilde dediee a la regularite et aux longues series.',
      cost: 500,
      requiredLevel: 6,
      iconName: 'guild',
      bonusCoins: 4,
      bonusXp: 8,
      maxLevel: 3,
    ),
    KingdomBuilding(
      id: 'focus_tower',
      name: 'Tour de concentration',
      description:
          'Le symbole du royaume : chaque session y laisse une trace visible.',
      cost: 780,
      requiredLevel: 8,
      iconName: 'tower',
      bonusCoins: 6,
      bonusXp: 14,
      maxLevel: 3,
    ),
  ];

  @override
  List<KingdomBuilding> build() =>
      _storage.loadKingdomBuildings(defaultBuildings);

  Future<BuildResult> buildBuilding(String id) async {
    final index = state.indexWhere((building) => building.id == id);
    if (index == -1) {
      return BuildResult.notFound;
    }

    final building = state[index];
    final player = ref.read(playerProvider);
    if (building.isBuilt) {
      return BuildResult.alreadyBuilt;
    }
    if (player.level < building.requiredLevel) {
      return BuildResult.levelTooLow;
    }

    final paid = await ref
        .read(playerProvider.notifier)
        .spendCoins(building.cost);
    if (!paid) {
      return BuildResult.notEnoughCoins;
    }

    final updated = [...state];
    updated[index] = building.copyWith(isBuilt: true, level: 1);
    state = updated;
    await _storage.saveKingdomBuildings(state);
    return BuildResult.built;
  }

  Future<BuildResult> upgradeBuilding(String id) async {
    final index = state.indexWhere((building) => building.id == id);
    if (index == -1) {
      return BuildResult.notFound;
    }

    final building = state[index];
    if (!building.isBuilt) {
      return BuildResult.notBuilt;
    }
    if (!building.canUpgrade) {
      return BuildResult.maxLevel;
    }

    final paid = await ref
        .read(playerProvider.notifier)
        .spendCoins(building.upgradeCost);
    if (!paid) {
      return BuildResult.notEnoughCoins;
    }

    final updated = [...state];
    updated[index] = building.copyWith(level: building.level + 1);
    state = updated;
    await _storage.saveKingdomBuildings(state);
    return BuildResult.upgraded;
  }
}

enum BuildResult {
  built,
  upgraded,
  alreadyBuilt,
  notBuilt,
  maxLevel,
  levelTooLow,
  notEnoughCoins,
  notFound,
}
