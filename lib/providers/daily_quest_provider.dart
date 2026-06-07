import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/daily_quest.dart';
import '../services/storage_service.dart';
import 'kingdom_provider.dart';
import 'player_provider.dart';

final dailyQuestProvider = NotifierProvider<DailyQuestNotifier, DailyQuestState>(DailyQuestNotifier.new);

final dailyQuestProgressProvider = Provider<List<DailyQuestProgress>>((ref) {
  final state = ref.watch(dailyQuestProvider);
  final player = ref.watch(playerProvider);
  final buildings = ref.watch(kingdomProvider);
  final builtCount = buildings.where((building) => building.isBuilt).length;
  final upgradedCount = buildings.where((building) => building.level >= 2).length;

  return [
    for (final quest in DailyQuestNotifier.dailyQuests)
      DailyQuestProgress(
        quest: quest,
        isClaimed: state.claimedIds.contains(quest.id),
        current: switch (quest.type) {
          DailyQuestType.completeSessions => player.completedSessions - state.startCompletedSessions,
          DailyQuestType.earnCoins => player.totalCoinsEarned - state.startCoinsEarned,
          DailyQuestType.buildOrUpgrade => (builtCount - state.startBuiltCount) + (upgradedCount - state.startUpgradedCount),
        },
      ),
  ];
});

class DailyQuestProgress {
  const DailyQuestProgress({
    required this.quest,
    required this.current,
    required this.isClaimed,
  });

  final DailyQuest quest;
  final int current;
  final bool isClaimed;

  int get safeCurrent => current < 0 ? 0 : current;
  int get cappedCurrent => safeCurrent.clamp(0, quest.target);
  double get percent => quest.target == 0 ? 1 : (cappedCurrent / quest.target).clamp(0, 1);
  bool get isComplete => safeCurrent >= quest.target;
  bool get canClaim => isComplete && !isClaimed;
}

class DailyQuestNotifier extends Notifier<DailyQuestState> {
  StorageService get _storage => StorageService.instance;

  static const dailyQuests = [
    DailyQuest(
      id: 'daily_focus',
      title: 'Focus du jour',
      description: 'Termine 1 session de concentration aujourd hui.',
      type: DailyQuestType.completeSessions,
      target: 1,
      rewardCoins: 25,
      rewardXp: 20,
      iconName: 'timer',
    ),
    DailyQuest(
      id: 'daily_treasury',
      title: 'Tresor du jour',
      description: 'Gagne 30 pieces aujourd hui.',
      type: DailyQuestType.earnCoins,
      target: 30,
      rewardCoins: 35,
      rewardXp: 15,
      iconName: 'coins',
    ),
    DailyQuest(
      id: 'daily_builder',
      title: 'Main du batisseur',
      description: 'Construis ou ameliore 1 batiment aujourd hui.',
      type: DailyQuestType.buildOrUpgrade,
      target: 1,
      rewardCoins: 45,
      rewardXp: 30,
      iconName: 'build',
    ),
  ];

  @override
  DailyQuestState build() {
    final loaded = _storage.loadDailyQuestState();
    final today = _todayKey();
    if (loaded != null && loaded.dateKey == today) {
      return loaded;
    }
    final fresh = _freshState(today);
    _storage.saveDailyQuestState(fresh);
    return fresh;
  }

  Future<ClaimDailyQuestResult> claim(String id) async {
    final progress = ref.read(dailyQuestProgressProvider).firstWhere(
          (item) => item.quest.id == id,
          orElse: () => throw StateError('Quest not found'),
        );

    if (progress.isClaimed) {
      return ClaimDailyQuestResult.alreadyClaimed;
    }
    if (!progress.isComplete) {
      return ClaimDailyQuestResult.notComplete;
    }

    await ref.read(playerProvider.notifier).grantReward(
          xp: progress.quest.rewardXp,
          coins: progress.quest.rewardCoins,
        );

    state = state.copyWith(claimedIds: {...state.claimedIds, id});
    await _storage.saveDailyQuestState(state);
    return ClaimDailyQuestResult.claimed;
  }

  DailyQuestState _freshState(String dateKey) {
    final player = ref.read(playerProvider);
    final buildings = ref.read(kingdomProvider);
    return DailyQuestState(
      dateKey: dateKey,
      claimedIds: const {},
      startCompletedSessions: player.completedSessions,
      startCoinsEarned: player.totalCoinsEarned,
      startBuiltCount: buildings.where((building) => building.isBuilt).length,
      startUpgradedCount: buildings.where((building) => building.level >= 2).length,
    );
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}

enum ClaimDailyQuestResult { claimed, alreadyClaimed, notComplete }
