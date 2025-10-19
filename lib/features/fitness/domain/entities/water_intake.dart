import 'package:equatable/equatable.dart';

class WaterIntake extends Equatable {
  final int? id;
  final int amount; // in ml
  final DateTime timestamp;
  final String? notes;
  
  const WaterIntake({
    this.id,
    required this.amount,
    required this.timestamp,
    this.notes,
  });
  
  @override
  List<Object?> get props => [id, amount, timestamp, notes];
  
  WaterIntake copyWith({
    int? id,
    int? amount,
    DateTime? timestamp,
    String? notes,
  }) {
    return WaterIntake(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      timestamp: timestamp ?? this.timestamp,
      notes: notes ?? this.notes,
    );
  }
}

class DailyWaterIntake extends Equatable {
  final DateTime date;
  final List<WaterIntake> intakes;
  final int goal; // in ml
  
  const DailyWaterIntake({
    required this.date,
    required this.intakes,
    required this.goal,
  });
  
  @override
  List<Object?> get props => [date, intakes, goal];
  
  int get totalIntake => intakes.fold(0, (sum, intake) => sum + intake.amount);
  
  double get progressPercentage => (totalIntake / goal).clamp(0.0, 1.0);
  
  bool get isGoalAchieved => totalIntake >= goal;
  
  int get remainingAmount => (goal - totalIntake).clamp(0, goal);
}
