class AppSettings {
  const AppSettings({
    required this.devModeEnabled,
    required this.devTimerSeconds,
    required this.darkModeEnabled,
  });

  factory AppSettings.initial() => const AppSettings(
        devModeEnabled: false,
        devTimerSeconds: 15,
        darkModeEnabled: false,
      );

  factory AppSettings.fromMap(Map<dynamic, dynamic> map) {
    return AppSettings(
      devModeEnabled: map['devModeEnabled'] as bool? ?? false,
      devTimerSeconds: map['devTimerSeconds'] as int? ?? 15,
      darkModeEnabled: map['darkModeEnabled'] as bool? ?? false,
    );
  }

  final bool devModeEnabled;
  final int devTimerSeconds;
  final bool darkModeEnabled;

  int get focusSeconds => devModeEnabled ? devTimerSeconds : 25 * 60;

  Map<String, dynamic> toMap() => {
      'devModeEnabled': devModeEnabled,
      'devTimerSeconds': devTimerSeconds,
      'darkModeEnabled': darkModeEnabled,
      };

  AppSettings copyWith({
    bool? devModeEnabled,
    int? devTimerSeconds,
    bool? darkModeEnabled,
  }) {
    return AppSettings(
      devModeEnabled: devModeEnabled ?? this.devModeEnabled,
      devTimerSeconds: devTimerSeconds ?? this.devTimerSeconds,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
    );
  }
}
