import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/settings_provider.dart';
import 'screens/guide_screen.dart';
import 'screens/home_screen.dart';
import 'screens/pomodoro_screen.dart';
import 'screens/reward_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/stats_screen.dart';

class FocusBuddyApp extends ConsumerWidget {
  const FocusBuddyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'FocusBuddy',
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      themeMode: settings.darkModeEnabled ? ThemeMode.dark : ThemeMode.light,
      routes: {
        HomeScreen.routeName: (_) => const HomeScreen(),
        PomodoroScreen.routeName: (_) => const PomodoroScreen(),
        StatsScreen.routeName: (_) => const StatsScreen(),
        ShopScreen.routeName: (_) => const ShopScreen(),
        RewardScreen.routeName: (_) => const RewardScreen(),
        GuideScreen.routeName: (_) => const GuideScreen(),
      },
      initialRoute: HomeScreen.routeName,
    );
  }

  ThemeData _buildTheme(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    final colorScheme = ColorScheme.fromSeed(
      seedColor: isDark ? const Color(0xFF91B7FF) : const Color(0xFF6FA8DC),
      brightness: brightness,
    ).copyWith(
      primary: isDark ? const Color(0xFF9EBEFF) : const Color(0xFF5278C8),
      secondary: isDark ? const Color(0xFFFFC47D) : const Color(0xFFFFB86B),
      tertiary: isDark ? const Color(0xFF8EE0BE) : const Color(0xFF75C9A5),
      surface: isDark ? const Color(0xFF182235) : const Color(0xFFFFFBF3),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: isDark ? const Color(0xFF0F1624) : const Color(0xFFF8F2E8),
      appBarTheme: AppBarTheme(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark ? const Color(0xFFF3F6FF) : const Color(0xFF192235),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: isDark ? const Color(0xFF182235) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? const Color(0xFF243552) : const Color(0xFFFFFAF0),
        selectedColor: isDark ? const Color(0xFF314971) : const Color(0xFFFFE8B8),
      ),
    );
  }
}
