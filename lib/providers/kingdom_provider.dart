import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/kingdom_building.dart';
import '../services/storage_service.dart';
import 'player_provider.dart';

final kingdomProvider = NotifierProvider<KingdomNotifier, List<KingdomBuilding>>(KingdomNotifier.new);

class KingdomBonus {
  const KingdomBonus({required this.xp, required this.coins});

  final int xp;
  final int coins;
}

final kingdomBonusProvider = Provider<KingdomBonus>((ref) {
  final buildings = ref.watch(kingdomProvider);
  return KingdomBonus(
    xp: buildings.where((building) => building.isBuilt).fold(0, (total, building) => total + building.bonusXp),
    coins: buildings.where((building) => building.isBuilt).fold(0, (total, building) => total + building.bonusCoins),
  );
});

class KingdomNotifier extends Notifier<List<KingdomBuilding>> {
  StorageService get _storage => StorageService.instance;

  static const defaultBuildings = [
    KingdomBuilding(
      id: 'focus_camp',
      name: 'Camp du Focus',
      description: 'Le premier feu de camp du royaume. Chaque grande aventure commence ici.',
      cost: 0,
      requiredLevel: 1,
      iconName: 'home',
      bonusCoins: 0,
      bonusXp: 0,
      isBuilt: true,
    ),
    KingdomBuilding(
      id: 'quiet_office',
      name: 'Bureau calme',
      description: 'Un lieu stable pour transformer les intentions en vraies sessions.',
      cost: 60,
      requiredLevel: 1,
      iconName: 'desk',
      bonusCoins: 1,
      bonusXp: 0,
    ),
    KingdomBuilding(
      id: 'library',
      name: 'Bibliotheque',
      description: 'Les livres du royaume renforcent chaque session terminee.',
      cost: 140,
      requiredLevel: 2,
      iconName: 'library',
      bonusCoins: 0,
      bonusXp: 5,
    ),
    KingdomBuilding(
      id: 'garden',
      name: 'Jardin de recuperation',
      description: 'Un espace doux pour garder le rythme sans se bruler les ailes.',
      cost: 220,
      requiredLevel: 3,
      iconName: 'garden',
      bonusCoins: 2,
      bonusXp: 0,
    ),
    KingdomBuilding(
      id: 'pomodoro_workshop',
      name: 'Atelier Pomodoro',
      description: 'Les artisans du temps ameliorent les recompenses de chaque quete.',
      cost: 360,
      requiredLevel: 4,
      iconName: 'workshop',
      bonusCoins: 2,
      bonusXp: 5,
    ),
    KingdomBuilding(
      id: 'habit_guild',
      name: 'Guilde des habitudes',
      description: 'Une guilde dediee a la regularite et aux longues series.',
      cost: 560,
      requiredLevel: 6,
      iconName: 'guild',
      bonusCoins: 3,
      bonusXp: 8,
    ),
    KingdomBuilding(
      id: 'focus_tower',
      name: 'Tour de concentration',
      description: 'Le symbole du royaume : chaque session y laisse une trace visible.',
      cost: 900,
      requiredLevel: 8,
      iconName: 'tower',
      bonusCoins: 5,
      bonusXp: 12,
    ),
  ];

  @override
  List<KingdomBuilding> build() => _storage.loadKingdomBuildings(defaultBuildings);

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

    final paid = await ref.read(playerProvider.notifier).spendCoins(building.cost);
    if (!paid) {
      return BuildResult.notEnoughCoins;
    }

    final updated = [...state];
    updated[index] = building.copyWith(isBuilt: true);
    state = updated;
    await _storage.saveKingdomBuildings(state);
    return BuildResult.built;
  }
}

enum BuildResult { built, alreadyBuilt, levelTooLow, notEnoughCoins, notFound }
