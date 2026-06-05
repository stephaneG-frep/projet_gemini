import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/player_provider.dart';
import '../providers/timer_provider.dart';
import '../widgets/rpg_button.dart';

class RewardScreen extends ConsumerWidget {
  const RewardScreen({super.key});

  static const routeName = '/reward';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);
    final hasBonus = player.completedSessions > 0 && player.completedSessions % 4 == 0;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 136,
                height: 136,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFE1A8),
                  borderRadius: BorderRadius.circular(40),
                ),
                child: const Icon(Icons.emoji_events_rounded, size: 84, color: Color(0xFFFF9F1C)),
              ),
              const SizedBox(height: 24),
              Text('Quete reussie !', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              Text('+25 XP  +10 pieces${hasBonus ? '  +50 bonus' : ''}', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      _RewardLine(label: 'Niveau actuel', value: '${player.level}'),
                      _RewardLine(label: 'Serie', value: '${player.streak}'),
                      _RewardLine(label: 'Pieces', value: '${player.coins}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 26),
              RpgButton(
                label: "Retour a l'accueil",
                icon: Icons.home_rounded,
                onPressed: () {
                  ref.read(timerProvider.notifier).reset();
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RewardLine extends StatelessWidget {
  const _RewardLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}
