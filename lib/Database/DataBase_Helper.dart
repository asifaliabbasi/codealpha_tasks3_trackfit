import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

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
    final path = join(dbPath, 'fitness_tracker.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE workouts(
            id INTEGER PRIMARY KEY AUTOINCREMENT, 
            pushups INTEGER NOT NULL, 
            plank TEXT NOT NULL,
            lungs TEXT NOT NULL,
            steps INTEGER NOT NULL,
            date TEXT NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE profile(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            Name TEXT NOT NULL,
            Age INTEGER NOT NULL,
            Height INTEGER NOT NULL,
            Weight INTEGER NOT NULL,
            Gender TEXT NOT NULL,
            bio TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE goals(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            pushUps INTEGER NOT NULL,
            Steps INTEGER NOT NULL,
            date TEXT NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE workouts(
              id INTEGER PRIMARY KEY AUTOINCREMENT, 
              pushups INTEGER NOT NULL, 
              plank TEXT NOT NULL,
              lungs TEXT NOT NULL,
              steps INTEGER NOT NULL,
              date TEXT NOT NULL
            )
          ''');
        }
      },
      onOpen: (db) async {
        await db.rawQuery("PRAGMA journal_mode = WAL;");
      },
    );
  }

  Future<List<Map<String, dynamic>>> getFitness() async {
    final db = await database;
    try {
      return await db.query('workouts', orderBy: 'id DESC');
    } catch (e) {
      print('Error fetching fitness data: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getGoals() async {
    final db = await database;
    try {
      return await db.query('goals', orderBy: 'id DESC');
    } catch (e) {
      print('Error fetching goals: $e');
      return [];
    }
  }

  Future<int> addGoals(int pushUps, int Steps) async {
    final db = await database;
    try {
      return await db.insert(
        'goals',
        {
          'pushUps': pushUps,
          'Steps': Steps,
          'date': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error adding goals: $e');
      return -1;
    }
  }

  Future<int> updateProfile(String name, int age, int height, int weight, String gender, String bio) async {
    final db = await database;
    try {
      return await db.update(
        'profile',
        {
          'Name': name,
          'Age': age,
          'Height': height,
          'Weight': weight,
          'Gender': gender,
          'bio': bio,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error updating profile: $e');
      return -1;
    }
  }

  Future<int> addProfile(String name, int age, int height, int weight, String gender, String bio) async {
    final db = await database;
    try {
      return await db.insert(
        'profile',
        {
          'Name': name,
          'Age': age,
          'Height': height,
          'Weight': weight,
          'Gender': gender,
          'bio': bio,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      print('Error adding profile: $e');
      return -1;
    }
  }

  Future<int> deleteTrack(int id) async {
    final db = await database;
    try {
      return await db.delete('workouts', where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      print('Error deleting track: $e');
      return -1;
    }
  }

  Future<int> saveWorkouts(int pushups, String plank, String lungs, int steps) async {
    final db = await database;
    try {
      return await db.insert(
        'workouts',
        {
          'pushups': pushups,
          'plank': plank,
          'lungs': lungs,
          'steps': steps,
          'date': DateTime.now().toIso8601String()
        },
      );
    } catch (e) {
      print('Error saving workouts: $e');
      return -1;
    }
  }

  Future<List<Map<String, dynamic>>> getProfile() async {
    final db = await database;
    try {
      return await db.query('profile', orderBy: 'id DESC');
    } catch (e) {
      print('Error fetching profile: $e');
      return [];
    }
  }

  Future<void> closeDB() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }

  Future<void> clearWorkouts() async {
    final db = await database;
    try {
      await db.delete('workouts');
    } catch (e) {
      print('Error clearing workouts: $e');
    }
  }
}
