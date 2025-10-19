import 'package:fitness_tracker_app/core/utils/result.dart';
import 'package:fitness_tracker_app/core/errors/failures.dart' as failures;
import 'package:fitness_tracker_app/features/fitness/domain/entities/workout.dart';
import 'package:fitness_tracker_app/features/fitness/domain/repositories/fitness_repository.dart';

class GetWorkouts {
  final FitnessRepository repository;

  const GetWorkouts(this.repository);

  Future<Result<List<Workout>>> call() async {
    return await repository.getWorkouts();
  }
}

class GetWorkoutsByDateRange {
  final FitnessRepository repository;

  const GetWorkoutsByDateRange(this.repository);

  Future<Result<List<Workout>>> call(DateTime start, DateTime end) async {
    if (start.isAfter(end)) {
      return const Failure(failures.ValidationFailure(
          message: 'Start date cannot be after end date'));
    }

    return await repository.getWorkoutsByDateRange(start, end);
  }
}

class GetTodayWorkout {
  final FitnessRepository repository;

  const GetTodayWorkout(this.repository);

  Future<Result<Workout?>> call() async {
    return await repository.getTodayWorkout();
  }
}

class SaveWorkout {
  final FitnessRepository repository;

  const SaveWorkout(this.repository);

  Future<Result<Workout>> call(Workout workout) async {
    if (workout.pushUps < 0 ||
        workout.plankDuration < 0 ||
        workout.lungsDuration < 0 ||
        workout.steps < 0) {
      return const Failure(failures.ValidationFailure(
          message: 'Workout values cannot be negative'));
    }

    if (!workout.hasActivity) {
      return const Failure(failures.ValidationFailure(
          message: 'Workout must have at least one activity'));
    }

    return await repository.saveWorkout(workout);
  }
}

class DeleteWorkout {
  final FitnessRepository repository;

  const DeleteWorkout(this.repository);

  Future<Result<void>> call(int id) async {
    if (id <= 0) {
      return const Failure(
          failures.ValidationFailure(message: 'Invalid workout ID'));
    }

    return await repository.deleteWorkout(id);
  }
}
