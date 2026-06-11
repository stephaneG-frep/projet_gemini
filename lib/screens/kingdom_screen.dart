import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/kingdom_building.dart';
import '../providers/kingdom_goal_provider.dart';
import '../providers/kingdom_provider.dart';
import '../providers/player_provider.dart';
import '../widgets/reward_chip.dart';

class KingdomScreen extends ConsumerWidget {
  const KingdomScreen({super.key});

  static const routeName = '/kingdom';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);
    final buildings = ref.watch(kingdomProvider);
    final bonus = ref.watch(kingdomBonusProvider);
    final strategy = ref.watch(kingdomStrategyProvider);
    final goals = ref.watch(kingdomGoalProgressProvider);
    final builtCount = buildings.where((building) => building.isBuilt).length;
    final kingdomLevel = buildings.fold(
      0,
      (total, building) => total + building.level,
    );
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
                  ? const [
                      Color(0xFF101A2B),
                      Color(0xFF16253C),
                      Color(0xFF0F1624),
                    ]
                  : const [
                      Color(0xFFF4F8FF),
                      Color(0xFFFFF7EA),
                      Color(0xFFF8F2E8),
                    ],
            ),
          ),
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                'Batis ton royaume du focus',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
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
              _KingdomDistricts(
                builtCount: builtCount,
                kingdomLevel: kingdomLevel,
              ),
              const SizedBox(height: 18),
              _SpecialBonusPanel(bonus: bonus),
              const SizedBox(height: 18),
              _StrategyPanel(selected: strategy),
              const SizedBox(height: 18),
              _LongMissions(progressItems: goals),
              const SizedBox(height: 18),
              _KingdomGoals(progressItems: goals),
              const SizedBox(height: 18),
              Text(
                'Chantiers',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
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
      ...progressItems.where(
        (item) => item.canClaim && !item.goal.id.startsWith('mission_'),
      ),
      ...progressItems.where(
        (item) =>
            !item.canClaim &&
            !item.goal.isClaimed &&
            !item.goal.id.startsWith('mission_'),
      ),
      ...progressItems.where(
        (item) => item.goal.isClaimed && !item.goal.id.startsWith('mission_'),
      ),
    ].take(4).toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Objectifs du royaume',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        ...activeGoals.map((item) => _GoalCard(progress: item)),
      ],
    );
  }
}

class _LongMissions extends StatelessWidget {
  const _LongMissions({required this.progressItems});

  final List<KingdomGoalProgress> progressItems;

  @override
  Widget build(BuildContext context) {
    final missions = [
      ...progressItems.where(
        (item) => item.goal.id.startsWith('mission_') && item.canClaim,
      ),
      ...progressItems.where(
        (item) =>
            item.goal.id.startsWith('mission_') &&
            !item.canClaim &&
            !item.goal.isClaimed,
      ),
      ...progressItems.where(
        (item) => item.goal.id.startsWith('mission_') && item.goal.isClaimed,
      ),
    ].take(3).toList(growable: false);

    if (missions.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Missions longues',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        Text(
          'Des objectifs plus grands pour donner une direction a ton royaume.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 10),
        ...missions.map((item) => _GoalCard(progress: item)),
      ],
    );
  }
}

class _SpecialBonusPanel extends StatelessWidget {
  const _SpecialBonusPanel({required this.bonus});

  final KingdomBonus bonus;

  @override
  Widget build(BuildContext context) {
    final items = [
      _BonusInfo(
        icon: Icons.auto_awesome_rounded,
        title: 'Savoir',
        value: '+${bonus.xp} XP/session',
        isActive: bonus.xp > 0,
      ),
      _BonusInfo(
        icon: Icons.paid_rounded,
        title: 'Economie',
        value: '+${bonus.coins} pieces/session',
        isActive: bonus.coins > 0,
      ),
      _BonusInfo(
        icon: Icons.favorite_rounded,
        title: 'Recuperation',
        value: '+${bonus.hpRecovery} HP/session',
        isActive: bonus.hpRecovery > 0,
      ),
      _BonusInfo(
        icon: Icons.local_fire_department_rounded,
        title: 'Elan de serie',
        value: '+${bonus.streakCoins} pieces toutes les 3 series',
        isActive: bonus.streakCoins > 0,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pouvoirs du royaume',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        GridView.builder(
          itemCount: items.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.62,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) => _BonusTile(info: items[index]),
        ),
      ],
    );
  }
}

class _BonusInfo {
  const _BonusInfo({
    required this.icon,
    required this.title,
    required this.value,
    required this.isActive,
  });

  final IconData icon;
  final String title;
  final String value;
  final bool isActive;
}

class _BonusTile extends StatelessWidget {
  const _BonusTile({required this.info});

  final _BonusInfo info;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: info.isActive
            ? Theme.of(context).colorScheme.surface
            : (isDark ? const Color(0xFF172033) : const Color(0xFFF3F5FA)),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: info.isActive
              ? Theme.of(context).colorScheme.secondary.withValues(alpha: 0.45)
              : Theme.of(context).dividerColor.withValues(alpha: 0.35),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              info.isActive ? info.icon : Icons.lock_rounded,
              color: info.isActive
                  ? Theme.of(context).colorScheme.secondary
                  : Theme.of(context).disabledColor,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    info.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    info.isActive ? info.value : 'A debloquer',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _KingdomDistricts extends StatelessWidget {
  const _KingdomDistricts({
    required this.builtCount,
    required this.kingdomLevel,
  });

  final int builtCount;
  final int kingdomLevel;

  @override
  Widget build(BuildContext context) {
    final districts = [
      _DistrictInfo(
        name: 'Campement',
        description: 'Le point de depart de ton royaume.',
        icon: Icons.cottage_rounded,
        unlocked: builtCount >= 1,
        progress: builtCount.clamp(0, 1) / 1,
      ),
      _DistrictInfo(
        name: 'Village',
        description: 'Un vrai lieu commence a exister.',
        icon: Icons.holiday_village_rounded,
        unlocked: builtCount >= 3,
        progress: builtCount.clamp(0, 3) / 3,
      ),
      _DistrictInfo(
        name: 'Quartier du savoir',
        description: 'Les batiments avances donnent une direction.',
        icon: Icons.local_library_rounded,
        unlocked: kingdomLevel >= 6,
        progress: kingdomLevel.clamp(0, 6) / 6,
      ),
      _DistrictInfo(
        name: 'Cite royale',
        description: 'Le royaume devient un objectif long terme.',
        icon: Icons.castle_rounded,
        unlocked: kingdomLevel >= 12,
        progress: kingdomLevel.clamp(0, 12) / 12,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quartiers',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 142,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: districts.length,
            separatorBuilder: (_, _) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              return _DistrictCard(info: districts[index]);
            },
          ),
        ),
      ],
    );
  }
}

class _DistrictInfo {
  const _DistrictInfo({
    required this.name,
    required this.description,
    required this.icon,
    required this.unlocked,
    required this.progress,
  });

  final String name;
  final String description;
  final IconData icon;
  final bool unlocked;
  final double progress;
}

class _DistrictCard extends StatelessWidget {
  const _DistrictCard({required this.info});

  final _DistrictInfo info;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: 210,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: info.unlocked
              ? Theme.of(context).colorScheme.surface
              : (isDark ? const Color(0xFF172033) : const Color(0xFFF3F5FA)),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: info.unlocked
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.35)
                : Theme.of(context).dividerColor.withValues(alpha: 0.35),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    info.unlocked ? info.icon : Icons.lock_rounded,
                    color: info.unlocked
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).disabledColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      info.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                info.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const Spacer(),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(
                  value: info.progress.clamp(0, 1),
                  minHeight: 7,
                  backgroundColor: Theme.of(
                    context,
                  ).dividerColor.withValues(alpha: 0.22),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StrategyPanel extends ConsumerWidget {
  const _StrategyPanel({required this.selected});

  final KingdomStrategy selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Strategie du royaume',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 6),
        Text(
          'Choisis la priorite active pour tes prochaines sessions.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 10),
        ...KingdomStrategy.values.map(
          (strategy) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _StrategyCard(
              strategy: strategy,
              selected: strategy == selected,
              onTap: () {
                ref
                    .read(kingdomStrategyProvider.notifier)
                    .setStrategy(strategy);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _StrategyCard extends StatelessWidget {
  const _StrategyCard({
    required this.strategy,
    required this.selected,
    required this.onTap,
  });

  final KingdomStrategy strategy;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: selected
          ? Theme.of(context).colorScheme.secondaryContainer
          : (isDark ? const Color(0xFF172033) : Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: selected
              ? Theme.of(context).colorScheme.secondary
              : Theme.of(context).dividerColor.withValues(alpha: 0.35),
          width: selected ? 2 : 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox.square(
                dimension: 42,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: selected
                        ? Theme.of(context).colorScheme.onSecondaryContainer
                              .withValues(alpha: 0.10)
                        : Theme.of(
                            context,
                          ).colorScheme.primaryContainer.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    strategy.icon,
                    color: selected
                        ? Theme.of(context).colorScheme.onSecondaryContainer
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strategy.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      strategy.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        if (strategy.bonusXp > 0)
                          RewardChip.xp(
                            label: '+${strategy.bonusXp} XP',
                            compact: true,
                          ),
                        if (strategy.bonusCoins > 0)
                          RewardChip.coins(
                            label: '+${strategy.bonusCoins} pieces',
                            compact: true,
                          ),
                        if (strategy.bonusHpRecovery > 0)
                          _SummaryPill(
                            icon: Icons.favorite_rounded,
                            label: '+${strategy.bonusHpRecovery} HP',
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              if (selected) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.check_circle_rounded,
                  color: Theme.of(context).colorScheme.secondary,
                ),
              ],
            ],
          ),
        ),
      ),
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
                  child: Icon(
                    progress.canClaim ? Icons.card_giftcard_rounded : goal.icon,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w900),
                      ),
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
                backgroundColor: Theme.of(
                  context,
                ).dividerColor.withValues(alpha: 0.28),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _SummaryPill(
                  icon: Icons.flag_rounded,
                  label: '${progress.cappedCurrent}/${goal.target}',
                ),
                if (goal.rewardXp > 0)
                  RewardChip.xp(label: '+${goal.rewardXp} XP', compact: true),
                if (goal.rewardCoins > 0)
                  RewardChip.coins(
                    label: '+${goal.rewardCoins} pieces',
                    compact: true,
                  ),
                if (goal.isClaimed)
                  const _SummaryPill(
                    icon: Icons.check_circle_rounded,
                    label: 'Reclame',
                  ),
              ],
            ),
            if (!goal.isClaimed) ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.tonalIcon(
                  onPressed: progress.canClaim
                      ? () async {
                          final result = await ref
                              .read(kingdomGoalProvider.notifier)
                              .claim(goal.id);
                          if (!context.mounted) {
                            return;
                          }
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                _claimMessage(result, goal.rewardLabel),
                              ),
                            ),
                          );
                        }
                      : null,
                  icon: Icon(
                    progress.canClaim
                        ? Icons.redeem_rounded
                        : Icons.hourglass_bottom_rounded,
                  ),
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
            RewardChip.coins(label: '$coins pieces', compact: true),
            _SummaryPill(
              icon: Icons.military_tech_rounded,
              label: 'Niveau $level',
            ),
            _SummaryPill(
              icon: Icons.castle_rounded,
              label: 'Royaume niv. $kingdomLevel',
            ),
            _SummaryPill(
              icon: Icons.account_balance_rounded,
              label: '$builtCount/$totalCount batiments',
            ),
            if (bonus.xp > 0)
              RewardChip.xp(label: '+${bonus.xp} XP/session', compact: true),
            if (bonus.coins > 0)
              RewardChip.coins(
                label: '+${bonus.coins} pieces/session',
                compact: true,
              ),
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

    const positions = [
      Offset(0.27, 0.39),
      Offset(0.20, 0.60),
      Offset(0.43, 0.72),
      Offset(0.62, 0.39),
      Offset(0.79, 0.72),
      Offset(0.84, 0.53),
      Offset(0.67, 0.19),
    ];

    return Card(
      elevation: 0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 360,
          child: LayoutBuilder(
            builder: (context, constraints) {
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
                          color: const Color(
                            0xFF0F1624,
                          ).withValues(alpha: 0.22),
                        ),
                      ),
                    ),
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            (isDark ? const Color(0xFF0F1624) : Colors.white)
                                .withValues(alpha: isDark ? 0.26 : 0.12),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _KingdomRoadPainter(
                        points: positions,
                        dark: isDark,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    top: 12,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surface.withValues(alpha: 0.90),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 7,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.castle_rounded,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Royaume du focus',
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 16,
                    bottom: 16,
                    child: _MapLegend(
                      icon: Icons.account_tree_rounded,
                      label: 'Chemins du royaume',
                    ),
                  ),
                  for (var index = 0; index < buildings.length; index++)
                    Positioned(
                      left: constraints.maxWidth * positions[index].dx - 52,
                      top: constraints.maxHeight * positions[index].dy - 52,
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

class _MapLegend extends StatelessWidget {
  const _MapLegend({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.90),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 6),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

class _KingdomRoadPainter extends CustomPainter {
  const _KingdomRoadPainter({required this.points, required this.dark});

  final List<Offset> points;
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) {
      return;
    }

    final scaled = points
        .map((point) => Offset(point.dx * size.width, point.dy * size.height))
        .toList(growable: false);
    final road = Paint()
      ..color = (dark ? const Color(0xFFB8935F) : const Color(0xFFE4C28D))
          .withValues(alpha: dark ? 0.48 : 0.78)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 13;
    final highlight = Paint()
      ..color = (dark ? const Color(0xFFFFE1A8) : const Color(0xFFFFF1C8))
          .withValues(alpha: dark ? 0.36 : 0.82)
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 5;

    void drawCurve(Offset from, Offset to) {
      final control = Offset(
        (from.dx + to.dx) / 2,
        (from.dy + to.dy) / 2 - size.height * 0.06,
      );
      final path = Path()
        ..moveTo(from.dx, from.dy)
        ..quadraticBezierTo(control.dx, control.dy, to.dx, to.dy);
      canvas.drawPath(path, road);
      canvas.drawPath(path, highlight);
    }

    for (var index = 0; index < scaled.length - 1; index++) {
      drawCurve(scaled[index], scaled[index + 1]);
    }

    final plaza = Paint()
      ..color = (dark ? const Color(0xFF182235) : const Color(0xFFFFF8E7))
          .withValues(alpha: dark ? 0.72 : 0.86);
    for (final point in scaled) {
      canvas.drawCircle(point, 20, plaza);
      canvas.drawCircle(point, 20, road);
    }
  }

  @override
  bool shouldRepaint(covariant _KingdomRoadPainter oldDelegate) {
    return oldDelegate.points != points || oldDelegate.dark != dark;
  }
}

class _SceneBuilding extends StatelessWidget {
  const _SceneBuilding({required this.building});

  final KingdomBuilding building;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final built = building.isBuilt;
    final primary = built
        ? _buildingAccent(building.iconName, isDark)
        : (isDark ? const Color(0xFF6D7890) : const Color(0xFF9AA5B7));
    final surface = isDark ? const Color(0xFF182235) : Colors.white;
    final isMaxLevel = built && building.level >= building.maxLevel;
    final hasGlow = built && building.level >= 2;

    return Tooltip(
      message: building.name,
      child: SizedBox(
        width: 104,
        height: 104,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: 12,
              right: 12,
              bottom: 11,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: isDark ? 0.28 : 0.16),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: const SizedBox(height: 10),
              ),
            ),
            if (hasGlow)
              Positioned(
                left: 7,
                right: 7,
                top: 3,
                child: _LevelAura(color: primary, strong: isMaxLevel, size: 88),
              ),
            Positioned(
              left: 4,
              right: 4,
              top: 0,
              child: TweenAnimationBuilder<double>(
                key: ValueKey(
                  'map-${building.id}-${building.isBuilt}-${building.level}',
                ),
                tween: Tween(begin: built ? 1.16 : 1.0, end: 1),
                duration: const Duration(milliseconds: 520),
                curve: Curves.elasticOut,
                builder: (context, scale, child) {
                  return Transform.scale(scale: scale, child: child);
                },
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 240),
                  opacity: built ? 1 : 0.38,
                  child: Image.asset(
                    building.imageAsset,
                    height: 82,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                    errorBuilder: (context, error, stackTrace) {
                      return SizedBox.square(
                        dimension: 72,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: surface,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(color: primary),
                          ),
                          child: Icon(building.icon, color: primary),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            if (!built)
              Positioned(
                left: 34,
                top: 26,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: surface.withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).disabledColor.withValues(alpha: 0.32),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: Icon(
                      Icons.lock_rounded,
                      size: 18,
                      color: Theme.of(context).disabledColor,
                    ),
                  ),
                ),
              ),
            if (built)
              Positioned(
                right: 8,
                top: -3,
                child: _LevelBadge(
                  level: building.level,
                  isMaxLevel: isMaxLevel,
                ),
              ),
            if (isMaxLevel)
              Positioned(
                left: 10,
                top: 2,
                child: Icon(
                  Icons.workspace_premium_rounded,
                  size: 20,
                  color: Theme.of(context).colorScheme.secondary,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.32),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Center(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: surface.withValues(alpha: 0.94),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: built
                          ? primary.withValues(alpha: 0.45)
                          : Theme.of(
                              context,
                            ).disabledColor.withValues(alpha: 0.22),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    child: Text(
                      _shortName(building.name),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: built ? null : Theme.of(context).disabledColor,
                      ),
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

  Color _buildingAccent(String iconName, bool dark) {
    return switch (iconName) {
      'home' => dark ? const Color(0xFF8DD7A5) : const Color(0xFFBDEFC9),
      'desk' => dark ? const Color(0xFF77B8FF) : const Color(0xFFCBE4FF),
      'library' => dark ? const Color(0xFFC9A0FF) : const Color(0xFFE7D4FF),
      'garden' => dark ? const Color(0xFF74D6A0) : const Color(0xFFC9F4D8),
      'workshop' => dark ? const Color(0xFFFFC46B) : const Color(0xFFFFE0A3),
      'guild' => dark ? const Color(0xFFFF9FAE) : const Color(0xFFFFD4DC),
      'tower' => dark ? const Color(0xFF9ED9FF) : const Color(0xFFD4F0FF),
      _ => dark ? const Color(0xFF88A8FF) : const Color(0xFFDDE6FF),
    };
  }

  String _shortName(String name) {
    return switch (building.id) {
      'focus_camp' => 'Camp',
      'quiet_office' => 'Bureau',
      'library' => 'Biblio',
      'garden' => 'Jardin',
      'pomodoro_workshop' => 'Atelier',
      'habit_guild' => 'Guilde',
      'focus_tower' => 'Tour',
      _ => name,
    };
  }
}

class _LevelAura extends StatelessWidget {
  const _LevelAura({
    required this.color,
    required this.strong,
    required this.size,
  });

  final Color color;
  final bool strong;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: SizedBox.square(
        dimension: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                color.withValues(alpha: strong ? 0.38 : 0.25),
                color.withValues(alpha: strong ? 0.18 : 0.10),
                Colors.transparent,
              ],
              stops: const [0.0, 0.54, 1.0],
            ),
          ),
        ),
      ),
    );
  }
}

class _LevelBadge extends StatelessWidget {
  const _LevelBadge({required this.level, required this.isMaxLevel});

  final int level;
  final bool isMaxLevel;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: isMaxLevel
            ? const LinearGradient(
                colors: [Color(0xFFFFE08A), Color(0xFFFFA936)],
              )
            : null,
        color: isMaxLevel ? null : Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.72)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isMaxLevel) ...[
              const Icon(Icons.star_rounded, size: 12, color: Colors.black),
              const SizedBox(width: 2),
            ],
            Text(
              '$level',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BuildingCard extends ConsumerStatefulWidget {
  const _BuildingCard({required this.building});

  final KingdomBuilding building;

  @override
  ConsumerState<_BuildingCard> createState() => _BuildingCardState();
}

class _BuildingCardState extends ConsumerState<_BuildingCard> {
  bool _celebrating = false;

  @override
  Widget build(BuildContext context) {
    final building = widget.building;
    final player = ref.watch(playerProvider);
    final canBuild =
        !building.isBuilt &&
        player.level >= building.requiredLevel &&
        player.coins >= building.cost;
    final canUpgrade =
        building.canUpgrade && player.coins >= building.upgradeCost;
    final lockedByLevel = player.level < building.requiredLevel;

    return Card(
      elevation: 0,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _BuildingAvatar(building: building),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              building.name,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w900),
                            ),
                            const SizedBox(height: 4),
                            Text(building.description),
                            const SizedBox(height: 10),
                            _LevelTrack(
                              level: building.level,
                              maxLevel: building.maxLevel,
                              isBuilt: building.isBuilt,
                            ),
                            if (building.isBuilt) ...[
                              const SizedBox(height: 8),
                              _BuildingStageLabel(building: building),
                            ],
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
                      _SummaryPill(
                        icon: Icons.paid_rounded,
                        label: building.cost == 0
                            ? 'Gratuit'
                            : '${building.cost} pieces',
                      ),
                      _SummaryPill(
                        icon: Icons.military_tech_rounded,
                        label: 'Niv. ${building.requiredLevel}',
                      ),
                      if (building.isBuilt)
                        _SummaryPill(
                          icon: Icons.castle_rounded,
                          label:
                              'Batiment niv. ${building.level}/${building.maxLevel}',
                        ),
                      if (building.hasBonus && building.isBuilt)
                        _SummaryPill(
                          icon: Icons.auto_awesome_rounded,
                          label: building.bonusLabel,
                        ),
                      if (building.hasBonus && building.canUpgrade)
                        _SummaryPill(
                          icon: Icons.trending_up_rounded,
                          label: 'Prochain: ${building.nextBonusLabel}',
                        ),
                      if (building.isBuilt && building.canUpgrade)
                        _SummaryPill(
                          icon: Icons.upgrade_rounded,
                          label: 'Ameliorer: ${building.upgradeCost} pieces',
                        ),
                      if (building.isBuilt && !building.canUpgrade)
                        const _SummaryPill(
                          icon: Icons.verified_rounded,
                          label: 'Niveau max',
                        ),
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
                                    final result = await ref
                                        .read(kingdomProvider.notifier)
                                        .buildBuilding(building.id);
                                    if (!context.mounted) {
                                      return;
                                    }
                                    _celebrateIfSuccess(result);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          _messageFor(result, building.name),
                                        ),
                                      ),
                                    );
                                  }
                                : null,
                            icon: Icon(
                              lockedByLevel
                                  ? Icons.lock_rounded
                                  : Icons.construction_rounded,
                            ),
                            label: const Text('Construire'),
                          )
                        else
                          FilledButton.tonalIcon(
                            onPressed: canUpgrade
                                ? () async {
                                    final result = await ref
                                        .read(kingdomProvider.notifier)
                                        .upgradeBuilding(building.id);
                                    if (!context.mounted) {
                                      return;
                                    }
                                    _celebrateIfSuccess(result);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          _messageFor(result, building.name),
                                        ),
                                      ),
                                    );
                                  }
                                : null,
                            icon: Icon(
                              building.canUpgrade
                                  ? Icons.upgrade_rounded
                                  : Icons.verified_rounded,
                            ),
                            label: Text(
                              building.canUpgrade ? 'Ameliorer' : 'Max',
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (_celebrating)
              Positioned.fill(
                child: _BuildCelebration(
                  color: Theme.of(context).colorScheme.secondary,
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

  void _celebrateIfSuccess(BuildResult result) {
    if (result != BuildResult.built && result != BuildResult.upgraded) {
      return;
    }

    setState(() => _celebrating = true);
    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (mounted) {
        setState(() => _celebrating = false);
      }
    });
  }
}

class _BuildCelebration extends StatelessWidget {
  const _BuildCelebration({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 820),
        curve: Curves.easeOutCubic,
        builder: (context, value, child) {
          final opacity = (1 - value).clamp(0.0, 1.0);

          return Opacity(
            opacity: opacity,
            child: Stack(
              children: [
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.10 * opacity),
                    ),
                  ),
                ),
                _CelebrationSparkle(
                  left: 0.18,
                  top: 0.22,
                  value: value,
                  color: color,
                ),
                _CelebrationSparkle(
                  left: 0.74,
                  top: 0.18,
                  value: value * 0.92,
                  color: color,
                ),
                _CelebrationSparkle(
                  left: 0.62,
                  top: 0.68,
                  value: value * 0.82,
                  color: color,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _CelebrationSparkle extends StatelessWidget {
  const _CelebrationSparkle({
    required this.left,
    required this.top,
    required this.value,
    required this.color,
  });

  final double left;
  final double top;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: MediaQuery.sizeOf(context).width * left * 0.78,
      top: 22 + (90 * top) - (26 * value),
      child: Transform.scale(
        scale: 0.7 + (0.55 * value),
        child: Icon(
          Icons.auto_awesome_rounded,
          color: color,
          size: 24,
          shadows: [
            Shadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 8),
          ],
        ),
      ),
    );
  }
}

class _BuildingAvatar extends StatelessWidget {
  const _BuildingAvatar({required this.building});

  final KingdomBuilding building;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final built = building.isBuilt;
    final isMaxLevel = built && building.level >= building.maxLevel;
    final hasGlow = built && building.level >= 2;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: built
              ? Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.50)
              : Theme.of(context).dividerColor.withValues(alpha: 0.40),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.24 : 0.08),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SizedBox.square(
        dimension: 64,
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (hasGlow)
              _LevelAura(
                color: Theme.of(context).colorScheme.secondary,
                strong: isMaxLevel,
                size: 58,
              ),
            Opacity(
              opacity: built ? 1 : 0.42,
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Image.asset(
                  building.imageAsset,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
            if (!built)
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.surface.withValues(alpha: 0.86),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Icon(
                    Icons.lock_open_rounded,
                    color: Theme.of(context).disabledColor,
                    size: 18,
                  ),
                ),
              ),
            if (isMaxLevel)
              Positioned(
                right: 4,
                top: 4,
                child: Icon(
                  Icons.star_rounded,
                  size: 18,
                  color: Theme.of(context).colorScheme.secondary,
                  shadows: [
                    Shadow(
                      color: Colors.black.withValues(alpha: 0.22),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _BuildingStageLabel extends StatelessWidget {
  const _BuildingStageLabel({required this.building});

  final KingdomBuilding building;

  @override
  Widget build(BuildContext context) {
    final (icon, label) = switch (building.level) {
      >= 3 => (Icons.workspace_premium_rounded, 'Batiment majeur'),
      2 => (Icons.auto_awesome_rounded, 'Batiment renforce'),
      _ => (Icons.foundation_rounded, 'Base construite'),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 15, color: Theme.of(context).colorScheme.secondary),
        const SizedBox(width: 6),
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }
}

class _LevelTrack extends StatelessWidget {
  const _LevelTrack({
    required this.level,
    required this.maxLevel,
    required this.isBuilt,
  });

  final int level;
  final int maxLevel;
  final bool isBuilt;

  @override
  Widget build(BuildContext context) {
    final active = isBuilt ? level : 0;

    return Row(
      children: [
        Text(
          isBuilt ? 'Niveau $level/$maxLevel' : 'Pas construit',
          style: Theme.of(
            context,
          ).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Row(
            children: [
              for (var index = 0; index < maxLevel; index++) ...[
                Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 240),
                    height: 7,
                    decoration: BoxDecoration(
                      color: index < active
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(
                              context,
                            ).dividerColor.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                if (index < maxLevel - 1) const SizedBox(width: 4),
              ],
            ],
          ),
        ),
      ],
    );
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
              Icon(
                icon,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
