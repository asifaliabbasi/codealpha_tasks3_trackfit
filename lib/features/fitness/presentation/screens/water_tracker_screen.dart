import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../Database/DataBase_Helper.dart';
import 'main_navigation.dart';

class WaterTrackerScreen extends ConsumerStatefulWidget {
  const WaterTrackerScreen({super.key});

  @override
  ConsumerState<WaterTrackerScreen> createState() => _WaterTrackerScreenState();
}

class _WaterTrackerScreenState extends ConsumerState<WaterTrackerScreen>
    with TickerProviderStateMixin {
  int _waterIntake = 0;
  int _dailyGoal = 2000; // Default goal in ml
  bool _isLoading = true;
  List<Map<String, dynamic>> _weeklyData = [];

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    _loadWaterData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadWaterData() async {
    setState(() => _isLoading = true);

    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final dailyActivity =
          await DatabaseHelper.instance.getDailyActivity(1, today);

      if (dailyActivity != null) {
        _waterIntake = dailyActivity['water_intake_ml'] ?? 0;
      }

      // Load weekly data for chart
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));
      final weeklyActivities =
          await DatabaseHelper.instance.getDailyActivitiesRange(
        1,
        weekAgo.toIso8601String().split('T')[0],
        today,
      );

      setState(() {
        _weeklyData = weeklyActivities;
        _isLoading = false;
      });

      _animationController.forward();
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading water data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text(
          'Water Tracker',
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
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primaryBlue))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildWaterGlass(),
                  const SizedBox(height: 24),
                  _buildQuickAddButtons(),
                  const SizedBox(height: 24),
                  _buildProgressCard(),
                  const SizedBox(height: 24),
                  _buildWeeklyChart(),
                  const SizedBox(height: 24),
                  _buildTipsCard(),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    final progress = _dailyGoal > 0 ? _waterIntake / _dailyGoal : 0.0;
    final percentage = (progress * 100).clamp(0.0, 100.0);

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
            Icons.water_drop,
            size: 60,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: 12),
          const Text(
            'Stay Hydrated!',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${_waterIntake}ml / ${_dailyGoal}ml (${percentage.toStringAsFixed(0)}%)',
            style: TextStyle(
              color: AppColors.textPrimary.withOpacity(0.8),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterGlass() {
    final progress = _dailyGoal > 0 ? _waterIntake / _dailyGoal : 0.0;
    final fillLevel = progress.clamp(0.0, 1.0);

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: 200,
        height: 300,
        decoration: BoxDecoration(
          gradient: AppColors.cardGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowDark,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Glass outline
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.primaryBlue,
                  width: 3,
                ),
              ),
            ),
            // Water fill
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                height: 300 * fillLevel,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryBlue.withOpacity(0.8),
                      AppColors.primaryBlue.withOpacity(0.6),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Center(
                  child: Text(
                    '${(_waterIntake / 1000).toStringAsFixed(1)}L',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            // Glass handle
            Positioned(
              right: -15,
              top: 50,
              child: Container(
                width: 30,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAddButtons() {
    return Container(
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
          const Text(
            'Quick Add',
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
              _buildQuickAddButton(250, 'Small Glass'),
              _buildQuickAddButton(500, 'Large Glass'),
              _buildQuickAddButton(750, 'Bottle'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAddButton(int amount, String label) {
    return GestureDetector(
      onTap: () => _addWater(amount),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          gradient: AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowDark,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.water_drop,
              color: AppColors.textPrimary,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              '${amount}ml',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard() {
    final progress = _dailyGoal > 0 ? _waterIntake / _dailyGoal : 0.0;
    final isGoalReached = _waterIntake >= _dailyGoal;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: isGoalReached
            ? LinearGradient(
                colors: [AppColors.success, AppColors.success.withOpacity(0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : AppColors.cardGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isGoalReached
                ? AppColors.success.withOpacity(0.3)
                : AppColors.shadowDark,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Daily Progress',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isGoalReached)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.success,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'GOAL REACHED!',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: AppColors.textSecondary.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(
              isGoalReached ? AppColors.success : AppColors.primaryBlue,
            ),
            minHeight: 12,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_waterIntake}ml',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${_dailyGoal}ml',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart() {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weekly Progress',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 7,
              itemBuilder: (context, index) {
                final date = DateTime.now().subtract(Duration(days: 6 - index));
                final dayData = _weeklyData.firstWhere(
                  (data) =>
                      data['date'] == date.toIso8601String().split('T')[0],
                  orElse: () => {'water_intake_ml': 0},
                );
                final waterAmount = dayData['water_intake_ml'] ?? 0;
                final progress =
                    _dailyGoal > 0 ? waterAmount / _dailyGoal : 0.0;

                return _buildDayBar(
                  _getDayName(date.weekday),
                  progress,
                  waterAmount,
                  date.day,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayBar(
      String dayName, double progress, int waterAmount, int dayNumber) {
    return Container(
      width: 50,
      margin: const EdgeInsets.only(right: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            '${(waterAmount / 1000).toStringAsFixed(1)}L',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Expanded(
            child: Container(
              width: 30,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  height: 80 * progress.clamp(0.0, 1.0),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            dayName,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
          ),
          Text(
            dayNumber.toString(),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsCard() {
    return Container(
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Hydration Tips',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildTipItem(
            'Start your day with a glass of water',
            Icons.wb_sunny,
            AppColors.warning,
          ),
          _buildTipItem(
            'Keep a water bottle nearby',
            Icons.local_drink,
            AppColors.info,
          ),
          _buildTipItem(
            'Eat water-rich foods like fruits',
            Icons.apple,
            AppColors.success,
          ),
          _buildTipItem(
            'Listen to your body\'s thirst signals',
            Icons.hearing,
            AppColors.primaryBlue,
          ),
        ],
      ),
    );
  }

  Widget _buildTipItem(String tip, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              tip,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  Future<void> _addWater(int amount) async {
    setState(() {
      _waterIntake += amount;
    });

    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      await DatabaseHelper.instance.updateDailyActivity(1, today, {
        'water_intake_ml': _waterIntake,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Added ${amount}ml of water!'),
          backgroundColor: AppColors.success,
        ),
      );

      // Check if goal is reached
      if (_waterIntake >= _dailyGoal) {
        _showGoalReachedDialog();
      }
    } catch (e) {
      setState(() {
        _waterIntake -= amount; // Revert on error
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding water: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showGoalReachedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.cardBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(Icons.celebration, color: AppColors.success, size: 28),
            const SizedBox(width: 8),
            const Text(
              'Goal Reached!',
              style: TextStyle(color: AppColors.success),
            ),
          ],
        ),
        content: const Text(
          'Congratulations! You\'ve reached your daily water intake goal. Keep up the great work!',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Awesome!'),
          ),
        ],
      ),
    );
  }
}
