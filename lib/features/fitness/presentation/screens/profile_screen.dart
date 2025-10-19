import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fitness_tracker_app/core/theme/app_colors.dart';
import 'package:fitness_tracker_app/core/constants/app_constants.dart';
import 'package:fitness_tracker_app/features/fitness/presentation/providers/fitness_providers.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfileAsync = ref.watch(userProfileProvider);
    final statsAsync = ref.watch(workoutStatsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              _buildHeader(context, userProfileAsync),
              const SizedBox(height: AppConstants.largePadding),
              
              // Profile Card
              userProfileAsync.when(
                data: (profile) => _buildProfileCard(context, profile),
                loading: () => _buildProfileLoading(),
                error: (error, stack) => _buildErrorCard(context, error.toString()),
              ),
              
              const SizedBox(height: AppConstants.largePadding),
              
              // Stats Section
              statsAsync.when(
                data: (stats) => _buildStatsSection(context, stats),
                loading: () => _buildStatsLoading(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              
              const SizedBox(height: AppConstants.largePadding),
              
              // Settings Section
              _buildSettingsSection(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AsyncValue userProfileAsync) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Profile',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        IconButton(
          onPressed: () {
            // TODO: Implement settings
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Settings - Coming Soon!')),
            );
          },
          icon: const Icon(FontAwesomeIcons.gear),
        ),
      ],
    );
  }

  Widget _buildProfileCard(BuildContext context, userProfile) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.largePadding),
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
      child: Column(
        children: [
          // Profile Picture
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(40),
              border: Border.all(color: Colors.white, width: 3),
            ),
            child: const Icon(
              FontAwesomeIcons.user,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 16),
          
          // Name
          Text(
            userProfile?.name ?? 'Fitness Enthusiast',
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          
          // Bio
          Text(
            userProfile?.bio ?? 'Track your fitness journey',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          // Edit Profile Button
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Implement edit profile
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Edit Profile - Coming Soon!')),
              );
            },
            icon: const Icon(FontAwesomeIcons.penToSquare, size: 16),
            label: const Text('Edit Profile'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileLoading() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
      ),
    );
  }

  Widget _buildErrorCard(BuildContext context, String error) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.largePadding),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppConstants.largeBorderRadius),
        border: Border.all(color: AppColors.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(FontAwesomeIcons.exclamationTriangle, color: AppColors.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Error: $error',
              style: GoogleFonts.poppins(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context, Map<String, int> stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Stats',
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
              child: _buildStatCard(
                context,
                'Total Push-ups',
                stats['totalPushUps']?.toString() ?? '0',
                FontAwesomeIcons.dumbbell,
                AppColors.pushUps,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Total Steps',
                stats['totalSteps']?.toString() ?? '0',
                FontAwesomeIcons.walking,
                AppColors.steps,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Current Streak',
                '${stats['streakDays'] ?? 0} days',
                FontAwesomeIcons.fire,
                AppColors.accent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                context,
                'Workouts',
                '${stats['totalWorkouts'] ?? 0}',
                FontAwesomeIcons.chartLine,
                AppColors.secondary,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStatsLoading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 20,
          width: 100,
          color: Colors.grey[300],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _buildShimmerCard()),
            const SizedBox(width: 12),
            Expanded(child: _buildShimmerCard()),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: _buildShimmerCard()),
            const SizedBox(width: 12),
            Expanded(child: _buildShimmerCard()),
          ],
        ),
      ],
    );
  }

  Widget _buildShimmerCard() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        _buildSettingItem(
          context,
          'Notifications',
          FontAwesomeIcons.bell,
          () {},
        ),
        _buildSettingItem(
          context,
          'Privacy',
          FontAwesomeIcons.shield,
          () {},
        ),
        _buildSettingItem(
          context,
          'About',
          FontAwesomeIcons.info,
          () {},
        ),
        _buildSettingItem(
          context,
          'Help & Support',
          FontAwesomeIcons.questionCircle,
          () {},
        ),
      ],
    );
  }

  Widget _buildSettingItem(
    BuildContext context,
    String title,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withOpacity(0.1),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppColors.primary, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.3),
            ),
          ],
        ),
      ),
    );
  }
}
