import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/player_provider.dart';
import '../widgets/player_card.dart';
import '../widgets/rpg_button.dart';
import 'pomodoro_screen.dart';
import 'shop_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  static const routeName = '/';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('FocusBuddy'),
        actions: [
          IconButton(
            tooltip: 'Statistiques',
            icon: const Icon(Icons.bar_chart_rounded),
            onPressed: () => Navigator.pushNamed(context, StatsScreen.routeName),
          ),
          IconButton(
            tooltip: 'Boutique',
            icon: const Icon(Icons.storefront_rounded),
            onPressed: () => Navigator.pushNamed(context, ShopScreen.routeName),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            PlayerCard(player: player),
            const SizedBox(height: 24),
            RpgButton(
              label: 'Commencer une session',
              icon: Icons.play_arrow_rounded,
              onPressed: () => Navigator.pushNamed(context, PomodoroScreen.routeName),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _QuickCard(
                    icon: Icons.timer,
                    value: '${player.totalFocusMinutes} min',
                    label: 'focus total',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _QuickCard(
                    icon: Icons.check_circle,
                    value: '${player.completedSessions}',
                    label: 'sessions',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickCard extends StatelessWidget {
  const _QuickCard({required this.icon, required this.value, required this.label});

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 10),
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
