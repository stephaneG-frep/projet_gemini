import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/pomodoro_screen.dart';
import 'screens/reward_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/stats_screen.dart';

class FocusBuddyApp extends StatelessWidget {
  const FocusBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFF6FA8DC),
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: 'FocusBuddy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme.copyWith(
          primary: const Color(0xFF5278C8),
          secondary: const Color(0xFFFFB86B),
          tertiary: const Color(0xFF75C9A5),
          surface: const Color(0xFFFFFBF3),
        ),
        scaffoldBackgroundColor: const Color(0xFFF8F2E8),
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
        cardTheme: CardThemeData(
          elevation: 0,
          color: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        ),
      ),
      routes: {
        HomeScreen.routeName: (_) => const HomeScreen(),
        PomodoroScreen.routeName: (_) => const PomodoroScreen(),
        StatsScreen.routeName: (_) => const StatsScreen(),
        ShopScreen.routeName: (_) => const ShopScreen(),
        RewardScreen.routeName: (_) => const RewardScreen(),
      },
      initialRoute: HomeScreen.routeName,
    );
  }
}
