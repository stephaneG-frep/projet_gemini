class Player {
  const Player({
    required this.level,
    required this.xp,
    required this.xpToNextLevel,
    required this.coins,
    required this.hp,
    required this.maxHp,
    required this.streak,
    required this.bestStreak,
    required this.totalFocusMinutes,
    required this.completedSessions,
    required this.failedSessions,
    required this.totalCoinsEarned,
  });

  factory Player.initial() => const Player(
        level: 1,
        xp: 0,
        xpToNextLevel: 100,
        coins: 0,
        hp: 100,
        maxHp: 100,
        streak: 0,
        bestStreak: 0,
        totalFocusMinutes: 0,
        completedSessions: 0,
        failedSessions: 0,
        totalCoinsEarned: 0,
      );

  factory Player.fromMap(Map<dynamic, dynamic> map) => Player(
        level: map['level'] as int? ?? 1,
        xp: map['xp'] as int? ?? 0,
        xpToNextLevel: map['xpToNextLevel'] as int? ?? 100,
        coins: map['coins'] as int? ?? 0,
        hp: map['hp'] as int? ?? 100,
        maxHp: map['maxHp'] as int? ?? 100,
        streak: map['streak'] as int? ?? 0,
        bestStreak: map['bestStreak'] as int? ?? 0,
        totalFocusMinutes: map['totalFocusMinutes'] as int? ?? 0,
        completedSessions: map['completedSessions'] as int? ?? 0,
        failedSessions: map['failedSessions'] as int? ?? 0,
        totalCoinsEarned: map['totalCoinsEarned'] as int? ?? 0,
      );

  final int level;
  final int xp;
  final int xpToNextLevel;
  final int coins;
  final int hp;
  final int maxHp;
  final int streak;
  final int bestStreak;
  final int totalFocusMinutes;
  final int completedSessions;
  final int failedSessions;
  final int totalCoinsEarned;

  Map<String, dynamic> toMap() => {
        'level': level,
        'xp': xp,
        'xpToNextLevel': xpToNextLevel,
        'coins': coins,
        'hp': hp,
        'maxHp': maxHp,
        'streak': streak,
        'bestStreak': bestStreak,
        'totalFocusMinutes': totalFocusMinutes,
        'completedSessions': completedSessions,
        'failedSessions': failedSessions,
        'totalCoinsEarned': totalCoinsEarned,
      };

  Player copyWith({
    int? level,
    int? xp,
    int? xpToNextLevel,
    int? coins,
    int? hp,
    int? maxHp,
    int? streak,
    int? bestStreak,
    int? totalFocusMinutes,
    int? completedSessions,
    int? failedSessions,
    int? totalCoinsEarned,
  }) {
    return Player(
      level: level ?? this.level,
      xp: xp ?? this.xp,
      xpToNextLevel: xpToNextLevel ?? this.xpToNextLevel,
      coins: coins ?? this.coins,
      hp: hp ?? this.hp,
      maxHp: maxHp ?? this.maxHp,
      streak: streak ?? this.streak,
      bestStreak: bestStreak ?? this.bestStreak,
      totalFocusMinutes: totalFocusMinutes ?? this.totalFocusMinutes,
      completedSessions: completedSessions ?? this.completedSessions,
      failedSessions: failedSessions ?? this.failedSessions,
      totalCoinsEarned: totalCoinsEarned ?? this.totalCoinsEarned,
    );
  }
}
