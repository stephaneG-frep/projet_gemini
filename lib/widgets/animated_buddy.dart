import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../models/shop_item.dart';

class AnimatedBuddy extends StatelessWidget {
  const AnimatedBuddy({
    super.key,
    this.equippedItem,
    this.size = 156,
  });

  final ShopItem? equippedItem;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFFFE8B8),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF5278C8).withValues(alpha: 0.16),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: SizedBox.square(dimension: size * 0.9),
          ),
          Lottie.asset(
            'assets/animations/focus_buddy_idle.json',
            width: size,
            height: size,
            fit: BoxFit.contain,
          ),
          if (equippedItem != null)
            Positioned(
              right: size * 0.08,
              bottom: size * 0.08,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFFFB86B), width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(equippedItem!.icon, color: const Color(0xFF5278C8), size: size * 0.18),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
