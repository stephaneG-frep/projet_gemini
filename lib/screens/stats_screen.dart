import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/player_provider.dart';

class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key});

  static const routeName = '/stats';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistiques')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _StatTile(icon: Icons.schedule, label: 'Temps total de concentration', value: '${player.totalFocusMinutes} min'),
            _StatTile(icon: Icons.check_circle, label: 'Sessions reussies', value: '${player.completedSessions}'),
            _StatTile(icon: Icons.cancel, label: 'Sessions echouees', value: '${player.failedSessions}'),
            _StatTile(icon: Icons.local_fire_department, label: 'Meilleure serie', value: '${player.bestStreak}'),
            _StatTile(icon: Icons.military_tech, label: 'Niveau actuel', value: '${player.level}'),
            _StatTile(icon: Icons.toll, label: 'Pieces gagnees', value: '${player.totalCoinsEarned}'),
          ],
        ),
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        minVerticalPadding: 18,
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFF2F6FF),
          child: Icon(icon, color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(label),
        trailing: Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
      ),
    );
  }
}
