import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:fitness_tracker_app/core/constants/app_constants.dart';

class LocalDatabase {
  static final LocalDatabase _instance = LocalDatabase._internal();
  static Database? _database;

  LocalDatabase._internal();

  factory LocalDatabase() => _instance;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, AppConstants.databaseName);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onOpen: (db) async {
        await db.rawQuery("PRAGMA journal_mode = WAL;");
        await db.rawQuery("PRAGMA foreign_keys = ON;");
      },
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Workouts table
    await db.execute('''
      CREATE TABLE workouts(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        push_ups INTEGER NOT NULL DEFAULT 0,
        plank_duration INTEGER NOT NULL DEFAULT 0,
        lungs_duration INTEGER NOT NULL DEFAULT 0,
        steps INTEGER NOT NULL DEFAULT 0,
        date TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT
      )
    ''');

    // User profiles table
    await db.execute('''
      CREATE TABLE user_profiles(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        age INTEGER NOT NULL,
        height REAL NOT NULL,
        weight REAL NOT NULL,
        gender TEXT NOT NULL,
        bio TEXT NOT NULL,
        profile_image_path TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT
      )
    ''');

    // Fitness goals table
    await db.execute('''
      CREATE TABLE fitness_goals(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        steps_goal INTEGER NOT NULL,
        push_ups_goal INTEGER NOT NULL,
        water_goal INTEGER NOT NULL,
        plank_goal INTEGER NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT
      )
    ''');

    // Water intake table
    await db.execute('''
      CREATE TABLE water_intakes(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        amount INTEGER NOT NULL,
        timestamp TEXT NOT NULL,
        notes TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    // Create indexes for better performance
    await db.execute('CREATE INDEX idx_workouts_date ON workouts(date)');
    await db.execute(
        'CREATE INDEX idx_water_intakes_timestamp ON water_intakes(timestamp)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new columns or tables for version 2
      await db.execute('ALTER TABLE workouts ADD COLUMN notes TEXT');
    }

    if (oldVersion < 3) {
      // Add new columns or tables for version 3
      await db.execute(
          'ALTER TABLE user_profiles ADD COLUMN profile_image_path TEXT');
    }
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
