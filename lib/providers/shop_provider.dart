import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/shop_item.dart';
import '../services/storage_service.dart';
import 'player_provider.dart';

final shopProvider = NotifierProvider<ShopNotifier, List<ShopItem>>(ShopNotifier.new);

class ShopNotifier extends Notifier<List<ShopItem>> {
  StorageService get _storage => StorageService.instance;

  static const defaultItems = [
    ShopItem(
      id: 'novice_hat',
      name: 'Chapeau de novice',
      price: 40,
      description: 'Un petit chapeau pour les premieres quetes de focus.',
      iconName: 'school',
    ),
    ShopItem(
      id: 'focus_cape',
      name: 'Cape du focus',
      price: 100,
      description: 'Une cape douce qui donne une allure de heros concentre.',
      iconName: 'sparkle',
    ),
    ShopItem(
      id: 'pomodoro_armor',
      name: 'Armure Pomodoro',
      price: 180,
      description: 'Une armure legere forgee pour tenir les longues journees.',
      iconName: 'shield',
    ),
    ShopItem(
      id: 'chrono_pet',
      name: 'Familier chrono',
      price: 240,
      description: 'Un compagnon qui garde le rythme pendant tes sessions.',
      iconName: 'timer',
    ),
  ];

  @override
  List<ShopItem> build() => _storage.loadShopItems(defaultItems);

  Future<bool> buy(String id) async {
    final index = state.indexWhere((item) => item.id == id);
    if (index == -1 || state[index].isPurchased) {
      return false;
    }

    final item = state[index];
    final paid = await ref.read(playerProvider.notifier).spendCoins(item.price);
    if (!paid) {
      return false;
    }

    final updated = [...state];
    updated[index] = item.copyWith(isPurchased: true);
    state = updated;
    await _storage.saveShopItems(state);
    return true;
  }
}
