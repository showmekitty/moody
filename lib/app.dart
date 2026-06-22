import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'database/database_helper.dart';
import 'screens/home_screen.dart';
import 'screens/add_mood_screen.dart';
import 'screens/stats_screen.dart';
import 'screens/settings_screen.dart';
import 'theme/theme_provider.dart';
import 'theme/app_theme.dart';

class MoodyApp extends StatelessWidget {
  final DatabaseHelper dbHelper;

  const MoodyApp({super.key, required this.dbHelper});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          name: 'home',
          builder: (context, state) => HomeScreen(dbHelper: dbHelper),
        ),
        GoRoute(
          path: '/add',
          name: 'add',
          builder: (context, state) => AddMoodScreen(dbHelper: dbHelper),
        ),
        GoRoute(
          path: '/stats',
          name: 'stats',
          builder: (context, state) => StatsScreen(dbHelper: dbHelper),
        ),
        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (context, state) => SettingsScreen(dbHelper: dbHelper),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'Moody',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      routerConfig: router,
    );
  }
}