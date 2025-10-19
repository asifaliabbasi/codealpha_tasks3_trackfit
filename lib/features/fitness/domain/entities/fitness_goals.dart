import 'package:equatable/equatable.dart';

class FitnessGoals extends Equatable {
  final int? id;
  final int stepsGoal;
  final int pushUpsGoal;
  final int waterGoal; // in ml
  final int plankGoal; // in seconds
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  const FitnessGoals({
    this.id,
    required this.stepsGoal,
    required this.pushUpsGoal,
    required this.waterGoal,
    required this.plankGoal,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
  });

  @override
  List<Object?> get props => [
        id,
        stepsGoal,
        pushUpsGoal,
        waterGoal,
        plankGoal,
        createdAt,
        updatedAt,
        isActive,
      ];

  FitnessGoals copyWith({
    int? id,
    int? stepsGoal,
    int? pushUpsGoal,
    int? waterGoal,
    int? plankGoal,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
  }) {
    return FitnessGoals(
      id: id ?? this.id,
      stepsGoal: stepsGoal ?? this.stepsGoal,
      pushUpsGoal: pushUpsGoal ?? this.pushUpsGoal,
      waterGoal: waterGoal ?? this.waterGoal,
      plankGoal: plankGoal ?? this.plankGoal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
    );
  }

  static FitnessGoals get defaultGoals => FitnessGoals(
        stepsGoal: 10000,
        pushUpsGoal: 50,
        waterGoal: 2000,
        plankGoal: 60,
        createdAt: DateTime(2024, 1, 1),
      );
}
