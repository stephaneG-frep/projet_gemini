import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/player_provider.dart';
import '../providers/shop_provider.dart';

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  static const routeName = '/shop';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final player = ref.watch(playerProvider);
    final items = ref.watch(shopProvider);
    final equippedItems = items.where((item) => item.isEquipped);
    final equippedItem = equippedItems.isEmpty ? null : equippedItems.first;

    return Scaffold(
      appBar: AppBar(title: const Text('Boutique')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.toll, color: Color(0xFFFF9F1C)),
                        const SizedBox(width: 10),
                        Text('${player.coins} pieces disponibles', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      equippedItem == null ? 'Aucun objet equipe' : 'Equipe : ${equippedItem.name}',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            ...items.map(
              (item) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: item.isEquipped
                            ? const Color(0xFFFFE8B8)
                            : item.isPurchased
                                ? const Color(0xFFE4F7EF)
                                : const Color(0xFFF2F6FF),
                        child: Icon(
                          item.icon,
                          color: item.isEquipped
                              ? const Color(0xFFFF9F1C)
                              : item.isPurchased
                                  ? const Color(0xFF35A875)
                                  : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                            const SizedBox(height: 4),
                            Text(item.description),
                            const SizedBox(height: 10),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: [
                                _Tag(icon: Icons.toll, label: '${item.price} pieces'),
                                if (item.isEquipped) const _Tag(icon: Icons.check_circle, label: 'Equipe'),
                                if (item.isPurchased && !item.isEquipped) const _Tag(icon: Icons.inventory_2, label: 'Inventaire'),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FilledButton.tonalIcon(
                            onPressed: item.isPurchased
                                ? null
                                : () async {
                                    final bought = await ref.read(shopProvider.notifier).buy(item.id);
                                    if (!context.mounted) {
                                      return;
                                    }
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(bought ? '${item.name} achete !' : 'Pas assez de pieces.'),
                                      ),
                                    );
                                  },
                            icon: Icon(item.isPurchased ? Icons.check_rounded : Icons.shopping_bag_rounded),
                            label: Text(item.isPurchased ? 'Achete' : 'Acheter'),
                          ),
                          if (item.isPurchased) ...[
                            const SizedBox(height: 8),
                            OutlinedButton.icon(
                              onPressed: item.isEquipped
                                  ? null
                                  : () async {
                                      await ref.read(shopProvider.notifier).equip(item.id);
                                      if (!context.mounted) {
                                        return;
                                      }
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('${item.name} equipe !')),
                                      );
                                    },
                              icon: Icon(item.isEquipped ? Icons.check_rounded : Icons.swap_horiz_rounded),
                              label: Text(item.isEquipped ? 'Equipe' : 'Equiper'),
                            ),
                          ],
                        ],
                      ),
                    ],
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

class _Tag extends StatelessWidget {
  const _Tag({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F3EA),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16),
            const SizedBox(width: 5),
            Text(label, style: Theme.of(context).textTheme.labelMedium),
          ],
        ),
      ),
    );
  }
}
