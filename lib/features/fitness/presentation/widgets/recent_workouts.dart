import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fitness_tracker_app/core/theme/app_colors.dart';
import 'package:fitness_tracker_app/core/constants/app_constants.dart';
import 'package:fitness_tracker_app/features/fitness/domain/entities/workout.dart';

class RecentWorkouts extends StatelessWidget {
  final List<Workout> workouts;

  const RecentWorkouts({
    super.key,
    required this.workouts,
  });

  @override
  Widget build(BuildContext context) {
    final recentWorkouts = workouts.take(5).toList();
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Recent Workouts',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            if (workouts.length > 5)
              TextButton(
                onPressed: () => _navigateToWorkoutHistory(context),
                child: Text(
                  'View All',
                  style: GoogleFonts.poppins(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (recentWorkouts.isEmpty)
          _buildEmptyState(context)
        else
          ...recentWorkouts.map((workout) => _buildWorkoutCard(context, workout)),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            FontAwesomeIcons.dumbbell,
            size: 48,
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No workouts yet',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start your fitness journey by adding your first workout!',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutCard(BuildContext context, Workout workout) {
    final theme = Theme.of(context);
    final hasActivity = workout.hasActivity;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              FontAwesomeIcons.dumbbell,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatWorkoutDate(workout.date),
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                if (hasActivity) ...[
                  _buildActivityRow(
                    FontAwesomeIcons.dumbbell,
                    '${workout.pushUps} push-ups',
                    AppColors.pushUps,
                  ),
                  if (workout.steps > 0) ...[
                    const SizedBox(height: 2),
                    _buildActivityRow(
                      FontAwesomeIcons.walking,
                      '${workout.steps} steps',
                      AppColors.steps,
                    ),
                  ],
                  if (workout.plankDuration > 0) ...[
                    const SizedBox(height: 2),
                    _buildActivityRow(
                      FontAwesomeIcons.stopwatch,
                      '${workout.plankDuration ~/ 60}m plank',
                      AppColors.plank,
                    ),
                  ],
                  if (workout.lungsDuration > 0) ...[
                    const SizedBox(height: 2),
                    _buildActivityRow(
                      FontAwesomeIcons.lungs,
                      '${workout.lungsDuration ~/ 60}m lungs',
                      AppColors.lungs,
                    ),
                  ],
                ] else ...[
                  Text(
                    'No activities recorded',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityRow(IconData icon, String text, Color color) {
    return Row(
      children: [
        Icon(icon, size: 12, color: color),
        const SizedBox(width: 6),
        Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatWorkoutDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final workoutDay = DateTime(date.year, date.month, date.day);
    
    if (workoutDay.isAtSameMomentAs(today)) {
      return 'Today';
    } else if (workoutDay.isAtSameMomentAs(today.subtract(const Duration(days: 1)))) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _navigateToWorkoutHistory(BuildContext context) {
    // TODO: Navigate to workout history
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Workout History - Coming Soon!')),
    );
  }
}
