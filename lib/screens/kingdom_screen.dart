import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/kingdom_building.dart';
import '../providers/kingdom_goal_provider.dart';
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
    final goals = ref.watch(kingdomGoalProgressProvider);
    final builtCount = buildings.where((building) => building.isBuilt).length;
    final kingdomLevel = buildings.fold(0, (total, building) => total + building.level);
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
                kingdomLevel: kingdomLevel,
                bonus: bonus,
              ),
              const SizedBox(height: 16),
              _KingdomMap(buildings: buildings),
              const SizedBox(height: 18),
              _KingdomGoals(progressItems: goals),
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

class _KingdomGoals extends StatelessWidget {
  const _KingdomGoals({required this.progressItems});

  final List<KingdomGoalProgress> progressItems;

  @override
  Widget build(BuildContext context) {
    final activeGoals = [
      ...progressItems.where((item) => item.canClaim),
      ...progressItems.where((item) => !item.canClaim && !item.goal.isClaimed),
      ...progressItems.where((item) => item.goal.isClaimed),
    ].take(4).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Objectifs du royaume', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900)),
        const SizedBox(height: 10),
        ...activeGoals.map((item) => _GoalCard(progress: item)),
      ],
    );
  }
}

class _GoalCard extends ConsumerWidget {
  const _GoalCard({required this.progress});

  final KingdomGoalProgress progress;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goal = progress.goal;

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
                  backgroundColor: progress.canClaim
                      ? Theme.of(context).colorScheme.secondaryContainer
                      : Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(progress.canClaim ? Icons.card_giftcard_rounded : goal.icon),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(goal.title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900)),
                      const SizedBox(height: 4),
                      Text(goal.description),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: progress.percent,
                minHeight: 10,
                backgroundColor: Theme.of(context).dividerColor.withValues(alpha: 0.28),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _SummaryPill(icon: Icons.flag_rounded, label: '${progress.cappedCurrent}/${goal.target}'),
                _SummaryPill(icon: Icons.card_giftcard_rounded, label: goal.rewardLabel),
                if (goal.isClaimed) const _SummaryPill(icon: Icons.check_circle_rounded, label: 'Reclame'),
              ],
            ),
            if (!goal.isClaimed) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.tonalIcon(
                  onPressed: progress.canClaim
                      ? () async {
                          final result = await ref.read(kingdomGoalProvider.notifier).claim(goal.id);
                          if (!context.mounted) {
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(_claimMessage(result, goal.rewardLabel))),
                          );
                        }
                      : null,
                  icon: Icon(progress.canClaim ? Icons.redeem_rounded : Icons.hourglass_bottom_rounded),
                  label: Text(progress.canClaim ? 'Reclamer' : 'En cours'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _claimMessage(ClaimGoalResult result, String reward) {
    return switch (result) {
      ClaimGoalResult.claimed => 'Objectif valide : $reward !',
      ClaimGoalResult.alreadyClaimed => 'Objectif deja reclame.',
      ClaimGoalResult.notComplete => 'Objectif pas encore termine.',
      ClaimGoalResult.notFound => 'Objectif introuvable.',
    };
  }
}

class _KingdomSummary extends StatelessWidget {
  const _KingdomSummary({
    required this.coins,
    required this.level,
    required this.builtCount,
    required this.totalCount,
    required this.kingdomLevel,
    required this.bonus,
  });

  final int coins;
  final int level;
  final int builtCount;
  final int totalCount;
  final int kingdomLevel;
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
            _SummaryPill(icon: Icons.castle_rounded, label: 'Royaume niv. $kingdomLevel'),
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
          height: 300,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final positions = [
                const Offset(0.27, 0.39),
                const Offset(0.20, 0.60),
                const Offset(0.43, 0.72),
                const Offset(0.62, 0.39),
                const Offset(0.79, 0.72),
                const Offset(0.84, 0.53),
                const Offset(0.67, 0.19),
              ];

              return Stack(
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
                  Positioned(
                    left: 12,
                    top: 12,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.90),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.castle_rounded, size: 16, color: Theme.of(context).colorScheme.primary),
                            const SizedBox(width: 6),
                            Text(
                              'Royaume du focus',
                              style: Theme.of(context).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  for (var index = 0; index < buildings.length; index++)
                    Positioned(
                      left: constraints.maxWidth * positions[index].dx - 28,
                      top: constraints.maxHeight * positions[index].dy - 28,
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
    final activeColor = isDark ? const Color(0xFF182235) : Colors.white;
    final lockedColor = isDark ? const Color(0xFF182235) : const Color(0xFFFFFBF3);

    return Tooltip(
      message: building.name,
      child: SizedBox.square(
        dimension: 56,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: building.isBuilt ? activeColor : lockedColor,
                  borderRadius: BorderRadius.circular(999),
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
                  size: 28,
                ),
              ),
            ),
            if (building.isBuilt)
              Positioned(
                right: -2,
                top: -2,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    child: Text(
                      '${building.level}',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: Colors.black,
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ),
                ),
              ),
          ],
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
    final canUpgrade = building.canUpgrade && player.coins >= building.upgradeCost;
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
                if (building.isBuilt) _SummaryPill(icon: Icons.castle_rounded, label: 'Batiment niv. ${building.level}/${building.maxLevel}'),
                if (building.hasBonus && building.isBuilt) _SummaryPill(icon: Icons.auto_awesome_rounded, label: building.bonusLabel),
                if (building.hasBonus && building.canUpgrade) _SummaryPill(icon: Icons.trending_up_rounded, label: 'Prochain: ${building.nextBonusLabel}'),
                if (building.isBuilt && building.canUpgrade) _SummaryPill(icon: Icons.upgrade_rounded, label: 'Ameliorer: ${building.upgradeCost} pieces'),
                if (building.isBuilt && !building.canUpgrade) const _SummaryPill(icon: Icons.verified_rounded, label: 'Niveau max'),
              ],
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Wrap(
                alignment: WrapAlignment.end,
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (!building.isBuilt)
                    FilledButton.tonalIcon(
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
                      icon: Icon(lockedByLevel ? Icons.lock_rounded : Icons.construction_rounded),
                      label: const Text('Construire'),
                    )
                  else
                    FilledButton.tonalIcon(
                      onPressed: canUpgrade
                          ? () async {
                              final result = await ref.read(kingdomProvider.notifier).upgradeBuilding(building.id);
                              if (!context.mounted) {
                                return;
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(_messageFor(result, building.name))),
                              );
                            }
                          : null,
                      icon: Icon(building.canUpgrade ? Icons.upgrade_rounded : Icons.verified_rounded),
                      label: Text(building.canUpgrade ? 'Ameliorer' : 'Max'),
                    ),
                ],
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
      BuildResult.upgraded => '$name ameliore !',
      BuildResult.alreadyBuilt => '$name est deja construit.',
      BuildResult.notBuilt => 'Construis d abord ce batiment.',
      BuildResult.maxLevel => '$name est deja au niveau maximum.',
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
