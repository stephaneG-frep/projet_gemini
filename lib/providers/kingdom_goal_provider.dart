import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/kingdom_goal.dart';
import '../services/storage_service.dart';
import 'kingdom_provider.dart';
import 'player_provider.dart';

final kingdomGoalProvider =
    NotifierProvider<KingdomGoalNotifier, List<KingdomGoal>>(
      KingdomGoalNotifier.new,
    );

final kingdomGoalProgressProvider = Provider<List<KingdomGoalProgress>>((ref) {
  final goals = ref.watch(kingdomGoalProvider);
  final buildings = ref.watch(kingdomProvider);
  final player = ref.watch(playerProvider);
  final builtCount = buildings.where((building) => building.isBuilt).length;
  final kingdomLevel = buildings.fold(
    0,
    (total, building) => total + building.level,
  );
  final upgradedBuildings = buildings
      .where((building) => building.level >= 2)
      .length;

  return [
    for (final goal in goals)
      KingdomGoalProgress(
        goal: goal,
        current: switch (goal.type) {
          KingdomGoalType.builtBuildings => builtCount,
          KingdomGoalType.kingdomLevel => kingdomLevel,
          KingdomGoalType.completedSessions => player.completedSessions,
          KingdomGoalType.upgradedBuildings => upgradedBuildings,
          KingdomGoalType.totalFocusMinutes => player.totalFocusMinutes,
        },
      ),
  ];
});

class KingdomGoalProgress {
  const KingdomGoalProgress({required this.goal, required this.current});

  final KingdomGoal goal;
  final int current;

  int get cappedCurrent => current.clamp(0, goal.target);
  double get percent =>
      goal.target == 0 ? 1 : (cappedCurrent / goal.target).clamp(0, 1);
  bool get isComplete => current >= goal.target;
  bool get canClaim => isComplete && !goal.isClaimed;
}

class KingdomGoalNotifier extends Notifier<List<KingdomGoal>> {
  StorageService get _storage => StorageService.instance;

  static const defaultGoals = [
    KingdomGoal(
      id: 'first_builder',
      title: 'Premier chantier',
      description: 'Construis 2 batiments dans ton royaume.',
      type: KingdomGoalType.builtBuildings,
      target: 2,
      rewardCoins: 40,
      rewardXp: 20,
      iconName: 'build',
    ),
    KingdomGoal(
      id: 'small_village',
      title: 'Petit village',
      description: 'Atteins le niveau de royaume 5.',
      type: KingdomGoalType.kingdomLevel,
      target: 5,
      rewardCoins: 80,
      rewardXp: 40,
      iconName: 'castle',
    ),
    KingdomGoal(
      id: 'first_upgrade',
      title: 'Premiere amelioration',
      description: 'Ameliore au moins 1 batiment au niveau 2.',
      type: KingdomGoalType.upgradedBuildings,
      target: 1,
      rewardCoins: 70,
      rewardXp: 35,
      iconName: 'upgrade',
    ),
    KingdomGoal(
      id: 'focused_foundations',
      title: 'Fondations solides',
      description: 'Termine 5 sessions de focus.',
      type: KingdomGoalType.completedSessions,
      target: 5,
      rewardCoins: 100,
      rewardXp: 60,
      iconName: 'timer',
    ),
    KingdomGoal(
      id: 'growing_realm',
      title: 'Royaume en croissance',
      description: 'Construis 5 batiments.',
      type: KingdomGoalType.builtBuildings,
      target: 5,
      rewardCoins: 160,
      rewardXp: 90,
      iconName: 'spark',
    ),
    KingdomGoal(
      id: 'royal_momentum',
      title: 'Elan royal',
      description: 'Atteins le niveau de royaume 10.',
      type: KingdomGoalType.kingdomLevel,
      target: 10,
      rewardCoins: 220,
      rewardXp: 140,
      iconName: 'castle',
    ),
    KingdomGoal(
      id: 'mission_study_week',
      title: 'Mission longue : semaine studieuse',
      description: 'Cumule 150 minutes de concentration totale.',
      type: KingdomGoalType.totalFocusMinutes,
      target: 150,
      rewardCoins: 260,
      rewardXp: 180,
      iconName: 'timer',
    ),
    KingdomGoal(
      id: 'mission_capital',
      title: 'Mission longue : capitale du focus',
      description: 'Atteins le niveau de royaume 15.',
      type: KingdomGoalType.kingdomLevel,
      target: 15,
      rewardCoins: 360,
      rewardXp: 240,
      iconName: 'castle',
    ),
    KingdomGoal(
      id: 'mission_master_builder',
      title: 'Mission longue : maitre batisseur',
      description: 'Ameliore 5 batiments au niveau 2 ou plus.',
      type: KingdomGoalType.upgradedBuildings,
      target: 5,
      rewardCoins: 420,
      rewardXp: 300,
      iconName: 'upgrade',
    ),
  ];

  @override
  List<KingdomGoal> build() => _storage.loadKingdomGoals(defaultGoals);

  Future<ClaimGoalResult> claim(String id) async {
    final index = state.indexWhere((goal) => goal.id == id);
    if (index == -1) {
      return ClaimGoalResult.notFound;
    }

    final progress = ref
        .read(kingdomGoalProgressProvider)
        .firstWhere((item) => item.goal.id == id);
    if (progress.goal.isClaimed) {
      return ClaimGoalResult.alreadyClaimed;
    }
    if (!progress.isComplete) {
      return ClaimGoalResult.notComplete;
    }

    await ref
        .read(playerProvider.notifier)
        .grantReward(
          xp: progress.goal.rewardXp,
          coins: progress.goal.rewardCoins,
        );

    final updated = [...state];
    updated[index] = progress.goal.copyWith(isClaimed: true);
    state = updated;
    await _storage.saveKingdomGoals(state);
    return ClaimGoalResult.claimed;
  }
}

enum ClaimGoalResult { claimed, alreadyClaimed, notComplete, notFound }
