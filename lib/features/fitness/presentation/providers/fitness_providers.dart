import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fitness_tracker_app/core/utils/result.dart';
import 'package:fitness_tracker_app/features/fitness/data/repositories/fitness_repository_impl.dart';
import 'package:fitness_tracker_app/features/fitness/data/datasources/local_database.dart';
import 'package:fitness_tracker_app/features/fitness/domain/usecases/get_workouts.dart';
import 'package:fitness_tracker_app/features/fitness/domain/usecases/user_profile_usecases.dart';
import 'package:fitness_tracker_app/features/fitness/domain/entities/workout.dart';
import 'package:fitness_tracker_app/features/fitness/domain/entities/user_profile.dart';

// Database provider
final databaseProvider = Provider<LocalDatabase>((ref) {
  return LocalDatabase();
});

// Repository provider
final fitnessRepositoryProvider = Provider<FitnessRepositoryImpl>((ref) {
  final database = ref.watch(databaseProvider);
  return FitnessRepositoryImpl(database);
});

// Use cases providers
final getWorkoutsProvider = Provider<GetWorkouts>((ref) {
  final repository = ref.watch(fitnessRepositoryProvider);
  return GetWorkouts(repository);
});

final getTodayWorkoutProvider = Provider<GetTodayWorkout>((ref) {
  final repository = ref.watch(fitnessRepositoryProvider);
  return GetTodayWorkout(repository);
});

final saveWorkoutProvider = Provider<SaveWorkout>((ref) {
  final repository = ref.watch(fitnessRepositoryProvider);
  return SaveWorkout(repository);
});

final getUserProfileProvider = Provider<GetUserProfile>((ref) {
  final repository = ref.watch(fitnessRepositoryProvider);
  return GetUserProfile(repository);
});

final saveUserProfileProvider = Provider<SaveUserProfile>((ref) {
  final repository = ref.watch(fitnessRepositoryProvider);
  return SaveUserProfile(repository);
});

// State providers
final workoutsProvider = FutureProvider<List<Workout>>((ref) async {
  final getWorkouts = ref.watch(getWorkoutsProvider);
  final result = await getWorkouts.call();
  return result.getOrThrow();
});

final todayWorkoutProvider = FutureProvider<Workout?>((ref) async {
  final getTodayWorkout = ref.watch(getTodayWorkoutProvider);
  final result = await getTodayWorkout.call();
  return result.getOrNull();
});

final userProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final getUserProfile = ref.watch(getUserProfileProvider);
  final result = await getUserProfile.call();
  return result.getOrNull();
});

// Workout stats provider
final workoutStatsProvider = FutureProvider<Map<String, int>>((ref) async {
  final workouts = await ref.watch(workoutsProvider.future);

  int totalPushUps = 0;
  int totalSteps = 0;
  int totalPlankDuration = 0;
  int totalLungsDuration = 0;
  int streakDays = 0;

  for (final workout in workouts) {
    totalPushUps += workout.pushUps;
    totalSteps += workout.steps;
    totalPlankDuration += workout.plankDuration;
    totalLungsDuration += workout.lungsDuration;
  }

  // Calculate streak
  if (workouts.isNotEmpty) {
    final today = DateTime.now();
    final sortedWorkouts = workouts..sort((a, b) => b.date.compareTo(a.date));

    int currentStreak = 0;
    DateTime? lastWorkoutDate;

    for (final workout in sortedWorkouts) {
      final workoutDate = DateTime(
        workout.date.year,
        workout.date.month,
        workout.date.day,
      );

      if (lastWorkoutDate == null) {
        if (workoutDate.isAtSameMomentAs(today) ||
            workoutDate
                .isAtSameMomentAs(today.subtract(const Duration(days: 1)))) {
          currentStreak = 1;
          lastWorkoutDate = workoutDate;
        }
      } else {
        final daysDifference = lastWorkoutDate.difference(workoutDate).inDays;
        if (daysDifference == 1) {
          currentStreak++;
          lastWorkoutDate = workoutDate;
        } else {
          break;
        }
      }
    }

    streakDays = currentStreak;
  }

  return {
    'totalPushUps': totalPushUps,
    'totalSteps': totalSteps,
    'totalPlankDuration': totalPlankDuration,
    'totalLungsDuration': totalLungsDuration,
    'streakDays': streakDays,
  };
});
