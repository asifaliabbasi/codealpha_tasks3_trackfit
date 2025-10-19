import 'package:sqflite/sqflite.dart';
import 'package:fitness_tracker_app/core/utils/result.dart';
import 'package:fitness_tracker_app/core/errors/failures.dart' hide Failure;
import 'package:fitness_tracker_app/features/fitness/domain/entities/workout.dart';
import 'package:fitness_tracker_app/features/fitness/domain/entities/user_profile.dart';
import 'package:fitness_tracker_app/features/fitness/domain/entities/fitness_goals.dart';
import 'package:fitness_tracker_app/features/fitness/domain/entities/water_intake.dart';
import 'package:fitness_tracker_app/features/fitness/domain/repositories/fitness_repository.dart';
import 'package:fitness_tracker_app/features/fitness/data/datasources/local_database.dart';
import 'package:fitness_tracker_app/features/fitness/data/models/workout_model.dart';
import 'package:fitness_tracker_app/features/fitness/data/models/user_profile_model.dart';

class FitnessRepositoryImpl implements FitnessRepository {
  final LocalDatabase _database;

  const FitnessRepositoryImpl(this._database);

  @override
  Future<Result<List<Workout>>> getWorkouts() async {
    try {
      final db = await _database.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'workouts',
        orderBy: 'date DESC',
      );

      final workouts =
          maps.map((map) => WorkoutModel.fromJson(map).toEntity()).toList();

      return Success(workouts);
    } catch (e) {
      return Failure(DatabaseFailure(message: 'Failed to get workouts: $e'));
    }
  }

  @override
  Future<Result<Workout>> saveWorkout(Workout workout) async {
    try {
      final db = await _database.database;
      final model = WorkoutModel.fromEntity(workout);

      final id = await db.insert(
        'workouts',
        model.toJson()..remove('id'),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      final savedWorkout = workout.copyWith(id: id);
      return Success(savedWorkout);
    } catch (e) {
      return Failure(DatabaseFailure(message: 'Failed to save workout: $e'));
    }
  }

  @override
  Future<Result<void>> deleteWorkout(int id) async {
    try {
      final db = await _database.database;
      await db.delete(
        'workouts',
        where: 'id = ?',
        whereArgs: [id],
      );
      return Success(null);
    } catch (e) {
      return Failure(DatabaseFailure(message: 'Failed to delete workout: $e'));
    }
  }

  @override
  Future<Result<List<Workout>>> getWorkoutsByDateRange(
      DateTime start, DateTime end) async {
    try {
      final db = await _database.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'workouts',
        where: 'date BETWEEN ? AND ?',
        whereArgs: [start.toIso8601String(), end.toIso8601String()],
        orderBy: 'date DESC',
      );

      final workouts =
          maps.map((map) => WorkoutModel.fromJson(map).toEntity()).toList();

      return Success(workouts);
    } catch (e) {
      return Failure(
          DatabaseFailure(message: 'Failed to get workouts by date range: $e'));
    }
  }

  @override
  Future<Result<Workout?>> getTodayWorkout() async {
    try {
      final today = DateTime.now();
      final startOfDay = DateTime(today.year, today.month, today.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));

      final result = await getWorkoutsByDateRange(startOfDay, endOfDay);
      if (result.isFailure) {
        return Failure(result.error!);
      }

      final workouts = result.data!;
      return Success(workouts.isNotEmpty ? workouts.first : null);
    } catch (e) {
      return Failure(
          DatabaseFailure(message: 'Failed to get today workout: $e'));
    }
  }

  @override
  Future<Result<UserProfile?>> getUserProfile() async {
    try {
      final db = await _database.database;
      final List<Map<String, dynamic>> maps = await db.query(
        'user_profiles',
        orderBy: 'created_at DESC',
        limit: 1,
      );

      if (maps.isEmpty) {
        return Success(null);
      }

      final profile = UserProfileModel.fromJson(maps.first).toEntity();
      return Success(profile);
    } catch (e) {
      return Failure(
          DatabaseFailure(message: 'Failed to get user profile: $e'));
    }
  }

  @override
  Future<Result<UserProfile>> saveUserProfile(UserProfile profile) async {
    try {
      final db = await _database.database;
      final model = UserProfileModel.fromEntity(profile);
      final now = DateTime.now();

      final profileData = model.toJson()
        ..remove('id')
        ..['created_at'] =
            profile.createdAt?.toIso8601String() ?? now.toIso8601String()
        ..['updated_at'] = now.toIso8601String();

      final id = await db.insert(
        'user_profiles',
        profileData,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      final savedProfile = profile.copyWith(
        id: id,
        createdAt: profile.createdAt ?? now,
        updatedAt: now,
      );

      return Success(savedProfile);
    } catch (e) {
      return Failure(
          DatabaseFailure(message: 'Failed to save user profile: $e'));
    }
  }

  @override
  Future<Result<void>> deleteUserProfile() async {
    try {
      final db = await _database.database;
      await db.delete('user_profiles');
      return Success(null);
    } catch (e) {
      return Failure(
          DatabaseFailure(message: 'Failed to delete user profile: $e'));
    }
  }

  @override
  Future<Result<FitnessGoals?>> getFitnessGoals() async {
    // Implementation for fitness goals
    return Success(null);
  }

  @override
  Future<Result<FitnessGoals>> saveFitnessGoals(FitnessGoals goals) async {
    // Implementation for saving fitness goals
    return Success(goals);
  }

  @override
  Future<Result<void>> deleteFitnessGoals() async {
    // Implementation for deleting fitness goals
    return Success(null);
  }

  @override
  Future<Result<List<WaterIntake>>> getWaterIntakesByDate(DateTime date) async {
    // Implementation for water intakes
    return const Success([]);
  }

  @override
  Future<Result<WaterIntake>> saveWaterIntake(WaterIntake intake) async {
    // Implementation for saving water intake
    return Success(intake);
  }

  @override
  Future<Result<void>> deleteWaterIntake(int id) async {
    // Implementation for deleting water intake
    return Success(null);
  }

  @override
  Future<Result<DailyWaterIntake>> getDailyWaterIntake(
      DateTime date, int goal) async {
    // Implementation for daily water intake
    return Success(DailyWaterIntake(date: date, intakes: [], goal: goal));
  }

  @override
  Future<Result<Map<String, dynamic>>> getWorkoutStats() async {
    // Implementation for workout stats
    return const Success({});
  }

  @override
  Future<Result<List<Map<String, dynamic>>>> getWeeklyProgress() async {
    // Implementation for weekly progress
    return const Success([]);
  }

  @override
  Future<Result<int>> getCurrentStreak() async {
    // Implementation for current streak
    return const Success(0);
  }
}
