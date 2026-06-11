import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'kingdom_provider.dart';
import 'player_provider.dart';
import 'settings_provider.dart';

enum PomodoroStatus { idle, running, paused, completed, abandoned }

class PomodoroTimerState {
  const PomodoroTimerState({
    required this.totalSeconds,
    required this.remainingSeconds,
    required this.status,
  });

  factory PomodoroTimerState.initial({int totalSeconds = 25 * 60}) {
    return PomodoroTimerState(
      totalSeconds: totalSeconds,
      remainingSeconds: totalSeconds,
      status: PomodoroStatus.idle,
    );
  }

  final int totalSeconds;
  final int remainingSeconds;
  final PomodoroStatus status;

  bool get isActive =>
      status == PomodoroStatus.running || status == PomodoroStatus.paused;
  bool get isRunning => status == PomodoroStatus.running;
  double get progress => 1 - (remainingSeconds / totalSeconds);

  PomodoroTimerState copyWith({
    int? totalSeconds,
    int? remainingSeconds,
    PomodoroStatus? status,
  }) {
    return PomodoroTimerState(
      totalSeconds: totalSeconds ?? this.totalSeconds,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      status: status ?? this.status,
    );
  }
}

final timerProvider = NotifierProvider<TimerNotifier, PomodoroTimerState>(
  TimerNotifier.new,
);

class TimerNotifier extends Notifier<PomodoroTimerState> {
  Timer? _timer;

  @override
  PomodoroTimerState build() {
    ref.onDispose(() => _timer?.cancel());
    final totalSeconds = ref.watch(settingsProvider).focusSeconds;
    return PomodoroTimerState.initial(totalSeconds: totalSeconds);
  }

  void start() {
    _timer?.cancel();
    final totalSeconds = ref.read(settingsProvider).focusSeconds;
    state = PomodoroTimerState.initial(
      totalSeconds: totalSeconds,
    ).copyWith(status: PomodoroStatus.running);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void pause() {
    if (!state.isRunning) {
      return;
    }
    _timer?.cancel();
    state = state.copyWith(status: PomodoroStatus.paused);
  }

  void resume() {
    if (state.status != PomodoroStatus.paused) {
      return;
    }
    state = state.copyWith(status: PomodoroStatus.running);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void abandon() {
    _timer?.cancel();
    state = PomodoroTimerState.initial(
      totalSeconds: state.totalSeconds,
    ).copyWith(status: PomodoroStatus.abandoned);
  }

  void reset() {
    _timer?.cancel();
    final totalSeconds = ref.read(settingsProvider).focusSeconds;
    state = PomodoroTimerState.initial(totalSeconds: totalSeconds);
  }

  Future<void> _tick() async {
    if (state.remainingSeconds <= 1) {
      _timer?.cancel();
      state = state.copyWith(
        remainingSeconds: 0,
        status: PomodoroStatus.completed,
      );
      final kingdomBonus = ref.read(kingdomBonusProvider);
      await ref
          .read(playerProvider.notifier)
          .completeFocusSession(
            bonusXp: kingdomBonus.xp,
            bonusCoins: kingdomBonus.coins,
            hpRecovery: kingdomBonus.hpRecovery,
            streakBonusCoins: kingdomBonus.streakCoins,
          );
      return;
    }
    state = state.copyWith(remainingSeconds: state.remainingSeconds - 1);
  }
}
