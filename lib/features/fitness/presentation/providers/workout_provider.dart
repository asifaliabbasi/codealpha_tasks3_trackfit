import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../Database/DataBase_Helper.dart';
import '../../../../core/services/auth_service.dart';
import 'dart:convert';

// Workout models
class WorkoutCategory {
  final int id;
  final String name;
  final String description;
  final String icon;
  final String color;

  const WorkoutCategory({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
  });

  factory WorkoutCategory.fromMap(Map<String, dynamic> map) {
    return WorkoutCategory(
      id: map['id'] as int,
      name: map['name'] as String,
      description: map['description'] as String? ?? '',
      icon: map['icon'] as String,
      color: map['color'] as String,
    );
  }
}

class ExerciseType {
  final int id;
  final String name;
  final String category;
  final List<String> muscleGroups;
  final String? instructions;
  final double caloriesPerMinute;

  const ExerciseType({
    required this.id,
    required this.name,
    required this.category,
    required this.muscleGroups,
    this.instructions,
    required this.caloriesPerMinute,
  });

  factory ExerciseType.fromMap(Map<String, dynamic> map) {
    return ExerciseType(
      id: map['id'] as int,
      name: map['name'] as String,
      category: map['category'] as String,
      muscleGroups: List<String>.from(jsonDecode(map['muscle_groups'] ?? '[]')),
      instructions: map['instructions'] as String?,
      caloriesPerMinute: map['calories_per_minute'] as double,
    );
  }
}

class WorkoutExercise {
  final String name;
  final int sets;
  final int reps;
  final double weight;
  final int durationSeconds;
  final int restSeconds;
  final String? notes;

  const WorkoutExercise({
    required this.name,
    required this.sets,
    required this.reps,
    required this.weight,
    required this.durationSeconds,
    required this.restSeconds,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'sets': sets,
      'reps': reps,
      'weight': weight,
      'duration_seconds': durationSeconds,
      'rest_seconds': restSeconds,
      'notes': notes,
    };
  }

  factory WorkoutExercise.fromMap(Map<String, dynamic> map) {
    return WorkoutExercise(
      name: map['name'] as String,
      sets: map['sets'] as int,
      reps: map['reps'] as int,
      weight: map['weight'] as double,
      durationSeconds: map['duration_seconds'] as int,
      restSeconds: map['rest_seconds'] as int,
      notes: map['notes'] as String?,
    );
  }
}

class Workout {
  final int id;
  final int userId;
  final int? categoryId;
  final String name;
  final String? description;
  final int durationMinutes;
  final int caloriesBurned;
  final String difficultyLevel;
  final List<WorkoutExercise> exercises;
  final String? notes;
  final DateTime date;
  final DateTime createdAt;

  const Workout({
    required this.id,
    required this.userId,
    this.categoryId,
    required this.name,
    this.description,
    required this.durationMinutes,
    required this.caloriesBurned,
    required this.difficultyLevel,
    required this.exercises,
    this.notes,
    required this.date,
    required this.createdAt,
  });

  factory Workout.fromMap(Map<String, dynamic> map) {
    List<WorkoutExercise> exercises = [];
    if (map['exercise_data'] != null) {
      final exerciseData = jsonDecode(map['exercise_data'] as String);
      if (exerciseData is List) {
        exercises =
            exerciseData.map((e) => WorkoutExercise.fromMap(e)).toList();
      }
    }

    return Workout(
      id: map['id'] as int,
      userId: map['user_id'] as int,
      categoryId: map['category_id'] as int?,
      name: map['name'] as String,
      description: map['description'] as String?,
      durationMinutes: map['duration_minutes'] as int,
      caloriesBurned: map['calories_burned'] as int,
      difficultyLevel: map['difficulty_level'] as String,
      exercises: exercises,
      notes: map['notes'] as String?,
      date: DateTime.parse(map['date'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'category_id': categoryId,
      'name': name,
      'description': description,
      'duration_minutes': durationMinutes,
      'calories_burned': caloriesBurned,
      'difficulty_level': difficultyLevel,
      'exercise_data': jsonEncode(exercises.map((e) => e.toMap()).toList()),
      'notes': notes,
      'date': date.toIso8601String(),
    };
  }
}

// Workout state
class WorkoutState {
  final bool isLoading;
  final List<Workout> workouts;
  final List<WorkoutCategory> categories;
  final List<ExerciseType> exerciseTypes;
  final Workout? currentWorkout;
  final String? error;

  const WorkoutState({
    this.isLoading = false,
    this.workouts = const [],
    this.categories = const [],
    this.exerciseTypes = const [],
    this.currentWorkout,
    this.error,
  });

  WorkoutState copyWith({
    bool? isLoading,
    List<Workout>? workouts,
    List<WorkoutCategory>? categories,
    List<ExerciseType>? exerciseTypes,
    Workout? currentWorkout,
    String? error,
  }) {
    return WorkoutState(
      isLoading: isLoading ?? this.isLoading,
      workouts: workouts ?? this.workouts,
      categories: categories ?? this.categories,
      exerciseTypes: exerciseTypes ?? this.exerciseTypes,
      currentWorkout: currentWorkout ?? this.currentWorkout,
      error: error ?? this.error,
    );
  }
}

// Workout notifier
class WorkoutNotifier extends StateNotifier<WorkoutState> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final AuthService _authService = AuthService();

  WorkoutNotifier() : super(const WorkoutState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);
    try {
      await _loadCategories();
      await _loadExerciseTypes();
      await _loadUserWorkouts();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _dbHelper.getWorkoutCategories();
      state = state.copyWith(
        categories: categories.map((e) => WorkoutCategory.fromMap(e)).toList(),
      );
    } catch (e) {
      print('Error loading categories: $e');
    }
  }

  Future<void> _loadExerciseTypes() async {
    try {
      final exerciseTypes = await _dbHelper.getExerciseTypes();
      state = state.copyWith(
        exerciseTypes:
            exerciseTypes.map((e) => ExerciseType.fromMap(e)).toList(),
      );
    } catch (e) {
      print('Error loading exercise types: $e');
    }
  }

  Future<void> _loadUserWorkouts() async {
    if (_authService.currentUserId == null) return;

    try {
      final workouts =
          await _dbHelper.getUserWorkouts(_authService.currentUserId!);
      state = state.copyWith(
        isLoading: false,
        workouts: workouts.map((e) => Workout.fromMap(e)).toList(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> createWorkout({
    required String name,
    required int categoryId,
    required List<WorkoutExercise> exercises,
    String? description,
    String? notes,
    String difficultyLevel = 'beginner',
  }) async {
    if (_authService.currentUserId == null) return false;

    try {
      // Calculate total duration and calories
      int totalDurationMinutes = 0;
      int totalCalories = 0;

      for (final exercise in exercises) {
        totalDurationMinutes += exercise.durationSeconds ~/ 60;

        // Find exercise type to get calories per minute
        final exerciseType = state.exerciseTypes.firstWhere(
          (e) => e.name.toLowerCase() == exercise.name.toLowerCase(),
          orElse: () => const ExerciseType(
            id: 0,
            name: '',
            category: '',
            muscleGroups: [],
            caloriesPerMinute: 5.0,
          ),
        );

        totalCalories +=
            (exercise.durationSeconds / 60 * exerciseType.caloriesPerMinute)
                .round();
      }

      final workout = Workout(
        id: 0, // Will be set by database
        userId: _authService.currentUserId!,
        categoryId: categoryId,
        name: name,
        description: description,
        durationMinutes: totalDurationMinutes,
        caloriesBurned: totalCalories,
        difficultyLevel: difficultyLevel,
        exercises: exercises,
        notes: notes,
        date: DateTime.now(),
        createdAt: DateTime.now(),
      );

      final result = await _dbHelper.createWorkout(
        workout.userId,
        workout.name,
        workout.durationMinutes,
        workout.caloriesBurned,
        categoryId: workout.categoryId,
        description: workout.description,
        difficultyLevel: workout.difficultyLevel,
        exerciseData: jsonEncode(exercises.map((e) => e.toMap()).toList()),
        notes: workout.notes,
      );

      if (result > 0) {
        await _loadUserWorkouts();
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<void> deleteWorkout(int workoutId) async {
    try {
      // Note: DatabaseHelper doesn't have delete method yet, would need to add it
      await _loadUserWorkouts();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  List<Workout> getWorkoutsByCategory(int categoryId) {
    return state.workouts.where((w) => w.categoryId == categoryId).toList();
  }

  List<Workout> getWorkoutsByDateRange(DateTime startDate, DateTime endDate) {
    return state.workouts.where((w) {
      return w.date.isAfter(startDate.subtract(const Duration(days: 1))) &&
          w.date.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  List<Workout> getRecentWorkouts({int limit = 5}) {
    final sortedWorkouts = List<Workout>.from(state.workouts);
    sortedWorkouts.sort((a, b) => b.date.compareTo(a.date));
    return sortedWorkouts.take(limit).toList();
  }

  Map<String, int> getWorkoutStats() {
    final workouts = state.workouts;
    int totalWorkouts = workouts.length;
    int totalDuration = workouts.fold(0, (sum, w) => sum + w.durationMinutes);
    int totalCalories = workouts.fold(0, (sum, w) => sum + w.caloriesBurned);

    // Calculate streak
    int currentStreak = 0;
    final sortedWorkouts = List<Workout>.from(workouts);
    sortedWorkouts.sort((a, b) => b.date.compareTo(a.date));

    DateTime currentDate = DateTime.now();
    for (final workout in sortedWorkouts) {
      final workoutDate =
          DateTime(workout.date.year, workout.date.month, workout.date.day);
      final checkDate =
          DateTime(currentDate.year, currentDate.month, currentDate.day);

      if (workoutDate.isAtSameMomentAs(checkDate) ||
          workoutDate
              .isAtSameMomentAs(checkDate.subtract(const Duration(days: 1)))) {
        currentStreak++;
        currentDate = currentDate.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }

    return {
      'total_workouts': totalWorkouts,
      'total_duration': totalDuration,
      'total_calories': totalCalories,
      'current_streak': currentStreak,
    };
  }

  List<ExerciseType> getExerciseTypesByCategory(String category) {
    return state.exerciseTypes
        .where((e) => e.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Workout provider
final workoutProvider =
    StateNotifierProvider<WorkoutNotifier, WorkoutState>((ref) {
  return WorkoutNotifier();
});

// Convenience providers
final workoutCategoriesProvider = Provider<List<WorkoutCategory>>((ref) {
  return ref.watch(workoutProvider).categories;
});

final exerciseTypesProvider = Provider<List<ExerciseType>>((ref) {
  return ref.watch(workoutProvider).exerciseTypes;
});

final userWorkoutsProvider = Provider<List<Workout>>((ref) {
  return ref.watch(workoutProvider).workouts;
});

final recentWorkoutsProvider = Provider<List<Workout>>((ref) {
  final workouts = ref.watch(workoutProvider).workouts;
  final sortedWorkouts = List<Workout>.from(workouts);
  sortedWorkouts.sort((a, b) => b.date.compareTo(a.date));
  return sortedWorkouts.take(5).toList();
});

final workoutStatsProvider = Provider<Map<String, int>>((ref) {
  final notifier = ref.read(workoutProvider.notifier);
  return notifier.getWorkoutStats();
});
