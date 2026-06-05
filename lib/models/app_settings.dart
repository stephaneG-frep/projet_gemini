class AppSettings {
  const AppSettings({
    required this.devModeEnabled,
    required this.devTimerSeconds,
  });

  factory AppSettings.initial() => const AppSettings(
        devModeEnabled: false,
        devTimerSeconds: 15,
      );

  factory AppSettings.fromMap(Map<dynamic, dynamic> map) {
    return AppSettings(
      devModeEnabled: map['devModeEnabled'] as bool? ?? false,
      devTimerSeconds: map['devTimerSeconds'] as int? ?? 15,
    );
  }

  final bool devModeEnabled;
  final int devTimerSeconds;

  int get focusSeconds => devModeEnabled ? devTimerSeconds : 25 * 60;

  Map<String, dynamic> toMap() => {
        'devModeEnabled': devModeEnabled,
        'devTimerSeconds': devTimerSeconds,
      };

  AppSettings copyWith({bool? devModeEnabled, int? devTimerSeconds}) {
    return AppSettings(
      devModeEnabled: devModeEnabled ?? this.devModeEnabled,
      devTimerSeconds: devTimerSeconds ?? this.devTimerSeconds,
    );
  }
}
