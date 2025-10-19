class AppConstants {
  // App Information
  static const String appName = 'TrackFit';
  static const String appVersion = '2.0.0';
  
  // Database
  static const String databaseName = 'trackfit.db';
  static const int databaseVersion = 3;
  
  // Storage Keys
  static const String userProfileKey = 'user_profile';
  static const String themeKey = 'theme_mode';
  static const String waterIntakeKey = 'water_intake';
  static const String waterDateKey = 'water_date';
  static const String firstLaunchKey = 'first_launch';
  
  // Goals
  static const int defaultStepsGoal = 10000;
  static const int defaultPushUpsGoal = 50;
  static const int defaultWaterGoal = 2000; // ml
  static const int defaultPlankGoal = 60; // seconds
  
  // UI Constants
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 12.0;
  static const double largeBorderRadius = 20.0;
  
  // Animation Durations
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 400);
  static const Duration longAnimation = Duration(milliseconds: 600);
  
  // Touch Targets (Fitts' Law)
  static const double minTouchTarget = 44.0;
  static const double buttonHeight = 56.0;
  static const double iconSize = 24.0;
  static const double largeIconSize = 32.0;
}
