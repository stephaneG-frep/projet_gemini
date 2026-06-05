import 'package:hive_flutter/hive_flutter.dart';

import '../models/player.dart';
import '../models/shop_item.dart';

class StorageService {
  StorageService._();

  static final StorageService instance = StorageService._();

  static const _boxName = 'focus_buddy';
  static const _playerKey = 'player';
  static const _shopKey = 'shop_items';
  static const _settingsKey = 'settings';

  late final Box<dynamic> _box;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<dynamic>(_boxName);
    await _box.put(_settingsKey, settings);
  }

  Future<void> initForTests(String path) async {
    Hive.init(path);
    _box = await Hive.openBox<dynamic>(_boxName);
    await _box.clear();
    await _box.put(_settingsKey, settings);
  }

  Player loadPlayer() {
    final data = _box.get(_playerKey);
    if (data is Map) {
      return Player.fromMap(data);
    }
    final player = Player.initial();
    savePlayer(player);
    return player;
  }

  Future<void> savePlayer(Player player) => _box.put(_playerKey, player.toMap());

  List<ShopItem> loadShopItems(List<ShopItem> defaults) {
    final data = _box.get(_shopKey);
    if (data is List) {
      return data
          .whereType<Map>()
          .map(ShopItem.fromMap)
          .toList(growable: false);
    }
    saveShopItems(defaults);
    return defaults;
  }

  Future<void> saveShopItems(List<ShopItem> items) {
    return _box.put(_shopKey, items.map((item) => item.toMap()).toList());
  }

  Map<String, dynamic> get settings {
    final data = _box.get(_settingsKey);
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return {'pomodoroMinutes': 25, 'backgroundPenalty': 10};
  }
}
