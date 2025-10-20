import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../Database/DataBase_Helper.dart';
import '../../../../core/services/auth_service.dart';

// Goal models
class Goal {
  final int id;
  final int userId;
  final String title;
  final String? description;
  final String goalType; // daily, weekly, monthly, yearly
  final double targetValue;
  final double currentValue;
  final String unit;
  final DateTime startDate;
  final DateTime? endDate;
  final bool isAchieved;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Goal({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.goalType,
    required this.targetValue,
    required this.currentValue,
    required this.unit,
    required this.startDate,
    this.endDate,
    required this.isAchieved,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Goal.fromMap(Map<String, dynamic> map) {
    return Goal(
      id: map['id'] as int,
      userId: map['user_id'] as int,
      title: map['title'] as String,
      description: map['description'] as String?,
      goalType: map['goal_type'] as String,
      targetValue: map['target_value'] as double,
      currentValue: map['current_value'] as double,
      unit: map['unit'] as String,
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: map['end_date'] != null
          ? DateTime.parse(map['end_date'] as String)
          : null,
      isAchieved: (map['is_achieved'] as int) == 1,
      isActive: (map['is_active'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'title': title,
      'description': description,
      'goal_type': goalType,
      'target_value': targetValue,
      'current_value': currentValue,
      'unit': unit,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'is_achieved': isAchieved ? 1 : 0,
      'is_active': isActive ? 1 : 0,
    };
  }

  Goal copyWith({
    int? id,
    int? userId,
    String? title,
    String? description,
    String? goalType,
    double? targetValue,
    double? currentValue,
    String? unit,
    DateTime? startDate,
    DateTime? endDate,
    bool? isAchieved,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Goal(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      goalType: goalType ?? this.goalType,
      targetValue: targetValue ?? this.targetValue,
      currentValue: currentValue ?? this.currentValue,
      unit: unit ?? this.unit,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isAchieved: isAchieved ?? this.isAchieved,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  double get progressPercentage {
    if (targetValue == 0) return 0.0;
    return (currentValue / targetValue).clamp(0.0, 1.0);
  }

  bool get isOverdue {
    if (endDate == null) return false;
    return DateTime.now().isAfter(endDate!) && !isAchieved;
  }

  int get daysRemaining {
    if (endDate == null) return -1;
    final now = DateTime.now();
    final remaining = endDate!.difference(now).inDays;
    return remaining > 0 ? remaining : 0;
  }
}

// Goal state
class GoalState {
  final bool isLoading;
  final List<Goal> goals;
  final List<Goal> activeGoals;
  final List<Goal> achievedGoals;
  final String? error;

  const GoalState({
    this.isLoading = false,
    this.goals = const [],
    this.activeGoals = const [],
    this.achievedGoals = const [],
    this.error,
  });

  GoalState copyWith({
    bool? isLoading,
    List<Goal>? goals,
    List<Goal>? activeGoals,
    List<Goal>? achievedGoals,
    String? error,
  }) {
    return GoalState(
      isLoading: isLoading ?? this.isLoading,
      goals: goals ?? this.goals,
      activeGoals: activeGoals ?? this.activeGoals,
      achievedGoals: achievedGoals ?? this.achievedGoals,
      error: error ?? this.error,
    );
  }
}

// Goal notifier
class GoalNotifier extends StateNotifier<GoalState> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final AuthService _authService = AuthService();

  GoalNotifier() : super(const GoalState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);
    try {
      await _loadUserGoals();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> _loadUserGoals() async {
    if (_authService.currentUserId == null) return;

    try {
      final goals = await _dbHelper.getUserGoals(_authService.currentUserId!);
      final goalList = goals.map((e) => Goal.fromMap(e)).toList();

      final activeGoals =
          goalList.where((g) => g.isActive && !g.isAchieved).toList();
      final achievedGoals = goalList.where((g) => g.isAchieved).toList();

      state = state.copyWith(
        isLoading: false,
        goals: goalList,
        activeGoals: activeGoals,
        achievedGoals: achievedGoals,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> createGoal({
    required String title,
    required String goalType,
    required double targetValue,
    required String unit,
    String? description,
    DateTime? endDate,
  }) async {
    if (_authService.currentUserId == null) return false;

    try {
      final result = await _dbHelper.createGoal(
        _authService.currentUserId!,
        title,
        goalType,
        targetValue,
        unit,
        description: description,
        endDate: endDate?.toIso8601String(),
      );

      if (result > 0) {
        await _loadUserGoals();
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<bool> updateGoalProgress(int goalId, double currentValue) async {
    try {
      final result = await _dbHelper.updateGoalProgress(goalId, currentValue);

      if (result > 0) {
        await _loadUserGoals();
        return true;
      }
      return false;
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  Future<void> deleteGoal(int goalId) async {
    try {
      // Note: Would need to add delete method to DatabaseHelper
      await _loadUserGoals();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  List<Goal> getGoalsByType(String goalType) {
    return state.goals.where((g) => g.goalType == goalType).toList();
  }

  List<Goal> getOverdueGoals() {
    return state.activeGoals.where((g) => g.isOverdue).toList();
  }

  List<Goal> getGoalsDueSoon({int days = 7}) {
    final now = DateTime.now();
    return state.activeGoals.where((g) {
      if (g.endDate == null) return false;
      final daysUntilDue = g.endDate!.difference(now).inDays;
      return daysUntilDue <= days && daysUntilDue >= 0;
    }).toList();
  }

  Map<String, dynamic> getGoalStats() {
    final goals = state.goals;
    final activeGoals = state.activeGoals;
    final achievedGoals = state.achievedGoals;

    int totalGoals = goals.length;
    int activeCount = activeGoals.length;
    int achievedCount = achievedGoals.length;
    int overdueCount = getOverdueGoals().length;

    double achievementRate =
        totalGoals > 0 ? (achievedCount / totalGoals) * 100 : 0.0;

    // Calculate average progress for active goals
    double averageProgress = 0.0;
    if (activeGoals.isNotEmpty) {
      averageProgress =
          activeGoals.fold(0.0, (sum, g) => sum + g.progressPercentage) /
              activeGoals.length;
    }

    return {
      'total_goals': totalGoals,
      'active_goals': activeCount,
      'achieved_goals': achievedCount,
      'overdue_goals': overdueCount,
      'achievement_rate': achievementRate,
      'average_progress': averageProgress,
    };
  }

  // Predefined goal templates
  List<Map<String, dynamic>> getGoalTemplates() {
    return [
      {
        'title': 'Daily Steps Goal',
        'description': 'Walk 10,000 steps every day',
        'goalType': 'daily',
        'targetValue': 10000.0,
        'unit': 'steps',
        'category': 'fitness',
      },
      {
        'title': 'Weekly Workout Goal',
        'description': 'Complete 3 workouts per week',
        'goalType': 'weekly',
        'targetValue': 3.0,
        'unit': 'workouts',
        'category': 'fitness',
      },
      {
        'title': 'Monthly Weight Loss',
        'description': 'Lose 2 kg this month',
        'goalType': 'monthly',
        'targetValue': 2.0,
        'unit': 'kg',
        'category': 'weight',
      },
      {
        'title': 'Daily Water Intake',
        'description': 'Drink 2 liters of water daily',
        'goalType': 'daily',
        'targetValue': 2000.0,
        'unit': 'ml',
        'category': 'health',
      },
      {
        'title': 'Weekly Cardio',
        'description': 'Complete 150 minutes of cardio per week',
        'goalType': 'weekly',
        'targetValue': 150.0,
        'unit': 'minutes',
        'category': 'fitness',
      },
      {
        'title': 'Monthly Push-ups',
        'description': 'Do 1000 push-ups this month',
        'goalType': 'monthly',
        'targetValue': 1000.0,
        'unit': 'reps',
        'category': 'strength',
      },
    ];
  }

  Future<bool> createGoalFromTemplate(Map<String, dynamic> template) async {
    return await createGoal(
      title: template['title'] as String,
      goalType: template['goalType'] as String,
      targetValue: template['targetValue'] as double,
      unit: template['unit'] as String,
      description: template['description'] as String,
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Goal provider
final goalProvider = StateNotifierProvider<GoalNotifier, GoalState>((ref) {
  return GoalNotifier();
});

// Convenience providers
final activeGoalsProvider = Provider<List<Goal>>((ref) {
  return ref.watch(goalProvider).activeGoals;
});

final achievedGoalsProvider = Provider<List<Goal>>((ref) {
  return ref.watch(goalProvider).achievedGoals;
});

final goalStatsProvider = Provider<Map<String, dynamic>>((ref) {
  final notifier = ref.read(goalProvider.notifier);
  return notifier.getGoalStats();
});

final overdueGoalsProvider = Provider<List<Goal>>((ref) {
  final notifier = ref.read(goalProvider.notifier);
  return notifier.getOverdueGoals();
});

final goalsDueSoonProvider = Provider<List<Goal>>((ref) {
  final notifier = ref.read(goalProvider.notifier);
  return notifier.getGoalsDueSoon();
});
