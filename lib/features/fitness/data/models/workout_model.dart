import 'package:fitness_tracker_app/features/fitness/domain/entities/workout.dart';

class WorkoutModel extends Workout {
  const WorkoutModel({
    super.id,
    required super.pushUps,
    required super.plankDuration,
    required super.lungsDuration,
    required super.steps,
    required super.date,
    super.notes,
  });
  
  factory WorkoutModel.fromJson(Map<String, dynamic> json) {
    return WorkoutModel(
      id: json['id'] as int?,
      pushUps: json['push_ups'] as int,
      plankDuration: json['plank_duration'] as int,
      lungsDuration: json['lungs_duration'] as int,
      steps: json['steps'] as int,
      date: DateTime.parse(json['date'] as String),
      notes: json['notes'] as String?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'push_ups': pushUps,
      'plank_duration': plankDuration,
      'lungs_duration': lungsDuration,
      'steps': steps,
      'date': date.toIso8601String(),
      'notes': notes,
    };
  }
  
  factory WorkoutModel.fromEntity(Workout workout) {
    return WorkoutModel(
      id: workout.id,
      pushUps: workout.pushUps,
      plankDuration: workout.plankDuration,
      lungsDuration: workout.lungsDuration,
      steps: workout.steps,
      date: workout.date,
      notes: workout.notes,
    );
  }
  
  Workout toEntity() {
    return Workout(
      id: id,
      pushUps: pushUps,
      plankDuration: plankDuration,
      lungsDuration: lungsDuration,
      steps: steps,
      date: date,
      notes: notes,
    );
  }
}
