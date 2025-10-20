import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pedometer/pedometer.dart';
import '../../../../Database/DataBase_Helper.dart';
import '../../../../core/services/auth_service.dart';

// Real-time data models
class RealTimeData {
  final String dataType;
  final double value;
  final DateTime timestamp;
  final String? deviceId;

  const RealTimeData({
    required this.dataType,
    required this.value,
    required this.timestamp,
    this.deviceId,
  });

  Map<String, dynamic> toMap() {
    return {
      'data_type': dataType,
      'value': value,
      'timestamp': timestamp.toIso8601String(),
      'device_id': deviceId,
    };
  }

  factory RealTimeData.fromMap(Map<String, dynamic> map) {
    return RealTimeData(
      dataType: map['data_type'] as String,
      value: map['value'] as double,
      timestamp: DateTime.parse(map['timestamp'] as String),
      deviceId: map['device_id'] as String?,
    );
  }
}

class DailyActivityData {
  final int steps;
  final int caloriesBurned;
  final int caloriesConsumed;
  final int waterIntakeMl;
  final double sleepHours;
  final int? heartRateAvg;
  final double? weight;
  final String? mood;
  final String? notes;
  final DateTime date;

  const DailyActivityData({
    required this.steps,
    required this.caloriesBurned,
    required this.caloriesConsumed,
    required this.waterIntakeMl,
    required this.sleepHours,
    this.heartRateAvg,
    this.weight,
    this.mood,
    this.notes,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'steps': steps,
      'calories_burned': caloriesBurned,
      'calories_consumed': caloriesConsumed,
      'water_intake_ml': waterIntakeMl,
      'sleep_hours': sleepHours,
      'heart_rate_avg': heartRateAvg,
      'weight': weight,
      'mood': mood,
      'notes': notes,
      'date': date.toIso8601String().split('T')[0], // YYYY-MM-DD format
    };
  }

  factory DailyActivityData.fromMap(Map<String, dynamic> map) {
    return DailyActivityData(
      steps: map['steps'] as int? ?? 0,
      caloriesBurned: map['calories_burned'] as int? ?? 0,
      caloriesConsumed: map['calories_consumed'] as int? ?? 0,
      waterIntakeMl: map['water_intake_ml'] as int? ?? 0,
      sleepHours: map['sleep_hours'] as double? ?? 0.0,
      heartRateAvg: map['heart_rate_avg'] as int?,
      weight: map['weight'] as double?,
      mood: map['mood'] as String?,
      notes: map['notes'] as String?,
      date: DateTime.parse(map['date'] as String),
    );
  }

  DailyActivityData copyWith({
    int? steps,
    int? caloriesBurned,
    int? caloriesConsumed,
    int? waterIntakeMl,
    double? sleepHours,
    int? heartRateAvg,
    double? weight,
    String? mood,
    String? notes,
    DateTime? date,
  }) {
    return DailyActivityData(
      steps: steps ?? this.steps,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      caloriesConsumed: caloriesConsumed ?? this.caloriesConsumed,
      waterIntakeMl: waterIntakeMl ?? this.waterIntakeMl,
      sleepHours: sleepHours ?? this.sleepHours,
      heartRateAvg: heartRateAvg ?? this.heartRateAvg,
      weight: weight ?? this.weight,
      mood: mood ?? this.mood,
      notes: notes ?? this.notes,
      date: date ?? this.date,
    );
  }
}

// Real-time data state
class RealTimeDataState {
  final bool isLoading;
  final DailyActivityData? todayActivity;
  final List<RealTimeData> recentSteps;
  final List<RealTimeData> recentHeartRate;
  final List<RealTimeData> recentCalories;
  final String? error;
  final bool isTrackingSteps;

  const RealTimeDataState({
    this.isLoading = false,
    this.todayActivity,
    this.recentSteps = const [],
    this.recentHeartRate = const [],
    this.recentCalories = const [],
    this.error,
    this.isTrackingSteps = false,
  });

  RealTimeDataState copyWith({
    bool? isLoading,
    DailyActivityData? todayActivity,
    List<RealTimeData>? recentSteps,
    List<RealTimeData>? recentHeartRate,
    List<RealTimeData>? recentCalories,
    String? error,
    bool? isTrackingSteps,
  }) {
    return RealTimeDataState(
      isLoading: isLoading ?? this.isLoading,
      todayActivity: todayActivity ?? this.todayActivity,
      recentSteps: recentSteps ?? this.recentSteps,
      recentHeartRate: recentHeartRate ?? this.recentHeartRate,
      recentCalories: recentCalories ?? this.recentCalories,
      error: error ?? this.error,
      isTrackingSteps: isTrackingSteps ?? this.isTrackingSteps,
    );
  }
}

// Real-time data notifier
class RealTimeDataNotifier extends StateNotifier<RealTimeDataState> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final AuthService _authService = AuthService();

  Stream<StepCount>? _stepCountStream;
  Stream<PedestrianStatus>? _pedestrianStatusStream;

  RealTimeDataNotifier() : super(const RealTimeDataState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);
    try {
      await _loadTodayActivity();
      await _loadRecentData();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> _loadTodayActivity() async {
    if (_authService.currentUserId == null) return;

    try {
      final today = DateTime.now();
      final todayString = today.toIso8601String().split('T')[0];

      final activityData = await _dbHelper.getDailyActivity(
        _authService.currentUserId!,
        todayString,
      );

      if (activityData != null) {
        state = state.copyWith(
          todayActivity: DailyActivityData.fromMap(activityData),
        );
      } else {
        // Create default activity for today
        final defaultActivity = DailyActivityData(
          steps: 0,
          caloriesBurned: 0,
          caloriesConsumed: 0,
          waterIntakeMl: 0,
          sleepHours: 0.0,
          date: today,
        );

        await _dbHelper.updateDailyActivity(
          _authService.currentUserId!,
          todayString,
          defaultActivity.toMap(),
        );

        state = state.copyWith(todayActivity: defaultActivity);
      }
    } catch (e) {
      print('Error loading today activity: $e');
    }
  }

  Future<void> _loadRecentData() async {
    if (_authService.currentUserId == null) return;

    try {
      final steps = await _dbHelper.getRealTimeData(
        _authService.currentUserId!,
        'steps',
        limit: 10,
      );

      final heartRate = await _dbHelper.getRealTimeData(
        _authService.currentUserId!,
        'heart_rate',
        limit: 10,
      );

      final calories = await _dbHelper.getRealTimeData(
        _authService.currentUserId!,
        'calories',
        limit: 10,
      );

      state = state.copyWith(
        isLoading: false,
        recentSteps: steps.map((e) => RealTimeData.fromMap(e)).toList(),
        recentHeartRate: heartRate.map((e) => RealTimeData.fromMap(e)).toList(),
        recentCalories: calories.map((e) => RealTimeData.fromMap(e)).toList(),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> startStepTracking() async {
    if (_authService.currentUserId == null) return;

    try {
      _stepCountStream = Pedometer.stepCountStream;
      _pedestrianStatusStream = Pedometer.pedestrianStatusStream;

      _stepCountStream!.listen((StepCount event) {
        _updateSteps(event.steps);
      });

      _pedestrianStatusStream!.listen((PedestrianStatus status) {
        print('Pedestrian status: $status');
      });

      state = state.copyWith(isTrackingSteps: true);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> stopStepTracking() async {
    _stepCountStream = null;
    _pedestrianStatusStream = null;
    state = state.copyWith(isTrackingSteps: false);
  }

  Future<void> _updateSteps(int steps) async {
    if (_authService.currentUserId == null) return;

    try {
      // Add real-time data
      await _dbHelper.addRealTimeData(
        _authService.currentUserId!,
        'steps',
        steps.toDouble(),
      );

      // Update today's activity
      final today = DateTime.now();
      final todayString = today.toIso8601String().split('T')[0];

      final currentActivity = state.todayActivity;
      if (currentActivity != null) {
        final updatedActivity = currentActivity.copyWith(steps: steps);

        await _dbHelper.updateDailyActivity(
          _authService.currentUserId!,
          todayString,
          updatedActivity.toMap(),
        );

        state = state.copyWith(todayActivity: updatedActivity);
      }

      // Update recent steps data
      await _loadRecentData();
    } catch (e) {
      print('Error updating steps: $e');
    }
  }

  Future<void> updateWaterIntake(int ml) async {
    if (_authService.currentUserId == null) return;

    try {
      final today = DateTime.now();
      final todayString = today.toIso8601String().split('T')[0];

      final currentActivity = state.todayActivity;
      if (currentActivity != null) {
        final updatedActivity = currentActivity.copyWith(
          waterIntakeMl: currentActivity.waterIntakeMl + ml,
        );

        await _dbHelper.updateDailyActivity(
          _authService.currentUserId!,
          todayString,
          updatedActivity.toMap(),
        );

        state = state.copyWith(todayActivity: updatedActivity);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateCaloriesConsumed(int calories) async {
    if (_authService.currentUserId == null) return;

    try {
      final today = DateTime.now();
      final todayString = today.toIso8601String().split('T')[0];

      final currentActivity = state.todayActivity;
      if (currentActivity != null) {
        final updatedActivity = currentActivity.copyWith(
          caloriesConsumed: currentActivity.caloriesConsumed + calories,
        );

        await _dbHelper.updateDailyActivity(
          _authService.currentUserId!,
          todayString,
          updatedActivity.toMap(),
        );

        state = state.copyWith(todayActivity: updatedActivity);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateSleepHours(double hours) async {
    if (_authService.currentUserId == null) return;

    try {
      final today = DateTime.now();
      final todayString = today.toIso8601String().split('T')[0];

      final currentActivity = state.todayActivity;
      if (currentActivity != null) {
        final updatedActivity = currentActivity.copyWith(sleepHours: hours);

        await _dbHelper.updateDailyActivity(
          _authService.currentUserId!,
          todayString,
          updatedActivity.toMap(),
        );

        state = state.copyWith(todayActivity: updatedActivity);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateWeight(double weight) async {
    if (_authService.currentUserId == null) return;

    try {
      final today = DateTime.now();
      final todayString = today.toIso8601String().split('T')[0];

      final currentActivity = state.todayActivity;
      if (currentActivity != null) {
        final updatedActivity = currentActivity.copyWith(weight: weight);

        await _dbHelper.updateDailyActivity(
          _authService.currentUserId!,
          todayString,
          updatedActivity.toMap(),
        );

        state = state.copyWith(todayActivity: updatedActivity);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateMood(String mood) async {
    if (_authService.currentUserId == null) return;

    try {
      final today = DateTime.now();
      final todayString = today.toIso8601String().split('T')[0];

      final currentActivity = state.todayActivity;
      if (currentActivity != null) {
        final updatedActivity = currentActivity.copyWith(mood: mood);

        await _dbHelper.updateDailyActivity(
          _authService.currentUserId!,
          todayString,
          updatedActivity.toMap(),
        );

        state = state.copyWith(todayActivity: updatedActivity);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> addHeartRateData(int heartRate) async {
    if (_authService.currentUserId == null) return;

    try {
      await _dbHelper.addRealTimeData(
        _authService.currentUserId!,
        'heart_rate',
        heartRate.toDouble(),
      );

      // Update today's average heart rate
      final today = DateTime.now();
      final todayString = today.toIso8601String().split('T')[0];

      final currentActivity = state.todayActivity;
      if (currentActivity != null) {
        final updatedActivity =
            currentActivity.copyWith(heartRateAvg: heartRate);

        await _dbHelper.updateDailyActivity(
          _authService.currentUserId!,
          todayString,
          updatedActivity.toMap(),
        );

        state = state.copyWith(todayActivity: updatedActivity);
      }

      await _loadRecentData();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> refreshData() async {
    await _loadTodayActivity();
    await _loadRecentData();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Real-time data provider
final realTimeDataProvider =
    StateNotifierProvider<RealTimeDataNotifier, RealTimeDataState>((ref) {
  return RealTimeDataNotifier();
});

// Convenience providers
final todayActivityProvider = Provider<DailyActivityData?>((ref) {
  return ref.watch(realTimeDataProvider).todayActivity;
});

final isTrackingStepsProvider = Provider<bool>((ref) {
  return ref.watch(realTimeDataProvider).isTrackingSteps;
});

final recentStepsProvider = Provider<List<RealTimeData>>((ref) {
  return ref.watch(realTimeDataProvider).recentSteps;
});

final recentHeartRateProvider = Provider<List<RealTimeData>>((ref) {
  return ref.watch(realTimeDataProvider).recentHeartRate;
});

final recentCaloriesProvider = Provider<List<RealTimeData>>((ref) {
  return ref.watch(realTimeDataProvider).recentCalories;
});
