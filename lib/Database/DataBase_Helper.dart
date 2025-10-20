import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'trackfit_database.db');

    return await openDatabase(
      path,
      version: 3,
      onCreate: (db, version) async {
        // Users table for authentication
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE NOT NULL,
            email TEXT UNIQUE NOT NULL,
            password_hash TEXT NOT NULL,
            salt TEXT NOT NULL,
            created_at TEXT NOT NULL,
            last_login TEXT,
            is_active INTEGER DEFAULT 1
          )
        ''');

        // User profiles table
        await db.execute('''
          CREATE TABLE user_profiles(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            name TEXT NOT NULL,
            age INTEGER NOT NULL,
            height REAL NOT NULL,
            weight REAL NOT NULL,
            gender TEXT NOT NULL,
            bio TEXT,
            profile_image_path TEXT,
            fitness_level TEXT DEFAULT 'beginner',
            activity_level TEXT DEFAULT 'moderate',
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
          )
        ''');

        // Workout categories
        await db.execute('''
          CREATE TABLE workout_categories(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            description TEXT,
            icon TEXT,
            color TEXT,
            created_at TEXT NOT NULL
          )
        ''');

        // Workouts table
        await db.execute('''
          CREATE TABLE workouts(
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            user_id INTEGER NOT NULL,
            category_id INTEGER,
            name TEXT NOT NULL,
            description TEXT,
            duration_minutes INTEGER NOT NULL,
            calories_burned INTEGER NOT NULL,
            difficulty_level TEXT DEFAULT 'beginner',
            exercise_data TEXT, -- JSON string for exercise details
            notes TEXT,
            date TEXT NOT NULL,
            created_at TEXT NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
            FOREIGN KEY (category_id) REFERENCES workout_categories (id)
          )
        ''');

        // Exercise types
        await db.execute('''
          CREATE TABLE exercise_types(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            category TEXT NOT NULL,
            muscle_groups TEXT, -- JSON array
            instructions TEXT,
            calories_per_minute REAL,
            created_at TEXT NOT NULL
          )
        ''');

        // Daily activities tracking
        await db.execute('''
          CREATE TABLE daily_activities(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            date TEXT NOT NULL,
            steps INTEGER DEFAULT 0,
            calories_burned INTEGER DEFAULT 0,
            calories_consumed INTEGER DEFAULT 0,
            water_intake_ml INTEGER DEFAULT 0,
            sleep_hours REAL DEFAULT 0,
            heart_rate_avg INTEGER,
            weight REAL,
            mood TEXT,
            notes TEXT,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
            UNIQUE(user_id, date)
          )
        ''');

        // Goals table
        await db.execute('''
          CREATE TABLE goals(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            title TEXT NOT NULL,
            description TEXT,
            goal_type TEXT NOT NULL, -- daily, weekly, monthly, yearly
            target_value REAL NOT NULL,
            current_value REAL DEFAULT 0,
            unit TEXT NOT NULL,
            start_date TEXT NOT NULL,
            end_date TEXT,
            is_achieved INTEGER DEFAULT 0,
            is_active INTEGER DEFAULT 1,
            created_at TEXT NOT NULL,
            updated_at TEXT NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
          )
        ''');

        // Achievements table
        await db.execute('''
          CREATE TABLE achievements(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            description TEXT NOT NULL,
            icon TEXT NOT NULL,
            category TEXT NOT NULL,
            requirement_value REAL NOT NULL,
            requirement_type TEXT NOT NULL,
            points INTEGER DEFAULT 0,
            is_active INTEGER DEFAULT 1,
            created_at TEXT NOT NULL
          )
        ''');

        // User achievements
        await db.execute('''
          CREATE TABLE user_achievements(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            achievement_id INTEGER NOT NULL,
            unlocked_at TEXT NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE,
            FOREIGN KEY (achievement_id) REFERENCES achievements (id),
            UNIQUE(user_id, achievement_id)
          )
        ''');

        // Real-time data for live updates
        await db.execute('''
          CREATE TABLE real_time_data(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            data_type TEXT NOT NULL, -- steps, heart_rate, calories, etc.
            value REAL NOT NULL,
            timestamp TEXT NOT NULL,
            device_id TEXT,
            FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
          )
        ''');

        // Notifications table
        await db.execute('''
          CREATE TABLE notifications(
              id INTEGER PRIMARY KEY AUTOINCREMENT, 
            user_id INTEGER NOT NULL,
            title TEXT NOT NULL,
            message TEXT NOT NULL,
            type TEXT NOT NULL, -- reminder, achievement, goal, etc.
            is_read INTEGER DEFAULT 0,
            scheduled_time TEXT,
            created_at TEXT NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
            )
          ''');

        // Insert default workout categories
        await _insertDefaultData(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 3) {
          // Migrate existing data to new schema
          await _migrateToV3(db);
        }
      },
      onOpen: (db) async {
        await db.rawQuery("PRAGMA journal_mode = WAL;");
        await db.rawQuery("PRAGMA foreign_keys = ON;");
      },
    );
  }

  Future<void> _insertDefaultData(Database db) async {
    // Insert default workout categories
    final categories = [
      {
        'name': 'Cardio',
        'description': 'Cardiovascular exercises',
        'icon': '🏃',
        'color': '#3B82F6'
      },
      {
        'name': 'Strength',
        'description': 'Strength training exercises',
        'icon': '💪',
        'color': '#EF4444'
      },
      {
        'name': 'Flexibility',
        'description': 'Stretching and flexibility',
        'icon': '🧘',
        'color': '#10B981'
      },
      {
        'name': 'HIIT',
        'description': 'High Intensity Interval Training',
        'icon': '⚡',
        'color': '#F59E0B'
      },
      {
        'name': 'Yoga',
        'description': 'Yoga and meditation',
        'icon': '🧘‍♀️',
        'color': '#8B5CF6'
      },
      {
        'name': 'Swimming',
        'description': 'Swimming exercises',
        'icon': '🏊',
        'color': '#06B6D4'
      },
    ];

    for (var category in categories) {
      await db.insert('workout_categories', {
        'name': category['name'],
        'description': category['description'],
        'icon': category['icon'],
        'color': category['color'],
        'created_at': DateTime.now().toIso8601String(),
      });
    }

    // Insert default exercise types
    final exercises = [
      {
        'name': 'Push-ups',
        'category': 'Strength',
        'muscle_groups': '["chest", "shoulders", "triceps"]',
        'calories_per_minute': 8.0
      },
      {
        'name': 'Plank',
        'category': 'Strength',
        'muscle_groups': '["core", "shoulders"]',
        'calories_per_minute': 5.0
      },
      {
        'name': 'Lunges',
        'category': 'Strength',
        'muscle_groups': '["legs", "glutes"]',
        'calories_per_minute': 6.0
      },
      {
        'name': 'Running',
        'category': 'Cardio',
        'muscle_groups': '["legs", "cardio"]',
        'calories_per_minute': 12.0
      },
      {
        'name': 'Walking',
        'category': 'Cardio',
        'muscle_groups': '["legs", "cardio"]',
        'calories_per_minute': 4.0
      },
      {
        'name': 'Jumping Jacks',
        'category': 'Cardio',
        'muscle_groups': '["full_body"]',
        'calories_per_minute': 10.0
      },
    ];

    for (var exercise in exercises) {
      await db.insert('exercise_types', {
        'name': exercise['name'],
        'category': exercise['category'],
        'muscle_groups': exercise['muscle_groups'],
        'calories_per_minute': exercise['calories_per_minute'],
        'created_at': DateTime.now().toIso8601String(),
      });
    }

    // Insert default achievements
    final achievements = [
      {
        'name': 'First Steps',
        'description': 'Complete your first workout',
        'icon': '👶',
        'category': 'milestone',
        'requirement_value': 1,
        'requirement_type': 'workouts',
        'points': 10
      },
      {
        'name': 'Week Warrior',
        'description': 'Workout for 7 consecutive days',
        'icon': '🔥',
        'category': 'streak',
        'requirement_value': 7,
        'requirement_type': 'streak_days',
        'points': 50
      },
      {
        'name': 'Century Club',
        'description': 'Complete 100 workouts',
        'icon': '💯',
        'category': 'milestone',
        'requirement_value': 100,
        'requirement_type': 'workouts',
        'points': 200
      },
      {
        'name': 'Early Bird',
        'description': 'Complete 50 morning workouts',
        'icon': '🌅',
        'category': 'time',
        'requirement_value': 50,
        'requirement_type': 'morning_workouts',
        'points': 100
      },
      {
        'name': 'Marathon Master',
        'description': 'Run 26.2 miles total',
        'icon': '🏃',
        'category': 'distance',
        'requirement_value': 26.2,
        'requirement_type': 'running_distance',
        'points': 150
      },
    ];

    for (var achievement in achievements) {
      await db.insert('achievements', {
        'name': achievement['name'],
        'description': achievement['description'],
        'icon': achievement['icon'],
        'category': achievement['category'],
        'requirement_value': achievement['requirement_value'],
        'requirement_type': achievement['requirement_type'],
        'points': achievement['points'],
        'created_at': DateTime.now().toIso8601String(),
      });
    }
  }

  Future<void> _migrateToV3(Database db) async {
    // Create new tables for v3
    await db.execute('''
      CREATE TABLE IF NOT EXISTS users(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL,
        salt TEXT NOT NULL,
        created_at TEXT NOT NULL,
        last_login TEXT,
        is_active INTEGER DEFAULT 1
      )
    ''');

    // Migrate existing profile data to new user_profiles table
    await db.execute('''
      CREATE TABLE IF NOT EXISTS user_profiles(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        age INTEGER NOT NULL,
        height REAL NOT NULL,
        weight REAL NOT NULL,
        gender TEXT NOT NULL,
        bio TEXT,
        profile_image_path TEXT,
        fitness_level TEXT DEFAULT 'beginner',
        activity_level TEXT DEFAULT 'moderate',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Insert default data
    await _insertDefaultData(db);
  }

  // ========== USER AUTHENTICATION METHODS ==========

  Future<int> createUser(
      String username, String email, String passwordHash, String salt) async {
    final db = await database;
    try {
      return await db.insert('users', {
        'username': username,
        'email': email,
        'password_hash': passwordHash,
        'salt': salt,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error creating user: $e');
      return -1;
    }
  }

  Future<Map<String, dynamic>?> getUserByUsername(String username) async {
    final db = await database;
    try {
      final result = await db.query(
        'users',
        where: 'username = ? AND is_active = 1',
        whereArgs: [username],
        limit: 1,
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      print('Error getting user by username: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    final db = await database;
    try {
      final result = await db.query(
        'users',
        where: 'email = ? AND is_active = 1',
        whereArgs: [email],
        limit: 1,
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      print('Error getting user by email: $e');
      return null;
    }
  }

  Future<void> updateLastLogin(int userId) async {
    final db = await database;
    try {
      await db.update(
        'users',
        {'last_login': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [userId],
      );
    } catch (e) {
      print('Error updating last login: $e');
    }
  }

  // ========== USER PROFILE METHODS ==========

  Future<int> createUserProfile(int userId, String name, int age, double height,
      double weight, String gender,
      {String? bio, String? fitnessLevel, String? activityLevel}) async {
    final db = await database;
    try {
      return await db.insert('user_profiles', {
        'user_id': userId,
        'name': name,
        'age': age,
        'height': height,
        'weight': weight,
        'gender': gender,
        'bio': bio,
        'fitness_level': fitnessLevel ?? 'beginner',
        'activity_level': activityLevel ?? 'moderate',
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error creating user profile: $e');
      return -1;
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(int userId) async {
    final db = await database;
    try {
      final result = await db.query(
        'user_profiles',
        where: 'user_id = ?',
        whereArgs: [userId],
        limit: 1,
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  Future<int> updateUserProfile(
      int userId, Map<String, dynamic> updates) async {
    final db = await database;
    try {
      updates['updated_at'] = DateTime.now().toIso8601String();
      return await db.update(
        'user_profiles',
        updates,
        where: 'user_id = ?',
        whereArgs: [userId],
      );
    } catch (e) {
      print('Error updating user profile: $e');
      return -1;
    }
  }

  // ========== WORKOUT METHODS ==========

  Future<int> createWorkout(
      int userId, String name, int durationMinutes, int caloriesBurned,
      {int? categoryId,
      String? description,
      String? difficultyLevel,
      String? exerciseData,
      String? notes}) async {
    final db = await database;
    try {
      return await db.insert('workouts', {
        'user_id': userId,
        'category_id': categoryId,
        'name': name,
        'description': description,
        'duration_minutes': durationMinutes,
        'calories_burned': caloriesBurned,
        'difficulty_level': difficultyLevel ?? 'beginner',
        'exercise_data': exerciseData,
        'notes': notes,
        'date': DateTime.now().toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error creating workout: $e');
      return -1;
    }
  }

  Future<List<Map<String, dynamic>>> getUserWorkouts(int userId,
      {int? limit, String? orderBy}) async {
    final db = await database;
    try {
      return await db.query(
        'workouts',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: orderBy ?? 'date DESC',
        limit: limit,
      );
    } catch (e) {
      print('Error getting user workouts: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getWorkoutCategories() async {
    final db = await database;
    try {
      return await db.query('workout_categories', orderBy: 'name ASC');
    } catch (e) {
      print('Error getting workout categories: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getExerciseTypes(
      {String? category}) async {
    final db = await database;
    try {
      if (category != null) {
        return await db.query(
          'exercise_types',
          where: 'category = ?',
          whereArgs: [category],
          orderBy: 'name ASC',
        );
      }
      return await db.query('exercise_types', orderBy: 'name ASC');
    } catch (e) {
      print('Error getting exercise types: $e');
      return [];
    }
  }

  // ========== DAILY ACTIVITIES METHODS ==========

  Future<int> updateDailyActivity(
      int userId, String date, Map<String, dynamic> updates) async {
    final db = await database;
    try {
      updates['updated_at'] = DateTime.now().toIso8601String();

      // Check if record exists
      final existing = await db.query(
        'daily_activities',
        where: 'user_id = ? AND date = ?',
        whereArgs: [userId, date],
        limit: 1,
      );

      if (existing.isNotEmpty) {
        return await db.update(
          'daily_activities',
          updates,
          where: 'user_id = ? AND date = ?',
          whereArgs: [userId, date],
        );
      } else {
        updates['user_id'] = userId;
        updates['date'] = date;
        updates['created_at'] = DateTime.now().toIso8601String();
        return await db.insert('daily_activities', updates);
      }
    } catch (e) {
      print('Error updating daily activity: $e');
      return -1;
    }
  }

  Future<Map<String, dynamic>?> getDailyActivity(
      int userId, String date) async {
    final db = await database;
    try {
      final result = await db.query(
        'daily_activities',
        where: 'user_id = ? AND date = ?',
        whereArgs: [userId, date],
        limit: 1,
      );
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      print('Error getting daily activity: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getDailyActivitiesRange(
      int userId, String startDate, String endDate) async {
    final db = await database;
    try {
      return await db.query(
        'daily_activities',
        where: 'user_id = ? AND date BETWEEN ? AND ?',
        whereArgs: [userId, startDate, endDate],
        orderBy: 'date ASC',
      );
    } catch (e) {
      print('Error getting daily activities range: $e');
      return [];
    }
  }

  // ========== GOALS METHODS ==========

  Future<int> createGoal(int userId, String title, String goalType,
      double targetValue, String unit,
      {String? description, String? endDate}) async {
    final db = await database;
    try {
      return await db.insert('goals', {
        'user_id': userId,
        'title': title,
        'description': description,
        'goal_type': goalType,
        'target_value': targetValue,
        'current_value': 0,
        'unit': unit,
        'start_date': DateTime.now().toIso8601String(),
        'end_date': endDate,
        'is_achieved': 0,
        'is_active': 1,
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error creating goal: $e');
      return -1;
    }
  }

  Future<List<Map<String, dynamic>>> getUserGoals(int userId,
      {bool? activeOnly}) async {
    final db = await database;
    try {
      String whereClause = 'user_id = ?';
      List<dynamic> whereArgs = [userId];

      if (activeOnly == true) {
        whereClause += ' AND is_active = 1';
      }

      return await db.query(
        'goals',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'created_at DESC',
      );
    } catch (e) {
      print('Error getting user goals: $e');
      return [];
    }
  }

  Future<int> updateGoalProgress(int goalId, double currentValue) async {
    final db = await database;
    try {
      final goal = await db.query('goals',
          where: 'id = ?', whereArgs: [goalId], limit: 1);
      if (goal.isNotEmpty) {
        final targetValue = goal.first['target_value'] as double;
        final isAchieved = currentValue >= targetValue ? 1 : 0;

        return await db.update(
          'goals',
          {
            'current_value': currentValue,
            'is_achieved': isAchieved,
            'updated_at': DateTime.now().toIso8601String(),
          },
          where: 'id = ?',
          whereArgs: [goalId],
        );
      }
      return -1;
    } catch (e) {
      print('Error updating goal progress: $e');
      return -1;
    }
  }

  // ========== ACHIEVEMENTS METHODS ==========

  Future<List<Map<String, dynamic>>> getAllAchievements() async {
    final db = await database;
    try {
      return await db.query('achievements',
          where: 'is_active = 1', orderBy: 'points ASC');
    } catch (e) {
      print('Error getting all achievements: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getUserAchievements(int userId) async {
    final db = await database;
    try {
      return await db.rawQuery('''
        SELECT a.*, ua.unlocked_at 
        FROM achievements a
        INNER JOIN user_achievements ua ON a.id = ua.achievement_id
        WHERE ua.user_id = ?
        ORDER BY ua.unlocked_at DESC
      ''', [userId]);
    } catch (e) {
      print('Error getting user achievements: $e');
      return [];
    }
  }

  Future<int> unlockAchievement(int userId, int achievementId) async {
    final db = await database;
    try {
      return await db.insert('user_achievements', {
        'user_id': userId,
        'achievement_id': achievementId,
        'unlocked_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error unlocking achievement: $e');
      return -1;
    }
  }

  // ========== REAL-TIME DATA METHODS ==========

  Future<int> addRealTimeData(int userId, String dataType, double value,
      {String? deviceId}) async {
    final db = await database;
    try {
      return await db.insert('real_time_data', {
        'user_id': userId,
        'data_type': dataType,
        'value': value,
        'timestamp': DateTime.now().toIso8601String(),
        'device_id': deviceId,
      });
    } catch (e) {
      print('Error adding real-time data: $e');
      return -1;
    }
  }

  Future<List<Map<String, dynamic>>> getRealTimeData(
      int userId, String dataType,
      {int? limit}) async {
    final db = await database;
    try {
      return await db.query(
        'real_time_data',
        where: 'user_id = ? AND data_type = ?',
        whereArgs: [userId, dataType],
        orderBy: 'timestamp DESC',
        limit: limit,
      );
    } catch (e) {
      print('Error getting real-time data: $e');
      return [];
    }
  }

  // ========== NOTIFICATIONS METHODS ==========

  Future<int> createNotification(
      int userId, String title, String message, String type,
      {String? scheduledTime}) async {
    final db = await database;
    try {
      return await db.insert('notifications', {
        'user_id': userId,
        'title': title,
        'message': message,
        'type': type,
        'scheduled_time': scheduledTime,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error creating notification: $e');
      return -1;
    }
  }

  Future<List<Map<String, dynamic>>> getUserNotifications(int userId,
      {bool? unreadOnly}) async {
    final db = await database;
    try {
      String whereClause = 'user_id = ?';
      List<dynamic> whereArgs = [userId];

      if (unreadOnly == true) {
        whereClause += ' AND is_read = 0';
      }

      return await db.query(
        'notifications',
        where: whereClause,
        whereArgs: whereArgs,
        orderBy: 'created_at DESC',
      );
    } catch (e) {
      print('Error getting user notifications: $e');
      return [];
    }
  }

  Future<int> markNotificationAsRead(int notificationId) async {
    final db = await database;
    try {
      return await db.update(
        'notifications',
        {'is_read': 1},
        where: 'id = ?',
        whereArgs: [notificationId],
      );
    } catch (e) {
      print('Error marking notification as read: $e');
      return -1;
    }
  }

  // ========== STATISTICS METHODS ==========

  Future<Map<String, dynamic>> getUserStats(
      int userId, String startDate, String endDate) async {
    final db = await database;
    try {
      // Get workout stats
      final workoutStats = await db.rawQuery('''
        SELECT 
          COUNT(*) as total_workouts,
          SUM(duration_minutes) as total_duration,
          SUM(calories_burned) as total_calories
        FROM workouts 
        WHERE user_id = ? AND date BETWEEN ? AND ?
      ''', [userId, startDate, endDate]);

      // Get daily activity stats
      final activityStats = await db.rawQuery('''
        SELECT 
          AVG(steps) as avg_steps,
          SUM(calories_burned) as total_calories_burned,
          SUM(water_intake_ml) as total_water_intake,
          AVG(sleep_hours) as avg_sleep_hours
        FROM daily_activities 
        WHERE user_id = ? AND date BETWEEN ? AND ?
      ''', [userId, startDate, endDate]);

      // Get achievement count
      final achievementCount = await db.rawQuery('''
        SELECT COUNT(*) as total_achievements
        FROM user_achievements 
        WHERE user_id = ?
      ''', [userId]);

      return {
        'workout_stats': workoutStats.first,
        'activity_stats': activityStats.first,
        'achievement_count': achievementCount.first['total_achievements'],
      };
    } catch (e) {
      print('Error getting user stats: $e');
      return {};
    }
  }

  // ========== UTILITY METHODS ==========

  Future<void> closeDB() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  Future<void> clearAllData() async {
    final db = await database;
    try {
      await db.delete('user_achievements');
      await db.delete('notifications');
      await db.delete('real_time_data');
      await db.delete('goals');
      await db.delete('daily_activities');
      await db.delete('workouts');
      await db.delete('user_profiles');
      await db.delete('users');
    } catch (e) {
      print('Error clearing all data: $e');
    }
  }

  // Legacy methods for backward compatibility
  Future<List<Map<String, dynamic>>> getFitness() async {
    return await getUserWorkouts(1); // Default user ID for legacy support
  }

  Future<List<Map<String, dynamic>>> getGoals() async {
    return await getUserGoals(1); // Default user ID for legacy support
  }

  Future<int> addGoals(int pushUps, int Steps) async {
    return await createGoal(1, 'Push-ups Goal', 'daily', pushUps.toDouble(),
        'reps'); // Legacy support
  }

  Future<int> saveWorkouts(
      int pushups, String plank, String lungs, int steps) async {
    final exerciseData = jsonEncode({
      'pushups': pushups,
      'plank': plank,
      'lungs': lungs,
      'steps': steps,
    });
    return await createWorkout(1, 'Legacy Workout', 30, 200,
        exerciseData: exerciseData); // Legacy support
  }

  Future<List<Map<String, dynamic>>> getProfile() async {
    final profile =
        await getUserProfile(1); // Default user ID for legacy support
    return profile != null ? [profile] : [];
  }

  // Legacy method for backward compatibility
  Future<void> updateProfile(String name, int age, int height, int weight,
      String gender, String bio) async {
    await updateUserProfile(1, {
      'name': name,
      'age': age,
      'height': height.toDouble(),
      'weight': weight.toDouble(),
      'gender': gender,
      'bio': bio,
    });
  }

  // Legacy method for backward compatibility
  Future<void> addProfile(String name, int age, int height, int weight,
      String gender, String bio) async {
    await createUserProfile(
        1, name, age, height.toDouble(), weight.toDouble(), gender,
        bio: bio);
  }

  // Method to clear workouts data (for legacy compatibility)
  Future<void> clearWorkouts() async {
    final db = await database;
    try {
      await db.delete('workouts');
      await db.delete('daily_activities');
    } catch (e) {
      print('Error clearing workouts: $e');
    }
  }
}
