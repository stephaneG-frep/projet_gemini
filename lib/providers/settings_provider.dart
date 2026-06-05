import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/app_settings.dart';
import '../services/storage_service.dart';

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(SettingsNotifier.new);

class SettingsNotifier extends Notifier<AppSettings> {
  StorageService get _storage => StorageService.instance;

  @override
  AppSettings build() => _storage.loadSettings();

  Future<void> setDevMode(bool enabled) async {
    state = state.copyWith(devModeEnabled: enabled);
    await _storage.saveSettings(state);
  }

  Future<void> setDevTimerSeconds(int seconds) async {
    state = state.copyWith(devTimerSeconds: seconds.clamp(5, 120));
    await _storage.saveSettings(state);
  }

  Future<void> setDarkMode(bool enabled) async {
    state = state.copyWith(darkModeEnabled: enabled);
    await _storage.saveSettings(state);
  }
}
