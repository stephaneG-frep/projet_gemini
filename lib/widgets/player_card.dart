import 'package:flutter/material.dart';

import '../models/player.dart';
import '../models/shop_item.dart';
import 'animated_buddy.dart';
import 'hp_bar.dart';
import 'reward_chip.dart';
import 'xp_bar.dart';

class PlayerCard extends StatelessWidget {
  const PlayerCard({super.key, required this.player, this.equippedItem});

  final Player player;
  final ShopItem? equippedItem;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? const Color(0xFF314971) : Colors.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : const Color(0xFF3E5E9E)).withValues(
              alpha: isDark ? 0.24 : 0.10,
            ),
            blurRadius: 28,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(26),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              AnimatedBuddy(equippedItem: equippedItem),
              const SizedBox(height: 16),
              Text(
                'Aventurier du focus',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(
                equippedItem == null
                    ? 'Niveau ${player.level}'
                    : 'Niveau ${player.level} - ${equippedItem!.name}',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              XpBar(xp: player.xp, xpToNextLevel: player.xpToNextLevel),
              const SizedBox(height: 14),
              HpBar(hp: player.hp, maxHp: player.maxHp),
              const SizedBox(height: 18),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  RewardChip.coins(
                    label: '${player.coins} pieces',
                    compact: true,
                  ),
                  _Pill(
                    icon: Icons.local_fire_department,
                    label: 'Serie ${player.streak}',
                  ),
                  _Pill(
                    icon: Icons.emoji_events,
                    label: 'Record ${player.bestStreak}',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF243552) : const Color(0xFFF2F6FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 6),
            Text(label, style: Theme.of(context).textTheme.labelLarge),
          ],
        ),
      ),
    );
  }
}
