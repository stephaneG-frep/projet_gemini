import 'package:flutter/material.dart';

class HpBar extends StatelessWidget {
  const HpBar({super.key, required this.hp, required this.maxHp});

  final int hp;
  final int maxHp;

  @override
  Widget build(BuildContext context) {
    final value = maxHp == 0 ? 0.0 : hp / maxHp;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('PV $hp / $maxHp', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: value.clamp(0, 1),
            minHeight: 12,
            backgroundColor: const Color(0xFFFBE3E5),
            color: const Color(0xFFE85D75),
          ),
        ),
      ],
    );
  }
}
