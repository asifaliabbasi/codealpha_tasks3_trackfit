import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fitness_tracker_app/core/theme/app_colors.dart';
import 'package:fitness_tracker_app/core/constants/app_constants.dart';

class StreakWidget extends StatelessWidget {
  final int streakDays;

  const StreakWidget({
    super.key,
    required this.streakDays,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: AppColors.primaryGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              FontAwesomeIcons.fire,
              color: Colors.white,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Streak',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$streakDays ${streakDays == 1 ? 'day' : 'days'}',
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getStreakMessage(streakDays),
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          if (streakDays > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    FontAwesomeIcons.trophy,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _getStreakLevel(streakDays),
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _getStreakMessage(int days) {
    if (days == 0) {
      return 'Start your fitness journey today!';
    } else if (days == 1) {
      return 'Great start! Keep it up!';
    } else if (days < 7) {
      return 'You\'re building momentum!';
    } else if (days < 30) {
      return 'Amazing consistency!';
    } else if (days < 100) {
      return 'You\'re a fitness champion!';
    } else {
      return 'Legendary dedication!';
    }
  }

  String _getStreakLevel(int days) {
    if (days < 3) return 'Beginner';
    if (days < 7) return 'Rookie';
    if (days < 14) return 'Intermediate';
    if (days < 30) return 'Advanced';
    if (days < 100) return 'Expert';
    return 'Master';
  }
}
