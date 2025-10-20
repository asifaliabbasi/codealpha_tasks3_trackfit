import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:fitness_tracker_app/core/utils/result.dart';
import 'package:fitness_tracker_app/core/errors/failures.dart' as failures;
import 'package:fitness_tracker_app/features/fitness/domain/entities/workout.dart';
import 'package:fitness_tracker_app/features/fitness/domain/repositories/fitness_repository.dart';
import 'package:fitness_tracker_app/features/fitness/domain/usecases/get_workouts.dart';

import 'get_workouts_test.mocks.dart';

@GenerateMocks([FitnessRepository])
void main() {
  late MockFitnessRepository mockRepository;
  late GetWorkouts getWorkouts;
  late GetWorkoutsByDateRange getWorkoutsByDateRange;
  late SaveWorkout saveWorkout;
  late DeleteWorkout deleteWorkout;

  setUp(() {
    mockRepository = MockFitnessRepository();
    getWorkouts = GetWorkouts(mockRepository);
    getWorkoutsByDateRange = GetWorkoutsByDateRange(mockRepository);
    saveWorkout = SaveWorkout(mockRepository);
    deleteWorkout = DeleteWorkout(mockRepository);
  });

  group('GetWorkouts', () {
    test('should return workouts when repository call is successful', () async {
      // Arrange
      final workouts = [
        Workout(
          pushUps: 10,
          plankDuration: 30,
          lungsDuration: 20,
          steps: 1000,
          date: DateTime.now(),
        ),
      ];
      when(mockRepository.getWorkouts())
          .thenAnswer((_) async => Success(workouts));

      // Act
      final result = await getWorkouts.call();

      // Assert
      expect(result.isSuccess, true);
      expect(result.data, workouts);
      verify(mockRepository.getWorkouts());
    });

    test('should return failure when repository call fails', () async {
      // Arrange
      when(mockRepository.getWorkouts()).thenAnswer((_) async =>
          Failure(failures.DatabaseFailure(message: 'Database error')));

      // Act
      final result = await getWorkouts.call();

      // Assert
      expect(result.isFailure, true);
      expect(result.error?.message, 'Database error');
    });
  });

  group('GetWorkoutsByDateRange', () {
    test('should return workouts when date range is valid', () async {
      // Arrange
      final start = DateTime(2024, 1, 1);
      final end = DateTime(2024, 1, 31);
      final workouts = [
        Workout(
          pushUps: 10,
          plankDuration: 30,
          lungsDuration: 20,
          steps: 1000,
          date: DateTime(2024, 1, 15),
        ),
      ];
      when(mockRepository.getWorkoutsByDateRange(start, end))
          .thenAnswer((_) async => Success(workouts));

      // Act
      final result = await getWorkoutsByDateRange.call(start, end);

      // Assert
      expect(result.isSuccess, true);
      expect(result.data, workouts);
      verify(mockRepository.getWorkoutsByDateRange(start, end));
    });

    test('should return validation failure when start date is after end date',
        () async {
      // Arrange
      final start = DateTime(2024, 1, 31);
      final end = DateTime(2024, 1, 1);

      // Act
      final result = await getWorkoutsByDateRange.call(start, end);

      // Assert
      expect(result.isFailure, true);
      expect(result.error?.message, 'Start date cannot be after end date');
    });
  });

  group('SaveWorkout', () {
    test('should save workout when data is valid', () async {
      // Arrange
      final workout = Workout(
        pushUps: 10,
        plankDuration: 30,
        lungsDuration: 20,
        steps: 1000,
        date: DateTime.now(),
      );
      when(mockRepository.saveWorkout(workout))
          .thenAnswer((_) async => Success(workout));

      // Act
      final result = await saveWorkout.call(workout);

      // Assert
      expect(result.isSuccess, true);
      expect(result.data, workout);
      verify(mockRepository.saveWorkout(workout));
    });

    test('should return validation failure when workout has negative values',
        () async {
      // Arrange
      final workout = Workout(
        pushUps: -1,
        plankDuration: 30,
        lungsDuration: 20,
        steps: 1000,
        date: DateTime.now(),
      );

      // Act
      final result = await saveWorkout.call(workout);

      // Assert
      expect(result.isFailure, true);
      expect(result.error?.message, 'Workout values cannot be negative');
    });

    test('should return validation failure when workout has no activity',
        () async {
      // Arrange
      final workout = Workout(
        pushUps: 0,
        plankDuration: 0,
        lungsDuration: 0,
        steps: 0,
        date: DateTime.now(),
      );

      // Act
      final result = await saveWorkout.call(workout);

      // Assert
      expect(result.isFailure, true);
      expect(result.error?.message, 'Workout must have at least one activity');
    });
  });

  group('DeleteWorkout', () {
    test('should delete workout when ID is valid', () async {
      // Arrange
      const id = 1;
      when(mockRepository.deleteWorkout(id))
          .thenAnswer((_) async => const Success(null));

      // Act
      final result = await deleteWorkout.call(id);

      // Assert
      expect(result.isSuccess, true);
      verify(mockRepository.deleteWorkout(id));
    });

    test('should return validation failure when ID is invalid', () async {
      // Arrange
      const id = 0;

      // Act
      final result = await deleteWorkout.call(id);

      // Assert
      expect(result.isFailure, true);
      expect(result.error?.message, 'Invalid workout ID');
    });
  });
}
