import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fitness_tracker_app/core/theme/app_colors.dart';
import 'package:fitness_tracker_app/core/constants/app_constants.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                'Add Workout',
                FontAwesomeIcons.plus,
                AppColors.primary,
                () => _showAddWorkoutDialog(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                context,
                'Water Intake',
                FontAwesomeIcons.glassWater,
                AppColors.water,
                () => _navigateToWaterTracker(context),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                'BMI Calculator',
                FontAwesomeIcons.weight,
                AppColors.accent,
                () => _navigateToBMICalculator(context),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionButton(
                context,
                'Profile',
                FontAwesomeIcons.user,
                AppColors.secondary,
                () => _navigateToProfile(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showAddWorkoutDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Add Workout',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildWorkoutOption(
              context,
              'Push-ups',
              FontAwesomeIcons.dumbbell,
              AppColors.pushUps,
              () => _navigateToPushUps(context),
            ),
            const SizedBox(height: 12),
            _buildWorkoutOption(
              context,
              'Plank',
              FontAwesomeIcons.stopwatch,
              AppColors.plank,
              () => _navigateToPlank(context),
            ),
            const SizedBox(height: 12),
            _buildWorkoutOption(
              context,
              'Steps',
              FontAwesomeIcons.walking,
              AppColors.steps,
              () => _navigateToSteps(context),
            ),
            const SizedBox(height: 12),
            _buildWorkoutOption(
              context,
              'Lungs Test',
              FontAwesomeIcons.lungs,
              AppColors.lungs,
              () => _navigateToLungs(context),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkoutOption(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToWaterTracker(BuildContext context) {
    // TODO: Navigate to water tracker
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Water Tracker - Coming Soon!')),
    );
  }

  void _navigateToBMICalculator(BuildContext context) {
    // TODO: Navigate to BMI calculator
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('BMI Calculator - Coming Soon!')),
    );
  }

  void _navigateToProfile(BuildContext context) {
    // TODO: Navigate to profile
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile - Coming Soon!')),
    );
  }

  void _navigateToPushUps(BuildContext context) {
    // TODO: Navigate to push-ups workout
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Push-ups Workout - Coming Soon!')),
    );
  }

  void _navigateToPlank(BuildContext context) {
    // TODO: Navigate to plank workout
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Plank Workout - Coming Soon!')),
    );
  }

  void _navigateToSteps(BuildContext context) {
    // TODO: Navigate to steps tracking
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Steps Tracking - Coming Soon!')),
    );
  }

  void _navigateToLungs(BuildContext context) {
    // TODO: Navigate to lungs test
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lungs Test - Coming Soon!')),
    );
  }
}
