import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import 'main_navigation.dart';

class GoalsManagementScreen extends ConsumerStatefulWidget {
  const GoalsManagementScreen({super.key});

  @override
  ConsumerState<GoalsManagementScreen> createState() =>
      _GoalsManagementScreenState();
}

class _GoalsManagementScreenState extends ConsumerState<GoalsManagementScreen> {
  final TextEditingController _goalTitleController = TextEditingController();
  final TextEditingController _targetValueController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _selectedGoalType = 'Steps';
  String _selectedUnit = 'steps';
  String _selectedFrequency = 'Daily';
  DateTime _selectedEndDate = DateTime.now().add(const Duration(days: 30));
  bool _isLoading = false;

  List<GoalItem> _goals = [];

  @override
  void initState() {
    super.initState();
    _loadGoals();
  }

  @override
  void dispose() {
    _goalTitleController.dispose();
    _targetValueController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _loadGoals() {
    setState(() {
      _isLoading = true;
    });

    // Simulate loading goals
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _goals = [
          GoalItem(
            id: '1',
            title: 'Daily Steps Goal',
            description: 'Walk 10,000 steps every day',
            goalType: 'Steps',
            targetValue: 10000,
            currentValue: 7500,
            unit: 'steps',
            frequency: 'Daily',
            endDate: DateTime.now().add(const Duration(days: 7)),
            isActive: true,
            progress: 0.75,
          ),
          GoalItem(
            id: '2',
            title: 'Weekly Push-ups',
            description: 'Complete 200 push-ups this week',
            goalType: 'Push-ups',
            targetValue: 200,
            currentValue: 120,
            unit: 'reps',
            frequency: 'Weekly',
            endDate: DateTime.now().add(const Duration(days: 3)),
            isActive: true,
            progress: 0.6,
          ),
          GoalItem(
            id: '3',
            title: 'Monthly Plank Challenge',
            description: 'Hold plank for 5 minutes total this month',
            goalType: 'Plank',
            targetValue: 300,
            currentValue: 180,
            unit: 'seconds',
            frequency: 'Monthly',
            endDate: DateTime.now().add(const Duration(days: 15)),
            isActive: true,
            progress: 0.6,
          ),
          GoalItem(
            id: '4',
            title: 'Weight Loss Goal',
            description: 'Lose 5 pounds in 2 months',
            goalType: 'Weight',
            targetValue: 5,
            currentValue: 2.5,
            unit: 'lbs',
            frequency: 'Custom',
            endDate: DateTime.now().add(const Duration(days: 45)),
            isActive: true,
            progress: 0.5,
          ),
        ];
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text(
          'Goals Management',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
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
          IconButton(
            icon: const Icon(Icons.add, color: AppColors.textPrimary),
            onPressed: _showAddGoalDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppColors.primaryBlue,
              ),
            )
          : _goals.isEmpty
              ? _buildEmptyState()
              : Column(
                  children: [
                    _buildGoalsSummary(),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _goals.length,
                        itemBuilder: (context, index) {
                          return _buildGoalCard(_goals[index]);
                        },
                      ),
                    ),
                  ],
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGoalDialog,
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: AppColors.textPrimary),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.flag_outlined,
            size: 80,
            color: AppColors.textSecondary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Goals Set',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create your first fitness goal!',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _showAddGoalDialog,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Create Goal',
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

  Widget _buildGoalsSummary() {
    final activeGoals = _goals.where((goal) => goal.isActive).length;
    final completedGoals = _goals.where((goal) => goal.progress >= 1.0).length;
    final totalProgress = _goals.isNotEmpty
        ? _goals.map((goal) => goal.progress).reduce((a, b) => a + b) /
            _goals.length
        : 0.0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.cardGradient,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSummaryItem(
                icon: Icons.flag,
                label: 'Active Goals',
                value: activeGoals.toString(),
                color: AppColors.primaryBlue,
              ),
              _buildSummaryItem(
                icon: Icons.check_circle,
                label: 'Completed',
                value: completedGoals.toString(),
                color: AppColors.success,
              ),
              _buildSummaryItem(
                icon: Icons.trending_up,
                label: 'Avg Progress',
                value: '${(totalProgress * 100).toStringAsFixed(0)}%',
                color: AppColors.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildGoalCard(GoalItem goal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    goal.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleGoalAction(value, goal),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Text('Edit'),
                    ),
                    const PopupMenuItem(
                      value: 'toggle',
                      child: Text('Toggle Active'),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
            if (goal.description.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                goal.description,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  _getGoalIcon(goal.goalType),
                  color: AppColors.primaryBlue,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  '${goal.currentValue.toInt()} / ${goal.targetValue.toInt()} ${goal.unit}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(goal.progress * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: goal.progress.clamp(0.0, 1.0),
              backgroundColor: AppColors.textSecondary.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                goal.progress >= 1.0
                    ? AppColors.success
                    : AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Due: ${_formatDate(goal.endDate)}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: goal.isActive
                        ? AppColors.success
                        : AppColors.textSecondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    goal.isActive ? 'Active' : 'Inactive',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getGoalIcon(String goalType) {
    switch (goalType.toLowerCase()) {
      case 'steps':
        return Icons.directions_walk;
      case 'push-ups':
        return Icons.fitness_center;
      case 'plank':
        return Icons.timer;
      case 'weight':
        return Icons.monitor_weight;
      default:
        return Icons.flag;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference < 0) {
      return 'Overdue';
    } else if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else {
      return '${difference} days left';
    }
  }

  void _showAddGoalDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Create New Goal',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _goalTitleController,
                decoration: const InputDecoration(
                  labelText: 'Goal Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedGoalType,
                decoration: const InputDecoration(
                  labelText: 'Goal Type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Steps', child: Text('Steps')),
                  DropdownMenuItem(value: 'Push-ups', child: Text('Push-ups')),
                  DropdownMenuItem(value: 'Plank', child: Text('Plank')),
                  DropdownMenuItem(value: 'Weight', child: Text('Weight')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedGoalType = value!;
                    _selectedUnit = _getUnitForGoalType(value);
                  });
                },
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _targetValueController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Target Value',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedFrequency,
                decoration: const InputDecoration(
                  labelText: 'Frequency',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Daily', child: Text('Daily')),
                  DropdownMenuItem(value: 'Weekly', child: Text('Weekly')),
                  DropdownMenuItem(value: 'Monthly', child: Text('Monthly')),
                  DropdownMenuItem(value: 'Custom', child: Text('Custom')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedFrequency = value!;
                  });
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: _createGoal,
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  String _getUnitForGoalType(String goalType) {
    switch (goalType.toLowerCase()) {
      case 'steps':
        return 'steps';
      case 'push-ups':
        return 'reps';
      case 'plank':
        return 'seconds';
      case 'weight':
        return 'lbs';
      default:
        return 'units';
    }
  }

  void _createGoal() {
    if (_goalTitleController.text.trim().isEmpty ||
        _targetValueController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields')),
      );
      return;
    }

    final newGoal = GoalItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: _goalTitleController.text.trim(),
      description: _descriptionController.text.trim(),
      goalType: _selectedGoalType,
      targetValue: double.tryParse(_targetValueController.text) ?? 0,
      currentValue: 0,
      unit: _selectedUnit,
      frequency: _selectedFrequency,
      endDate: _selectedEndDate,
      isActive: true,
      progress: 0.0,
    );

    setState(() {
      _goals.add(newGoal);
    });

    _goalTitleController.clear();
    _descriptionController.clear();
    _targetValueController.clear();

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Goal "${newGoal.title}" created successfully!')),
    );
  }

  void _handleGoalAction(String action, GoalItem goal) {
    switch (action) {
      case 'edit':
        _editGoal(goal);
        break;
      case 'toggle':
        _toggleGoal(goal);
        break;
      case 'delete':
        _deleteGoal(goal);
        break;
    }
  }

  void _editGoal(GoalItem goal) {
    _goalTitleController.text = goal.title;
    _descriptionController.text = goal.description;
    _targetValueController.text = goal.targetValue.toString();
    _selectedGoalType = goal.goalType;
    _selectedUnit = goal.unit;
    _selectedFrequency = goal.frequency;
    _selectedEndDate = goal.endDate;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Edit Goal',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _goalTitleController,
                decoration: const InputDecoration(
                  labelText: 'Goal Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Description (Optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _targetValueController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Target Value',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                goal.title = _goalTitleController.text.trim();
                goal.description = _descriptionController.text.trim();
                goal.targetValue =
                    double.tryParse(_targetValueController.text) ??
                        goal.targetValue;
                goal.progress = goal.currentValue / goal.targetValue;
              });
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _toggleGoal(GoalItem goal) {
    setState(() {
      goal.isActive = !goal.isActive;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          goal.isActive
              ? 'Goal "${goal.title}" activated'
              : 'Goal "${goal.title}" deactivated',
        ),
      ),
    );
  }

  void _deleteGoal(GoalItem goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        title: const Text(
          'Delete Goal',
          style: TextStyle(color: AppColors.error),
        ),
        content: Text(
          'Are you sure you want to delete "${goal.title}"? This action cannot be undone.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _goals.removeWhere((g) => g.id == goal.id);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Goal "${goal.title}" deleted')),
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}

class GoalItem {
  final String id;
  String title;
  String description;
  String goalType;
  double targetValue;
  double currentValue;
  String unit;
  String frequency;
  DateTime endDate;
  bool isActive;
  double progress;

  GoalItem({
    required this.id,
    required this.title,
    required this.description,
    required this.goalType,
    required this.targetValue,
    required this.currentValue,
    required this.unit,
    required this.frequency,
    required this.endDate,
    required this.isActive,
    required this.progress,
  });
}
