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

    return Scaffold(
      appBar: AppBar(title: const Text('Boutique')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    const Icon(Icons.toll, color: Color(0xFFFF9F1C)),
                    const SizedBox(width: 10),
                    Text('${player.coins} pieces disponibles', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
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
                        backgroundColor: item.isPurchased ? const Color(0xFFE4F7EF) : const Color(0xFFF2F6FF),
                        child: Icon(item.icon, color: item.isPurchased ? const Color(0xFF35A875) : Theme.of(context).colorScheme.primary),
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
                            Text('${item.price} pieces', style: Theme.of(context).textTheme.labelLarge),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
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
