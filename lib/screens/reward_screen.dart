import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/kingdom_provider.dart';
import '../providers/player_provider.dart';
import '../providers/shop_provider.dart';
import '../providers/timer_provider.dart';
import '../widgets/animated_buddy.dart';
import '../widgets/reward_chip.dart';
import '../widgets/rpg_button.dart';

class RewardScreen extends ConsumerWidget {
  const RewardScreen({super.key});

  static const routeName = '/reward';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);
    final hasBonus =
        player.completedSessions > 0 && player.completedSessions % 4 == 0;
    final kingdomBonus = ref.watch(kingdomBonusProvider);
    final equippedItems = ref
        .watch(shopProvider)
        .where((item) => item.isEquipped);
    final equippedItem = equippedItems.isEmpty ? null : equippedItems.first;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? const [
                      Color(0xFF1B2740),
                      Color(0xFF101A2B),
                      Color(0xFF0F1624),
                    ]
                  : const [Color(0xFFFFF1C9), Color(0xFFEAF3FF)],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedBuddy(equippedItem: equippedItem, size: 170),
                const SizedBox(height: 18),
                Text(
                  'Quete reussie !',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    RewardChip.xp(label: '+${25 + kingdomBonus.xp} XP'),
                    RewardChip.coins(
                      label: '+${10 + kingdomBonus.coins} pieces',
                    ),
                    if (hasBonus) const RewardChip.bonus(label: '+50 serie'),
                  ],
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        _RewardLine(
                          label: 'Niveau actuel',
                          value: '${player.level}',
                        ),
                        _RewardLine(label: 'Serie', value: '${player.streak}'),
                        _RewardLine(label: 'Pieces', value: '${player.coins}'),
                        if (kingdomBonus.xp > 0 || kingdomBonus.coins > 0) ...[
                          const SizedBox(height: 8),
                          const _RewardHeader(label: 'Bonus royaume'),
                          const SizedBox(height: 8),
                          RewardChipGroup(
                            xp: kingdomBonus.xp,
                            coins: kingdomBonus.coins,
                            compact: true,
                          ),
                        ],
                        if (equippedItem != null)
                          _RewardLine(
                            label: 'Objet equipe',
                            value: equippedItem.name,
                          ),
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

class _RewardHeader extends StatelessWidget {
  const _RewardHeader({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
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
