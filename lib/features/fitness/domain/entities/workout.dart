import 'package:equatable/equatable.dart';

class Workout extends Equatable {
  final int? id;
  final int pushUps;
  final int plankDuration; // in seconds
  final int lungsDuration; // in seconds
  final int steps;
  final DateTime date;
  final String? notes;

  const Workout({
    this.id,
    required this.pushUps,
    required this.plankDuration,
    required this.lungsDuration,
    required this.steps,
    required this.date,
    this.notes,
  });

  @override
  List<Object?> get props => [
        id,
        pushUps,
        plankDuration,
        lungsDuration,
        steps,
        date,
        notes,
      ];

  Workout copyWith({
    int? id,
    int? pushUps,
    int? plankDuration,
    int? lungsDuration,
    int? steps,
    DateTime? date,
    String? notes,
  }) {
    return Workout(
      id: id ?? this.id,
      pushUps: pushUps ?? this.pushUps,
      plankDuration: plankDuration ?? this.plankDuration,
      lungsDuration: lungsDuration ?? this.lungsDuration,
      steps: steps ?? this.steps,
      date: date ?? this.date,
      notes: notes ?? this.notes,
    );
  }

  int get totalDuration => plankDuration + lungsDuration;

  bool get hasActivity =>
      pushUps > 0 || plankDuration > 0 || lungsDuration > 0 || steps > 0;
}
