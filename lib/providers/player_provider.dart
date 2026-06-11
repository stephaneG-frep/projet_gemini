import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/player.dart';
import '../services/storage_service.dart';

final playerProvider = NotifierProvider<PlayerNotifier, Player>(
  PlayerNotifier.new,
);

class PlayerNotifier extends Notifier<Player> {
  StorageService get _storage => StorageService.instance;

  @override
  Player build() => _storage.loadPlayer();

  Future<void> completeFocusSession({
    int bonusXp = 0,
    int bonusCoins = 0,
    int hpRecovery = 0,
    int streakBonusCoins = 0,
  }) async {
    var xp = state.xp + 25 + bonusXp;
    var coins = state.coins + 10 + bonusCoins;
    var earnedCoins = state.totalCoinsEarned + 10 + bonusCoins;
    var level = state.level;
    var maxHp = state.maxHp;
    var hp = state.hp;
    var xpToNextLevel = state.xpToNextLevel;
    final completedSessions = state.completedSessions + 1;
    final streak = state.streak + 1;

    if (completedSessions % 4 == 0) {
      coins += 50;
      earnedCoins += 50;
    }

    if (streakBonusCoins > 0 && streak % 3 == 0) {
      coins += streakBonusCoins;
      earnedCoins += streakBonusCoins;
    }

    while (xp >= xpToNextLevel) {
      xp -= xpToNextLevel;
      level += 1;
      maxHp += 10;
      hp = maxHp;
      xpToNextLevel = (xpToNextLevel * 1.25).round() + 25;
    }

    if (hpRecovery > 0) {
      hp = (hp + hpRecovery).clamp(0, maxHp);
    }

    state = state.copyWith(
      level: level,
      xp: xp,
      xpToNextLevel: xpToNextLevel,
      coins: coins,
      hp: hp,
      maxHp: maxHp,
      streak: streak,
      bestStreak: streak > state.bestStreak ? streak : state.bestStreak,
      totalFocusMinutes: state.totalFocusMinutes + 25,
      completedSessions: completedSessions,
      totalCoinsEarned: earnedCoins,
    );
    await _storage.savePlayer(state);
  }

  Future<void> applyBackgroundPenalty() async {
    final newHp = state.hp - 10;
    if (newHp <= 0) {
      state = state.copyWith(
        hp: (state.maxHp / 2).round(),
        streak: 0,
        failedSessions: state.failedSessions + 1,
      );
    } else {
      state = state.copyWith(
        hp: newHp,
        failedSessions: state.failedSessions + 1,
      );
    }
    await _storage.savePlayer(state);
  }

  Future<void> failSession() async {
    state = state.copyWith(failedSessions: state.failedSessions + 1, streak: 0);
    await _storage.savePlayer(state);
  }

  Future<bool> spendCoins(int amount) async {
    if (state.coins < amount) {
      return false;
    }
    state = state.copyWith(coins: state.coins - amount);
    await _storage.savePlayer(state);
    return true;
  }

  Future<void> grantReward({int xp = 0, int coins = 0}) async {
    var newXp = state.xp + xp;
    var level = state.level;
    var maxHp = state.maxHp;
    var hp = state.hp;
    var xpToNextLevel = state.xpToNextLevel;

    while (newXp >= xpToNextLevel) {
      newXp -= xpToNextLevel;
      level += 1;
      maxHp += 10;
      hp = maxHp;
      xpToNextLevel = (xpToNextLevel * 1.25).round() + 25;
    }

    state = state.copyWith(
      level: level,
      xp: newXp,
      xpToNextLevel: xpToNextLevel,
      coins: state.coins + coins,
      hp: hp,
      maxHp: maxHp,
      totalCoinsEarned: state.totalCoinsEarned + coins,
    );
    await _storage.savePlayer(state);
  }
}
