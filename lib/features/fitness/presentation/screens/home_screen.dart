import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fitness_tracker_app/core/theme/app_colors.dart';
import 'package:fitness_tracker_app/core/constants/app_constants.dart';
import 'package:fitness_tracker_app/features/fitness/presentation/providers/fitness_providers.dart';
import 'package:fitness_tracker_app/features/fitness/presentation/widgets/stats_card.dart';
import 'package:fitness_tracker_app/features/fitness/presentation/widgets/quick_actions.dart';
import 'package:fitness_tracker_app/features/fitness/presentation/widgets/recent_workouts.dart';
import 'package:fitness_tracker_app/features/fitness/presentation/widgets/streak_widget.dart';
import 'package:fitness_tracker_app/features/fitness/presentation/widgets/progress_chart.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final workoutsAsync = ref.watch(workoutsProvider);
    final statsAsync = ref.watch(workoutStatsProvider);
    final userProfileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(workoutsProvider);
            ref.invalidate(workoutStatsProvider);
            ref.invalidate(userProfileProvider);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(context, userProfileAsync),
                const SizedBox(height: AppConstants.largePadding),
                
                // Stats Cards
                statsAsync.when(
                  data: (stats) => _buildStatsSection(context, stats),
                  loading: () => _buildStatsLoading(),
                  error: (error, stack) => _buildErrorWidget(error.toString()),
                ),
                
                const SizedBox(height: AppConstants.largePadding),
                
                // Streak Widget
                statsAsync.when(
                  data: (stats) => StreakWidget(streakDays: stats['streakDays'] ?? 0),
                  loading: () => const SizedBox.shrink(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
                
                const SizedBox(height: AppConstants.largePadding),
                
                // Quick Actions
                const QuickActions(),
                
                const SizedBox(height: AppConstants.largePadding),
                
                // Recent Workouts
                workoutsAsync.when(
                  data: (workouts) => RecentWorkouts(workouts: workouts),
                  loading: () => _buildWorkoutsLoading(),
                  error: (error, stack) => _buildErrorWidget(error.toString()),
                ),
                
                const SizedBox(height: AppConstants.largePadding),
                
                // Progress Chart
                workoutsAsync.when(
                  data: (workouts) => ProgressChart(workouts: workouts),
                  loading: () => _buildChartLoading(),
                  error: (_, __) => const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AsyncValue userProfileAsync) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back!',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            userProfileAsync.when(
              data: (profile) => Text(
                profile?.name ?? 'Fitness Enthusiast',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              loading: () => Text(
                'Loading...',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              error: (_, __) => Text(
                'Fitness Enthusiast',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            FontAwesomeIcons.dumbbell,
            color: AppColors.primary,
            size: 24,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection(BuildContext context, Map<String, int> stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Progress',
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
              child: StatsCard(
                title: 'Steps',
                value: stats['totalSteps']?.toString() ?? '0',
                icon: FontAwesomeIcons.walking,
                color: AppColors.steps,
                subtitle: 'Goal: 10,000',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatsCard(
                title: 'Push-ups',
                value: stats['totalPushUps']?.toString() ?? '0',
                icon: FontAwesomeIcons.dumbbell,
                color: AppColors.pushUps,
                subtitle: 'Goal: 50',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatsCard(
                title: 'Plank',
                value: '${(stats['totalPlankDuration'] ?? 0) ~/ 60}m',
                icon: FontAwesomeIcons.stopwatch,
                color: AppColors.plank,
                subtitle: 'Goal: 1m',
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatsCard(
                title: 'Lungs',
                value: '${(stats['totalLungsDuration'] ?? 0) ~/ 60}m',
                icon: FontAwesomeIcons.lungs,
                color: AppColors.lungs,
                subtitle: 'Goal: 1m',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsLoading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Progress',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
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
      height: 100,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildWorkoutsLoading() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Workouts',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...List.generate(3, (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildShimmerCard(),
        )),
      ],
    );
  }

  Widget _buildChartLoading() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }

  Widget _buildErrorWidget(String error) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
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
}
