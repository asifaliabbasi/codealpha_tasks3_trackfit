import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_tracker_app/core/theme/app_theme.dart';
import 'package:fitness_tracker_app/core/services/auth_service.dart';
import 'package:fitness_tracker_app/features/fitness/presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize auth service
  await AuthService().initialize();

  runApp(
    const ProviderScope(
      child: TrackFitApp(),
    ),
  );
}

class TrackFitApp extends StatelessWidget {
  const TrackFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrackFit',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      home: const SplashScreen(),
    );
  }
}
