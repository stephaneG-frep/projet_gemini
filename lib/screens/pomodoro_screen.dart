import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/player_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/shop_provider.dart';
import '../providers/timer_provider.dart';
import '../services/lifecycle_service.dart';
import '../widgets/animated_buddy.dart';
import '../widgets/circular_timer.dart';
import '../widgets/rpg_button.dart';
import 'reward_screen.dart';

class PomodoroScreen extends ConsumerStatefulWidget {
  const PomodoroScreen({super.key});

  static const routeName = '/pomodoro';

  @override
  ConsumerState<PomodoroScreen> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends ConsumerState<PomodoroScreen> {
  late final FocusLifecycleObserver _observer;
  bool _rewardShown = false;
  bool _showPenaltyMessage = false;

  @override
  void initState() {
    super.initState();
    _observer = FocusLifecycleObserver(
      isSessionActive: () => ref.read(timerProvider).isActive,
      onBackgrounded: () {
        ref.read(playerProvider.notifier).applyBackgroundPenalty();
        _showPenaltyMessage = true;
      },
      onForegrounded: () {
        if (!mounted || !_showPenaltyMessage) {
          return;
        }
        _showPenaltyMessage = false;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Tu as quitte la quete : -10 PV.')),
        );
      },
    );
    WidgetsBinding.instance.addObserver(_observer);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(timerProvider.notifier).start();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(_observer);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(timerProvider, (previous, next) {
      if (next.status == PomodoroStatus.completed && !_rewardShown) {
        _rewardShown = true;
        Navigator.pushReplacementNamed(context, RewardScreen.routeName);
      }
    });

    final timer = ref.watch(timerProvider);
    final settings = ref.watch(settingsProvider);
    final equippedItems = ref.watch(shopProvider).where((item) => item.isEquipped);
    final equippedItem = equippedItems.isEmpty ? null : equippedItems.first;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Quete Pomodoro')),
      body: SafeArea(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? const [Color(0xFF101A2B), Color(0xFF16253C), Color(0xFF0F1624)]
                  : const [Color(0xFFEAF3FF), Color(0xFFFFF7EA)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                AnimatedBuddy(equippedItem: equippedItem, size: 118),
                const SizedBox(height: 12),
                if (settings.devModeEnabled)
                  Chip(
                    avatar: const Icon(Icons.speed_rounded, size: 18),
                    label: Text('Mode dev : ${settings.devTimerSeconds}s'),
                  ),
                const Spacer(),
                CircularTimer(progress: timer.progress, remainingSeconds: timer.remainingSeconds),
                const SizedBox(height: 32),
                Text(
                  _statusLabel(timer.status),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    RpgButton(
                      label: 'Pause',
                      icon: Icons.pause_rounded,
                      isPrimary: false,
                      onPressed: timer.isRunning ? ref.read(timerProvider.notifier).pause : null,
                    ),
                    RpgButton(
                      label: 'Reprendre',
                      icon: Icons.play_arrow_rounded,
                      isPrimary: false,
                      onPressed: timer.status == PomodoroStatus.paused ? ref.read(timerProvider.notifier).resume : null,
                    ),
                    RpgButton(
                      label: 'Abandonner',
                      icon: Icons.flag_rounded,
                      isPrimary: false,
                      onPressed: () async {
                        ref.read(timerProvider.notifier).abandon();
                        await ref.read(playerProvider.notifier).failSession();
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _statusLabel(PomodoroStatus status) {
    return switch (status) {
      PomodoroStatus.running => "Reste dans l'app pour proteger ton heros.",
      PomodoroStatus.paused => 'Session en pause.',
      PomodoroStatus.completed => 'Session terminee !',
      PomodoroStatus.abandoned => 'Session abandonnee.',
      PomodoroStatus.idle => 'Preparation de la quete...',
    };
  }
}
