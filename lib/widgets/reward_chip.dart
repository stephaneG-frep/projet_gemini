import 'package:flutter/material.dart';

enum RewardKind { xp, coins, bonus, gift }

class RewardChip extends StatelessWidget {
  const RewardChip({
    super.key,
    required this.kind,
    required this.label,
    this.compact = false,
  });

  const RewardChip.xp({super.key, required this.label, this.compact = false})
    : kind = RewardKind.xp;

  const RewardChip.coins({super.key, required this.label, this.compact = false})
    : kind = RewardKind.coins;

  const RewardChip.bonus({super.key, required this.label, this.compact = false})
    : kind = RewardKind.bonus;

  const RewardChip.gift({super.key, required this.label, this.compact = false})
    : kind = RewardKind.gift;

  final RewardKind kind;
  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final palette = _palette(Theme.of(context).brightness);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.background,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: palette.border),
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 10 : 13,
          vertical: compact ? 7 : 9,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox.square(
              dimension: compact ? 22 : 26,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: palette.iconBackground,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _icon,
                  color: palette.icon,
                  size: compact ? 14 : 16,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: palette.text,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData get _icon {
    return switch (kind) {
      RewardKind.xp => Icons.auto_awesome_rounded,
      RewardKind.coins => Icons.paid_rounded,
      RewardKind.bonus => Icons.stars_rounded,
      RewardKind.gift => Icons.card_giftcard_rounded,
    };
  }

  _RewardPalette _palette(Brightness brightness) {
    final dark = brightness == Brightness.dark;

    return switch (kind) {
      RewardKind.xp => _RewardPalette(
        background: dark ? const Color(0xFF263A63) : const Color(0xFFEAF2FF),
        border: dark ? const Color(0xFF4D78C5) : const Color(0xFFBCD6FF),
        iconBackground: dark
            ? const Color(0xFF375994)
            : const Color(0xFFD7E8FF),
        icon: dark ? const Color(0xFF9FC4FF) : const Color(0xFF255FA8),
        text: dark ? const Color(0xFFDDEAFF) : const Color(0xFF183D70),
      ),
      RewardKind.coins => _RewardPalette(
        background: dark ? const Color(0xFF493A1A) : const Color(0xFFFFF0C8),
        border: dark ? const Color(0xFFC8982A) : const Color(0xFFF2C966),
        iconBackground: dark
            ? const Color(0xFF6A511C)
            : const Color(0xFFFFD874),
        icon: dark ? const Color(0xFFFFD875) : const Color(0xFF7A4A00),
        text: dark ? const Color(0xFFFFE7A8) : const Color(0xFF6A4200),
      ),
      RewardKind.bonus => _RewardPalette(
        background: dark ? const Color(0xFF3E2B5E) : const Color(0xFFF1E7FF),
        border: dark ? const Color(0xFF8D6BD1) : const Color(0xFFD9C1FF),
        iconBackground: dark
            ? const Color(0xFF5A3C8B)
            : const Color(0xFFE3D2FF),
        icon: dark ? const Color(0xFFD8C4FF) : const Color(0xFF6B43A6),
        text: dark ? const Color(0xFFEDE1FF) : const Color(0xFF4C2D78),
      ),
      RewardKind.gift => _RewardPalette(
        background: dark ? const Color(0xFF244733) : const Color(0xFFE9F8EF),
        border: dark ? const Color(0xFF54A873) : const Color(0xFFBDE8CB),
        iconBackground: dark
            ? const Color(0xFF33704A)
            : const Color(0xFFD1F1DA),
        icon: dark ? const Color(0xFFA8EFC0) : const Color(0xFF237344),
        text: dark ? const Color(0xFFD7F7E1) : const Color(0xFF1D5C37),
      ),
    };
  }
}

class RewardChipGroup extends StatelessWidget {
  const RewardChipGroup({
    super.key,
    required this.xp,
    required this.coins,
    this.compact = false,
    this.includeEmpty = false,
  });

  final int xp;
  final int coins;
  final bool compact;
  final bool includeEmpty;

  @override
  Widget build(BuildContext context) {
    final chips = [
      if (xp > 0 || includeEmpty)
        RewardChip.xp(label: '+$xp XP', compact: compact),
      if (coins > 0 || includeEmpty)
        RewardChip.coins(label: '+$coins pieces', compact: compact),
    ];

    return Wrap(spacing: 8, runSpacing: 8, children: chips);
  }
}

class _RewardPalette {
  const _RewardPalette({
    required this.background,
    required this.border,
    required this.iconBackground,
    required this.icon,
    required this.text,
  });

  final Color background;
  final Color border;
  final Color iconBackground;
  final Color icon;
  final Color text;
}
