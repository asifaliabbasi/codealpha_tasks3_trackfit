import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:fitness_tracker_app/core/theme/app_colors.dart';
import 'package:fitness_tracker_app/features/fitness/presentation/screens/home_screen.dart';
import 'package:fitness_tracker_app/features/fitness/presentation/screens/workout_screen.dart';
import 'package:fitness_tracker_app/features/fitness/presentation/screens/profile_screen.dart';

class MainNavigation extends ConsumerStatefulWidget {
  const MainNavigation({super.key});

  @override
  ConsumerState<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends ConsumerState<MainNavigation> {
  int _currentIndex = 0;

  final List<NavigationItem> _navigationItems = [
    NavigationItem(
      icon: FontAwesomeIcons.house,
      activeIcon: FontAwesomeIcons.house,
      label: 'Home',
      screen: const HomeScreen(),
    ),
    NavigationItem(
      icon: FontAwesomeIcons.dumbbell,
      activeIcon: FontAwesomeIcons.dumbbell,
      label: 'Workouts',
      screen: const WorkoutScreen(),
    ),
    NavigationItem(
      icon: FontAwesomeIcons.user,
      activeIcon: FontAwesomeIcons.user,
      label: 'Profile',
      screen: const ProfileScreen(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _navigationItems.map((item) => item.screen).toList(),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _navigationItems.asMap().entries.map((entry) {
                final index = entry.key;
                final item = entry.value;
                final isSelected = _currentIndex == index;
                
                return Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? AppColors.primary.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? AppColors.primary
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              isSelected ? item.activeIcon : item.icon,
                              color: isSelected 
                                  ? Colors.white
                                  : theme.colorScheme.onSurface.withOpacity(0.6),
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            item.label,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              fontWeight: isSelected 
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: isSelected 
                                  ? AppColors.primary
                                  : theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}

class NavigationItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final Widget screen;

  const NavigationItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.screen,
  });
}
