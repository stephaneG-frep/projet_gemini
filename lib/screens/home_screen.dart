import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/kingdom_building.dart';
import '../providers/player_provider.dart';
import '../providers/kingdom_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/shop_provider.dart';
import '../widgets/player_card.dart';
import '../widgets/rpg_button.dart';
import 'guide_screen.dart';
import 'kingdom_screen.dart';
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
    final kingdom = ref.watch(kingdomProvider);
    final pendingBuildings = kingdom.where((building) => !building.isBuilt).toList(growable: false);
    final equippedItems = ref.watch(shopProvider).where((item) => item.isEquipped);
    final equippedItem = equippedItems.isEmpty ? null : equippedItems.first;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('FocusBuddy'),
        actions: [
          IconButton(
            tooltip: "Mode d'emploi",
            icon: const Icon(Icons.help_outline_rounded),
            onPressed: () => Navigator.pushNamed(context, GuideScreen.routeName),
          ),
          IconButton(
            tooltip: 'Royaume',
            icon: const Icon(Icons.castle_rounded),
            onPressed: () => Navigator.pushNamed(context, KingdomScreen.routeName),
          ),
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
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? const [Color(0xFF101A2B), Color(0xFF16253C), Color(0xFF0F1624)]
                  : const [Color(0xFFF4F8FF), Color(0xFFFFF7EA), Color(0xFFF8F2E8)],
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
              const SizedBox(height: 18),
              _KingdomPreview(
                builtCount: kingdom.where((building) => building.isBuilt).length,
                totalCount: kingdom.length,
                nextBuilding: pendingBuildings.isEmpty ? null : pendingBuildings.first,
              ),
              const SizedBox(height: 20),
              RpgButton(
                label: settings.devModeEnabled ? 'Session test ${settings.devTimerSeconds}s' : 'Commencer une session',
                icon: Icons.play_arrow_rounded,
                onPressed: () => Navigator.pushNamed(context, PomodoroScreen.routeName),
              ),
              const SizedBox(height: 14),
              _OptionsPanel(
                devSeconds: settings.devTimerSeconds,
                devEnabled: settings.devModeEnabled,
                darkEnabled: settings.darkModeEnabled,
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
      ),
    );
  }
}

class _KingdomPreview extends StatelessWidget {
  const _KingdomPreview({
    required this.builtCount,
    required this.totalCount,
    required this.nextBuilding,
  });

  final int builtCount;
  final int totalCount;
  final KingdomBuilding? nextBuilding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final upcoming = nextBuilding;

    return Material(
      color: isDark ? const Color(0xFF182235) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () => Navigator.pushNamed(context, KingdomScreen.routeName),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.castle_rounded, color: Theme.of(context).colorScheme.secondary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Mon royaume',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                    ),
                  ),
                  FilledButton.tonalIcon(
                    onPressed: () => Navigator.pushNamed(context, KingdomScreen.routeName),
                    icon: const Icon(Icons.visibility_rounded),
                    label: const Text('Voir'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 118,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: Image.asset(
                                'assets/images/kingdom_background.png',
                                fit: BoxFit.cover,
                                filterQuality: FilterQuality.high,
                              ),
                            ),
                            if (isDark)
                              Positioned.fill(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF0F1624).withValues(alpha: 0.22),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 14,
                      bottom: 18,
                      child: _TinyKingdomIcon(icon: Icons.cottage_rounded, active: builtCount >= 1),
                    ),
                    Positioned(
                      left: 76,
                      bottom: 32,
                      child: _TinyKingdomIcon(icon: Icons.desktop_windows_rounded, active: builtCount >= 2),
                    ),
                    Positioned(
                      right: 78,
                      bottom: 30,
                      child: _TinyKingdomIcon(icon: Icons.local_library_rounded, active: builtCount >= 3),
                    ),
                    Positioned(
                      right: 18,
                      bottom: 42,
                      child: _TinyKingdomIcon(icon: Icons.castle_rounded, active: builtCount >= totalCount),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                upcoming == null
                    ? 'Royaume complet pour cette premiere version.'
                    : '$builtCount/$totalCount batiments construits - prochain chantier : ${upcoming.name}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TinyKingdomIcon extends StatelessWidget {
  const _TinyKingdomIcon({required this.icon, required this.active});

  final IconData icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: active ? Theme.of(context).colorScheme.surface : Theme.of(context).disabledColor.withValues(alpha: 0.20),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Icon(
          active ? icon : Icons.lock_rounded,
          color: active ? Theme.of(context).colorScheme.primary : Theme.of(context).disabledColor,
          size: 24,
        ),
      ),
    );
  }
}

class _OptionsPanel extends ConsumerWidget {
  const _OptionsPanel({
    required this.devSeconds,
    required this.devEnabled,
    required this.darkEnabled,
  });

  final int devSeconds;
  final bool devEnabled;
  final bool darkEnabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? const Color(0xFF182235) : const Color(0xFFFFFAF0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isDark ? const Color(0xFF314971) : const Color(0xFFFFD79A)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.dark_mode_rounded),
              title: const Text('Theme sombre'),
              subtitle: const Text('Une ambiance nuit plus calme pour les sessions du soir.'),
              value: darkEnabled,
              onChanged: ref.read(settingsProvider.notifier).setDarkMode,
            ),
            const Divider(),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: const Icon(Icons.speed_rounded),
              title: const Text('Mode dev'),
              subtitle: Text(devEnabled ? 'Sessions rapides pour tester les recompenses.' : 'Pomodoro classique de 25 minutes.'),
              value: devEnabled,
              onChanged: ref.read(settingsProvider.notifier).setDevMode,
            ),
            if (devEnabled) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.speed_rounded, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Slider(
                      value: devSeconds.toDouble(),
                      min: 5,
                      max: 60,
                      divisions: 11,
                      label: '${devSeconds}s',
                      onChanged: (value) {
                        ref.read(settingsProvider.notifier).setDevTimerSeconds(value.round());
                      },
                    ),
                  ),
                  SizedBox(
                    width: 44,
                    child: Text('${devSeconds}s', textAlign: TextAlign.end),
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
