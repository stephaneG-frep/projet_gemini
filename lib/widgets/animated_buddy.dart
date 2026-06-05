import 'package:flutter/material.dart';

import '../models/shop_item.dart';

class AnimatedBuddy extends StatefulWidget {
  const AnimatedBuddy({
    super.key,
    this.equippedItem,
    this.size = 156,
  });

  final ShopItem? equippedItem;
  final double size;

  @override
  State<AnimatedBuddy> createState() => _AnimatedBuddyState();
}

class _AnimatedBuddyState extends State<AnimatedBuddy> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _floatAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: 0, end: -5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _scaleAnimation = Tween<double>(begin: 0.985, end: 1.015).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox.square(
      dimension: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            bottom: widget.size * 0.02,
            child: DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isDark ? const Color(0xFF91B7FF) : const Color(0xFF5278C8)).withValues(alpha: 0.14),
              ),
              child: SizedBox(width: widget.size * 0.62, height: widget.size * 0.12),
            ),
          ),
          AnimatedBuilder(
            animation: _controller,
            child: Image.asset(
              'assets/images/focus_buddy_character.png',
              width: widget.size * 0.92,
              height: widget.size * 0.92,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _floatAnimation.value),
                child: Transform.scale(scale: _scaleAnimation.value, child: child),
              );
            },
          ),
          if (widget.equippedItem != null)
            Positioned(
              right: widget.size * 0.04,
              bottom: widget.size * 0.06,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Theme.of(context).colorScheme.secondary, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.30 : 0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Icon(
                    widget.equippedItem!.icon,
                    color: Theme.of(context).colorScheme.primary,
                    size: widget.size * 0.18,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
