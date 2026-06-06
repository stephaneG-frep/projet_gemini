import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/kingdom_building.dart';
import '../providers/kingdom_provider.dart';
import '../providers/player_provider.dart';

class KingdomScreen extends ConsumerWidget {
  const KingdomScreen({super.key});

  static const routeName = '/kingdom';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);
    final buildings = ref.watch(kingdomProvider);
    final bonus = ref.watch(kingdomBonusProvider);
    final builtCount = buildings.where((building) => building.isBuilt).length;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text('Royaume')),
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
                'Batis ton royaume du focus',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 8),
              Text(
                'Chaque session finance un lieu qui rend tes prochaines quetes plus fortes.',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 18),
              _KingdomSummary(
                coins: player.coins,
                level: player.level,
                builtCount: builtCount,
                totalCount: buildings.length,
                bonus: bonus,
              ),
              const SizedBox(height: 16),
              _KingdomMap(buildings: buildings),
              const SizedBox(height: 18),
              Text('Chantiers', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 10),
              ...buildings.map((building) => _BuildingCard(building: building)),
            ],
          ),
        ),
      ),
    );
  }
}

class _KingdomSummary extends StatelessWidget {
  const _KingdomSummary({
    required this.coins,
    required this.level,
    required this.builtCount,
    required this.totalCount,
    required this.bonus,
  });

  final int coins;
  final int level;
  final int builtCount;
  final int totalCount;
  final KingdomBonus bonus;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            _SummaryPill(icon: Icons.toll_rounded, label: '$coins pieces'),
            _SummaryPill(icon: Icons.military_tech_rounded, label: 'Niveau $level'),
            _SummaryPill(icon: Icons.account_balance_rounded, label: '$builtCount/$totalCount batiments'),
            _SummaryPill(icon: Icons.auto_awesome_rounded, label: '+${bonus.xp} XP  +${bonus.coins} pieces'),
          ],
        ),
      ),
    );
  }
}

class _KingdomMap extends StatelessWidget {
  const _KingdomMap({required this.buildings});

  final List<KingdomBuilding> buildings;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 260,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final positions = [
                const Offset(0.13, 0.68),
                const Offset(0.34, 0.58),
                const Offset(0.62, 0.50),
                const Offset(0.82, 0.66),
                const Offset(0.22, 0.33),
                const Offset(0.52, 0.28),
                const Offset(0.76, 0.24),
              ];

              return Stack(
                children: [
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: isDark
                              ? const [Color(0xFF182A49), Color(0xFF203B5C), Color(0xFF182235)]
                              : const [Color(0xFFBFE8FF), Color(0xFFEAF8D8), Color(0xFFFFF0C6)],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: -40,
                    right: -40,
                    bottom: -36,
                    child: Container(
                      height: 132,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF274267) : const Color(0xFFCBEFA8),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(100)),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 30,
                    right: 24,
                    bottom: 70,
                    child: Container(
                      height: 20,
                      decoration: BoxDecoration(
                        color: (isDark ? const Color(0xFFFFC47D) : const Color(0xFFD8A85F)).withValues(alpha: 0.45),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 0,
                    top: 18,
                    right: 0,
                    child: Center(
                      child: Text(
                        'Vue du royaume',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
                      ),
                    ),
                  ),
                  for (var index = 0; index < buildings.length; index++)
                    Positioned(
                      left: constraints.maxWidth * positions[index].dx - 31,
                      top: constraints.maxHeight * positions[index].dy - 31,
                      child: _SceneBuilding(building: buildings[index]),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SceneBuilding extends StatelessWidget {
  const _SceneBuilding({required this.building});

  final KingdomBuilding building;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeColor = isDark ? const Color(0xFF243552) : Colors.white;
    final lockedColor = isDark ? const Color(0xFF182235) : const Color(0xFFF7F3EA);

    return Tooltip(
      message: building.name,
      child: SizedBox.square(
        dimension: 62,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: building.isBuilt ? activeColor : lockedColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: building.isBuilt ? Theme.of(context).colorScheme.secondary : Theme.of(context).disabledColor,
              width: building.isBuilt ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.12),
                blurRadius: 12,
                offset: const Offset(0, 7),
              ),
            ],
          ),
          child: Icon(
            building.isBuilt ? building.icon : Icons.lock_rounded,
            color: building.isBuilt ? Theme.of(context).colorScheme.primary : Theme.of(context).disabledColor,
            size: 30,
          ),
        ),
      ),
    );
  }
}

class _BuildingCard extends ConsumerWidget {
  const _BuildingCard({required this.building});

  final KingdomBuilding building;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);
    final canBuild = !building.isBuilt && player.level >= building.requiredLevel && player.coins >= building.cost;
    final lockedByLevel = player.level < building.requiredLevel;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: building.isBuilt
                      ? Theme.of(context).colorScheme.tertiaryContainer
                      : Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(building.isBuilt ? building.icon : Icons.lock_open_rounded),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(building.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      Text(building.description),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _SummaryPill(icon: Icons.toll_rounded, label: building.cost == 0 ? 'Gratuit' : '${building.cost} pieces'),
                _SummaryPill(icon: Icons.military_tech_rounded, label: 'Niv. ${building.requiredLevel}'),
                if (building.hasBonus) _SummaryPill(icon: Icons.auto_awesome_rounded, label: building.bonusLabel),
                if (building.isBuilt) const _SummaryPill(icon: Icons.check_circle_rounded, label: 'Construit'),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonalIcon(
                onPressed: canBuild
                    ? () async {
                        final result = await ref.read(kingdomProvider.notifier).buildBuilding(building.id);
                        if (!context.mounted) {
                          return;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(_messageFor(result, building.name))),
                        );
                      }
                    : null,
                icon: Icon(building.isBuilt ? Icons.check_rounded : lockedByLevel ? Icons.lock_rounded : Icons.construction_rounded),
                label: Text(building.isBuilt ? 'Fait' : 'Construire'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _messageFor(BuildResult result, String name) {
    return switch (result) {
      BuildResult.built => '$name construit !',
      BuildResult.alreadyBuilt => '$name est deja construit.',
      BuildResult.levelTooLow => 'Niveau trop bas pour ce chantier.',
      BuildResult.notEnoughCoins => 'Pas assez de pieces.',
      BuildResult.notFound => 'Batiment introuvable.',
    };
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 210),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF243552) : const Color(0xFFF2F6FF),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
