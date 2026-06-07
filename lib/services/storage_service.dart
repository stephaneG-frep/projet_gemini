import 'package:hive_flutter/hive_flutter.dart';

import '../models/app_settings.dart';
import '../models/daily_quest.dart';
import '../models/kingdom_building.dart';
import '../models/kingdom_goal.dart';
import '../models/player.dart';
import '../models/shop_item.dart';

class StorageService {
  StorageService._();

  static final StorageService instance = StorageService._();

  static const _boxName = 'focus_buddy';
  static const _playerKey = 'player';
  static const _shopKey = 'shop_items';
  static const _settingsKey = 'settings';
  static const _kingdomKey = 'kingdom_buildings';
  static const _kingdomGoalsKey = 'kingdom_goals';
  static const _dailyQuestStateKey = 'daily_quest_state';

  late final Box<dynamic> _box;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox<dynamic>(_boxName);
    await _box.put(_settingsKey, loadSettings().toMap());
  }

  Future<void> initForTests(String path) async {
    Hive.init(path);
    _box = await Hive.openBox<dynamic>(_boxName);
    await _box.clear();
    await _box.put(_settingsKey, loadSettings().toMap());
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

  List<KingdomBuilding> loadKingdomBuildings(List<KingdomBuilding> defaults) {
    final data = _box.get(_kingdomKey);
    if (data is List) {
      final saved = data.whereType<Map>().map(KingdomBuilding.fromMap).toList();
      return [
        for (final defaultBuilding in defaults)
          saved
              .firstWhere(
                (building) => building.id == defaultBuilding.id,
                orElse: () => defaultBuilding,
              )
              .copyWith(
                isBuilt: saved
                    .where((building) => building.id == defaultBuilding.id)
                    .any((building) => building.isBuilt),
              ),
      ];
    }
    saveKingdomBuildings(defaults);
    return defaults;
  }

  Future<void> saveKingdomBuildings(List<KingdomBuilding> buildings) {
    return _box.put(_kingdomKey, buildings.map((building) => building.toMap()).toList());
  }

  List<KingdomGoal> loadKingdomGoals(List<KingdomGoal> defaults) {
    final data = _box.get(_kingdomGoalsKey);
    if (data is List) {
      final saved = data.whereType<Map>().map(KingdomGoal.fromMap).toList();
      return [
        for (final defaultGoal in defaults)
          defaultGoal.copyWith(
            isClaimed: saved
                .where((goal) => goal.id == defaultGoal.id)
                .any((goal) => goal.isClaimed),
          ),
      ];
    }
    saveKingdomGoals(defaults);
    return defaults;
  }

  Future<void> saveKingdomGoals(List<KingdomGoal> goals) {
    return _box.put(_kingdomGoalsKey, goals.map((goal) => goal.toMap()).toList());
  }

  DailyQuestState? loadDailyQuestState() {
    final data = _box.get(_dailyQuestStateKey);
    if (data is Map) {
      return DailyQuestState.fromMap(data);
    }
    return null;
  }

  Future<void> saveDailyQuestState(DailyQuestState state) {
    return _box.put(_dailyQuestStateKey, state.toMap());
  }

  AppSettings loadSettings() {
    final data = _box.get(_settingsKey);
    if (data is Map) {
      return AppSettings.fromMap(data);
    }
    final settings = AppSettings.initial();
    saveSettings(settings);
    return settings;
  }

  Future<void> saveSettings(AppSettings settings) => _box.put(_settingsKey, settings.toMap());
}
