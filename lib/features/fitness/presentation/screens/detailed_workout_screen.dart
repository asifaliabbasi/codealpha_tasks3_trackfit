import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'dart:convert';
import '../../../../core/theme/app_colors.dart';
import '../../../../Database/DataBase_Helper.dart';
import 'main_navigation.dart';

class DetailedWorkoutScreen extends ConsumerStatefulWidget {
  final Map<String, dynamic>? workoutData;
  final String workoutType;

  const DetailedWorkoutScreen({
    super.key,
    this.workoutData,
    required this.workoutType,
  });

  @override
  ConsumerState<DetailedWorkoutScreen> createState() =>
      _DetailedWorkoutScreenState();
}

class _DetailedWorkoutScreenState extends ConsumerState<DetailedWorkoutScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;

  Timer? _workoutTimer;
  Duration _workoutDuration = Duration.zero;
  bool _isWorkoutActive = false;
  bool _isPaused = false;
  int _currentExerciseIndex = 0;
  int _currentSet = 1;
  int _repsCompleted = 0;
  int _restTimeRemaining = 0;
  Timer? _restTimer;

  List<Map<String, dynamic>> _exercises = [];
  List<Map<String, dynamic>> _completedExercises = [];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _loadWorkoutData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _workoutTimer?.cancel();
    _restTimer?.cancel();
    super.dispose();
  }

  void _loadWorkoutData() {
    // Load exercises based on workout type
    switch (widget.workoutType.toLowerCase()) {
      case 'push-ups':
        _exercises = [
          {
            'name': 'Standard Push-ups',
            'sets': 3,
            'reps': 10,
            'restTime': 60,
            'instructions':
                'Keep your body straight and lower until chest nearly touches floor',
            'muscleGroups': ['Chest', 'Shoulders', 'Triceps'],
          },
          {
            'name': 'Wide Push-ups',
            'sets': 3,
            'reps': 8,
            'restTime': 60,
            'instructions':
                'Hands wider than shoulders, focus on chest muscles',
            'muscleGroups': ['Chest', 'Shoulders'],
          },
          {
            'name': 'Diamond Push-ups',
            'sets': 2,
            'reps': 6,
            'restTime': 60,
            'instructions': 'Hands close together forming diamond shape',
            'muscleGroups': ['Triceps', 'Chest'],
          },
        ];
        break;
      case 'plank':
        _exercises = [
          {
            'name': 'Standard Plank',
            'sets': 3,
            'duration': 30,
            'restTime': 60,
            'instructions': 'Hold straight line from head to heels',
            'muscleGroups': ['Core', 'Shoulders'],
          },
          {
            'name': 'Side Plank',
            'sets': 2,
            'duration': 20,
            'restTime': 60,
            'instructions': 'Hold side position, engage obliques',
            'muscleGroups': ['Obliques', 'Core'],
          },
        ];
        break;
      case 'cardio':
        _exercises = [
          {
            'name': 'Jumping Jacks',
            'sets': 3,
            'duration': 60,
            'restTime': 30,
            'instructions': 'Jump feet apart while raising arms overhead',
            'muscleGroups': ['Full Body', 'Cardio'],
          },
          {
            'name': 'High Knees',
            'sets': 3,
            'duration': 45,
            'restTime': 30,
            'instructions': 'Run in place bringing knees to chest',
            'muscleGroups': ['Legs', 'Cardio'],
          },
          {
            'name': 'Burpees',
            'sets': 2,
            'reps': 8,
            'restTime': 60,
            'instructions':
                'Full body exercise combining squat, push-up, and jump',
            'muscleGroups': ['Full Body', 'Cardio'],
          },
        ];
        break;
      default:
        _exercises = [
          {
            'name': 'Custom Exercise',
            'sets': 3,
            'reps': 10,
            'restTime': 60,
            'instructions': 'Follow your custom workout routine',
            'muscleGroups': ['Various'],
          },
        ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: Text(
          widget.workoutType,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => _showExitDialog(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: AppColors.textPrimary),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MainNavigation()),
              );
            },
          ),
        ],
      ),
      body: _isWorkoutActive ? _buildActiveWorkout() : _buildWorkoutPreview(),
    );
  }

  Widget _buildWorkoutPreview() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWorkoutHeader(),
          const SizedBox(height: 20),
          _buildWorkoutStats(),
          const SizedBox(height: 20),
          _buildExercisesList(),
          const SizedBox(height: 20),
          _buildStartButton(),
        ],
      ),
    );
  }

  Widget _buildWorkoutHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDark,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            _getWorkoutIcon(),
            size: 60,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: 12),
          Text(
            widget.workoutType,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Ready to start your workout?',
            style: TextStyle(
              color: AppColors.textPrimary.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutStats() {
    final totalExercises = _exercises.length;
    int totalSets = 0;
    for (var exercise in _exercises) {
      totalSets += (exercise['sets'] as int? ?? 0);
    }
    final estimatedDuration = _calculateEstimatedDuration();

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            Icons.fitness_center,
            'Exercises',
            totalExercises.toString(),
            AppColors.primaryBlue,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            Icons.repeat,
            'Sets',
            totalSets.toString(),
            AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            Icons.timer,
            'Duration',
            '${estimatedDuration}min',
            AppColors.warning,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDark,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExercisesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Exercises',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ..._exercises.asMap().entries.map((entry) {
          final index = entry.key;
          final exercise = entry.value;
          return _buildExerciseCard(exercise, index);
        }).toList(),
      ],
    );
  }

  Widget _buildExerciseCard(Map<String, dynamic> exercise, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDark,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '${index + 1}',
                style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise['name'],
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  exercise['instructions'],
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildExerciseInfo(
                        Icons.repeat, '${exercise['sets']} sets'),
                    const SizedBox(width: 16),
                    _buildExerciseInfo(
                      Icons.fitness_center,
                      exercise['reps'] != null
                          ? '${exercise['reps']} reps'
                          : '${exercise['duration']}s',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseInfo(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 16),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _startWorkout,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Start Workout',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildActiveWorkout() {
    if (_currentExerciseIndex >= _exercises.length) {
      return _buildWorkoutComplete();
    }

    final currentExercise = _exercises[_currentExerciseIndex];
    final isResting = _restTimeRemaining > 0;

    return Column(
      children: [
        _buildWorkoutTimer(),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _buildCurrentExercise(currentExercise),
                const SizedBox(height: 20),
                if (isResting)
                  _buildRestTimer()
                else
                  _buildExerciseControls(currentExercise),
                const SizedBox(height: 20),
                _buildWorkoutProgress(),
              ],
            ),
          ),
        ),
        _buildWorkoutControls(),
      ],
    );
  }

  Widget _buildWorkoutTimer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDark,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            _formatDuration(_workoutDuration),
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _isPaused ? 'Paused' : 'Workout in Progress',
            style: TextStyle(
              color: AppColors.textPrimary.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentExercise(Map<String, dynamic> exercise) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDark,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            exercise['name'],
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            exercise['instructions'],
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildExerciseStat('Set', '$_currentSet / ${exercise['sets']}'),
              _buildExerciseStat(
                'Target',
                exercise['reps'] != null
                    ? '${exercise['reps']} reps'
                    : '${exercise['duration']}s',
              ),
              _buildExerciseStat('Completed', '$_repsCompleted'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseStat(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildRestTimer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'Rest Time',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '$_restTimeRemaining',
            style: const TextStyle(
              color: AppColors.warning,
              fontSize: 48,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'seconds',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _skipRest,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Skip Rest',
              style: TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseControls(Map<String, dynamic> exercise) {
    return Column(
      children: [
        if (exercise['reps'] != null)
          _buildRepsControls()
        else
          _buildDurationControls(exercise),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _completeSet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Complete Set',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _skipExercise,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.textSecondary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Skip Exercise',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRepsControls() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'Reps Completed',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: _decreaseReps,
                icon: const Icon(Icons.remove_circle, color: AppColors.error),
                iconSize: 40,
              ),
              Text(
                '$_repsCompleted',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: _increaseReps,
                icon: const Icon(Icons.add_circle, color: AppColors.success),
                iconSize: 40,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDurationControls(Map<String, dynamic> exercise) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            'Hold for ${exercise['duration']} seconds',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _startDurationTimer,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Start Timer',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutProgress() {
    final progress = (_currentExerciseIndex +
            (_currentSet - 1) / _exercises[_currentExerciseIndex]['sets']) /
        _exercises.length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progress',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${(progress * 100).toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: AppColors.primaryBlue,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.textSecondary.withOpacity(0.2),
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowDark,
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _isPaused ? _resumeWorkout : _pauseWorkout,
              icon: Icon(_isPaused ? Icons.play_arrow : Icons.pause),
              label: Text(_isPaused ? 'Resume' : 'Pause'),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isPaused ? AppColors.success : AppColors.warning,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: _endWorkout,
              icon: const Icon(Icons.stop),
              label: const Text('End Workout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutComplete() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.emoji_events,
              size: 80,
              color: AppColors.success,
            ),
            const SizedBox(height: 20),
            const Text(
              'Workout Complete!',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Great job! You completed ${_exercises.length} exercises.',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveWorkout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Workout',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const MainNavigation()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.textSecondary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Back to Home',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getWorkoutIcon() {
    switch (widget.workoutType.toLowerCase()) {
      case 'push-ups':
        return Icons.fitness_center;
      case 'plank':
        return Icons.timer;
      case 'cardio':
        return Icons.directions_run;
      default:
        return Icons.fitness_center;
    }
  }

  int _calculateEstimatedDuration() {
    int totalDuration = 0;
    for (var exercise in _exercises) {
      final sets = (exercise['sets'] as int? ?? 1);
      final exerciseTime = (exercise['duration'] as int? ??
          ((exercise['reps'] as int? ?? 10) * 3)); // 3 seconds per rep
      final restTime = ((exercise['restTime'] as int? ?? 60) * (sets - 1));
      totalDuration += exerciseTime * sets + restTime;
    }
    return (totalDuration / 60).ceil();
  }

  void _startWorkout() {
    setState(() {
      _isWorkoutActive = true;
    });
    _workoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _workoutDuration = Duration(seconds: _workoutDuration.inSeconds + 1);
      });
    });
    _animationController.forward();
  }

  void _pauseWorkout() {
    setState(() {
      _isPaused = true;
    });
    _workoutTimer?.cancel();
  }

  void _resumeWorkout() {
    setState(() {
      _isPaused = false;
    });
    _workoutTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _workoutDuration = Duration(seconds: _workoutDuration.inSeconds + 1);
      });
    });
  }

  void _endWorkout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'End Workout',
          style: TextStyle(color: AppColors.error),
        ),
        content: const Text(
          'Are you sure you want to end this workout? Your progress will be saved.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _saveWorkout();
            },
            child: const Text(
              'End Workout',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _completeSet() {
    setState(() {
      _repsCompleted = 0;
      _currentSet++;

      if (_currentSet > _exercises[_currentExerciseIndex]['sets']) {
        _completedExercises.add(_exercises[_currentExerciseIndex]);
        _currentExerciseIndex++;
        _currentSet = 1;

        if (_currentExerciseIndex < _exercises.length) {
          _startRestTimer();
        }
      } else {
        _startRestTimer();
      }
    });
  }

  void _skipExercise() {
    setState(() {
      _currentExerciseIndex++;
      _currentSet = 1;
      _repsCompleted = 0;
    });
  }

  void _increaseReps() {
    setState(() {
      _repsCompleted++;
    });
  }

  void _decreaseReps() {
    if (_repsCompleted > 0) {
      setState(() {
        _repsCompleted--;
      });
    }
  }

  void _startDurationTimer() {
    // Implement duration timer logic
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Duration timer started!')),
    );
  }

  void _startRestTimer() {
    final restTime = _exercises[_currentExerciseIndex]['restTime'] ?? 60;
    setState(() {
      _restTimeRemaining = restTime;
    });

    _restTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _restTimeRemaining--;
      });

      if (_restTimeRemaining <= 0) {
        timer.cancel();
        setState(() {
          _restTimeRemaining = 0;
        });
      }
    });
  }

  void _skipRest() {
    _restTimer?.cancel();
    setState(() {
      _restTimeRemaining = 0;
    });
  }

  void _saveWorkout() async {
    try {
      final exerciseData = jsonEncode(_completedExercises);
      await DatabaseHelper.instance.createWorkout(
        1,
        widget.workoutType,
        30, // Duration will be calculated from actual time
        200, // Calories will be calculated
        exerciseData: exerciseData,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Workout saved successfully!')),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigation()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving workout: $e')),
      );
    }
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Exit Workout',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Are you sure you want to exit? Your progress will be lost.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              'Exit',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }
}
