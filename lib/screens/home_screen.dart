import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/player_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/shop_provider.dart';
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
    final settings = ref.watch(settingsProvider);
    final equippedItems = ref.watch(shopProvider).where((item) => item.isEquipped);
    final equippedItem = equippedItems.isEmpty ? null : equippedItems.first;

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
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFF4F8FF), Color(0xFFFFF7EA), Color(0xFFF8F2E8)],
            ),
          ),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Pret pour une quete de 25 minutes ?',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 6),
              Text(
                "Garde le cap, gagne de l'XP, equipe ton heros.",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 18),
              PlayerCard(player: player, equippedItem: equippedItem),
              const SizedBox(height: 20),
              RpgButton(
                label: settings.devModeEnabled ? 'Session test ${settings.devTimerSeconds}s' : 'Commencer une session',
                icon: Icons.play_arrow_rounded,
                onPressed: () => Navigator.pushNamed(context, PomodoroScreen.routeName),
              ),
              const SizedBox(height: 14),
              _DevModePanel(settingsSeconds: settings.devTimerSeconds, enabled: settings.devModeEnabled),
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
      ),
    );
  }
}

class _DevModePanel extends ConsumerWidget {
  const _DevModePanel({required this.settingsSeconds, required this.enabled});

  final int settingsSeconds;
  final bool enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: const Color(0xFFFFFAF0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFFFD79A)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Mode dev'),
              subtitle: Text(enabled ? 'Sessions rapides pour tester les recompenses.' : 'Pomodoro classique de 25 minutes.'),
              value: enabled,
              onChanged: ref.read(settingsProvider.notifier).setDevMode,
            ),
            if (enabled) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.speed_rounded, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Slider(
                      value: settingsSeconds.toDouble(),
                      min: 5,
                      max: 60,
                      divisions: 11,
                      label: '${settingsSeconds}s',
                      onChanged: (value) {
                        ref.read(settingsProvider.notifier).setDevTimerSeconds(value.round());
                      },
                    ),
                  ),
                  SizedBox(
                    width: 44,
                    child: Text('${settingsSeconds}s', textAlign: TextAlign.end),
                  ),
                ],
              ),
            ],
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
