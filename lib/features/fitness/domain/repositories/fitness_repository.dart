import 'package:fitness_tracker_app/core/utils/result.dart';
import 'package:fitness_tracker_app/features/fitness/domain/entities/workout.dart';
import 'package:fitness_tracker_app/features/fitness/domain/entities/user_profile.dart';
import 'package:fitness_tracker_app/features/fitness/domain/entities/fitness_goals.dart';
import 'package:fitness_tracker_app/features/fitness/domain/entities/water_intake.dart';

abstract class FitnessRepository {
  // Workout operations
  Future<Result<List<Workout>>> getWorkouts();
  Future<Result<Workout>> saveWorkout(Workout workout);
  Future<Result<void>> deleteWorkout(int id);
  Future<Result<List<Workout>>> getWorkoutsByDateRange(DateTime start, DateTime end);
  Future<Result<Workout?>> getTodayWorkout();
  
  // User Profile operations
  Future<Result<UserProfile?>> getUserProfile();
  Future<Result<UserProfile>> saveUserProfile(UserProfile profile);
  Future<Result<void>> deleteUserProfile();
  
  // Goals operations
  Future<Result<FitnessGoals?>> getFitnessGoals();
  Future<Result<FitnessGoals>> saveFitnessGoals(FitnessGoals goals);
  Future<Result<void>> deleteFitnessGoals();
  
  // Water Intake operations
  Future<Result<List<WaterIntake>>> getWaterIntakesByDate(DateTime date);
  Future<Result<WaterIntake>> saveWaterIntake(WaterIntake intake);
  Future<Result<void>> deleteWaterIntake(int id);
  Future<Result<DailyWaterIntake>> getDailyWaterIntake(DateTime date, int goal);
  
  // Analytics operations
  Future<Result<Map<String, dynamic>>> getWorkoutStats();
  Future<Result<List<Map<String, dynamic>>>> getWeeklyProgress();
  Future<Result<int>> getCurrentStreak();
}
