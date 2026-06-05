import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/player_provider.dart';
import '../providers/shop_provider.dart';
import '../providers/timer_provider.dart';
import '../widgets/animated_buddy.dart';
import '../widgets/rpg_button.dart';

class RewardScreen extends ConsumerWidget {
  const RewardScreen({super.key});

  static const routeName = '/reward';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);
    final hasBonus = player.completedSessions > 0 && player.completedSessions % 4 == 0;
    final equippedItems = ref.watch(shopProvider).where((item) => item.isEquipped);
    final equippedItem = equippedItems.isEmpty ? null : equippedItems.first;

    return Scaffold(
      body: SafeArea(
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFFF1C9), Color(0xFFEAF3FF)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuddy(equippedItem: equippedItem, size: 170),
                const SizedBox(height: 18),
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
                        if (equippedItem != null) _RewardLine(label: 'Objet equipe', value: equippedItem.name),
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
