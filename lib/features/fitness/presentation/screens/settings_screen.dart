import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import 'main_navigation.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = true;
  bool _stepTrackingEnabled = true;
  bool _workoutRemindersEnabled = true;
  String _selectedUnit = 'Metric';
  String _selectedLanguage = 'English';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        title: const Text(
          'Settings',
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('Account'),
            _buildSettingsCard([
              _buildSettingsTile(
                icon: Icons.person_outline,
                title: 'Profile Settings',
                subtitle: 'Manage your personal information',
                onTap: () => _navigateToProfileSettings(),
              ),
              _buildSettingsTile(
                icon: Icons.security_outlined,
                title: 'Privacy & Security',
                subtitle: 'Control your data and privacy',
                onTap: () => _navigateToPrivacySettings(),
              ),
              _buildSettingsTile(
                icon: Icons.logout,
                title: 'Sign Out',
                subtitle: 'Sign out of your account',
                onTap: () => _showSignOutDialog(),
                isDestructive: true,
              ),
            ]),
            const SizedBox(height: 24),
            _buildSectionHeader('Preferences'),
            _buildSettingsCard([
              _buildSwitchTile(
                icon: Icons.notifications_outlined,
                title: 'Push Notifications',
                subtitle: 'Receive workout reminders and updates',
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() {
                    _notificationsEnabled = value;
                  });
                },
              ),
              _buildSwitchTile(
                icon: Icons.dark_mode_outlined,
                title: 'Dark Mode',
                subtitle: 'Use dark theme throughout the app',
                value: _darkModeEnabled,
                onChanged: (value) {
                  setState(() {
                    _darkModeEnabled = value;
                  });
                },
              ),
              _buildSwitchTile(
                icon: Icons.directions_walk_outlined,
                title: 'Step Tracking',
                subtitle: 'Automatically track your daily steps',
                value: _stepTrackingEnabled,
                onChanged: (value) {
                  setState(() {
                    _stepTrackingEnabled = value;
                  });
                },
              ),
              _buildSwitchTile(
                icon: Icons.fitness_center_outlined,
                title: 'Workout Reminders',
                subtitle: 'Get reminded to complete your workouts',
                value: _workoutRemindersEnabled,
                onChanged: (value) {
                  setState(() {
                    _workoutRemindersEnabled = value;
                  });
                },
              ),
            ]),
            const SizedBox(height: 24),
            _buildSectionHeader('Units & Language'),
            _buildSettingsCard([
              _buildDropdownTile(
                icon: Icons.straighten_outlined,
                title: 'Measurement Units',
                subtitle: 'Choose your preferred unit system',
                value: _selectedUnit,
                items: ['Metric', 'Imperial'],
                onChanged: (value) {
                  setState(() {
                    _selectedUnit = value!;
                  });
                },
              ),
              _buildDropdownTile(
                icon: Icons.language_outlined,
                title: 'Language',
                subtitle: 'Select your preferred language',
                value: _selectedLanguage,
                items: ['English', 'Spanish', 'French', 'German'],
                onChanged: (value) {
                  setState(() {
                    _selectedLanguage = value!;
                  });
                },
              ),
            ]),
            const SizedBox(height: 24),
            _buildSectionHeader('Support'),
            _buildSettingsCard([
              _buildSettingsTile(
                icon: Icons.help_outline,
                title: 'Help & Support',
                subtitle: 'Get help and contact support',
                onTap: () => _navigateToHelp(),
              ),
              _buildSettingsTile(
                icon: Icons.info_outline,
                title: 'About',
                subtitle: 'App version and information',
                onTap: () => _showAboutDialog(),
              ),
              _buildSettingsTile(
                icon: Icons.star_outline,
                title: 'Rate App',
                subtitle: 'Rate us on the app store',
                onTap: () => _rateApp(),
              ),
            ]),
            const SizedBox(height: 24),
            _buildSectionHeader('Data'),
            _buildSettingsCard([
              _buildSettingsTile(
                icon: Icons.backup_outlined,
                title: 'Backup Data',
                subtitle: 'Backup your fitness data to cloud',
                onTap: () => _backupData(),
              ),
              _buildSettingsTile(
                icon: Icons.restore_outlined,
                title: 'Restore Data',
                subtitle: 'Restore data from backup',
                onTap: () => _restoreData(),
              ),
              _buildSettingsTile(
                icon: Icons.delete_outline,
                title: 'Clear All Data',
                subtitle: 'Permanently delete all your data',
                onTap: () => _showClearDataDialog(),
                isDestructive: true,
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
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
      child: Column(children: children),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isDestructive ? AppColors.error : AppColors.primaryBlue,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isDestructive ? AppColors.error : AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: AppColors.textSecondary,
        size: 16,
      ),
      onTap: onTap,
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.primaryBlue,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primaryBlue,
      ),
    );
  }

  Widget _buildDropdownTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.primaryBlue,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 12,
        ),
      ),
      trailing: DropdownButton<String>(
        value: value,
        onChanged: onChanged,
        underline: const SizedBox(),
        items: items.map((String item) {
          return DropdownMenuItem<String>(
            value: item,
            child: Text(
              item,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _navigateToProfileSettings() {
    // Navigate to profile settings screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile Settings - Coming Soon!')),
    );
  }

  void _navigateToPrivacySettings() {
    // Navigate to privacy settings screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Privacy Settings - Coming Soon!')),
    );
  }

  void _navigateToHelp() {
    // Navigate to help screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Help & Support - Coming Soon!')),
    );
  }

  void _showSignOutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBackground,
          title: const Text(
            'Sign Out',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: const Text(
            'Are you sure you want to sign out?',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                      builder: (context) => const MainNavigation()),
                );
              },
              child: const Text(
                'Sign Out',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'TrackFit',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(
        Icons.fitness_center,
        size: 48,
        color: AppColors.primaryBlue,
      ),
      children: [
        const Text('TrackFit - Your Personal Fitness Companion'),
        const SizedBox(height: 16),
        const Text(
            'Track your workouts, monitor your progress, and achieve your fitness goals with TrackFit.'),
      ],
    );
  }

  void _rateApp() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Thank you for your support!')),
    );
  }

  void _backupData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data backup initiated!')),
    );
  }

  void _restoreData() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Data restore initiated!')),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.cardBackground,
          title: const Text(
            'Clear All Data',
            style: TextStyle(color: AppColors.error),
          ),
          content: const Text(
            'This action cannot be undone. All your fitness data, workouts, and progress will be permanently deleted.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All data cleared!')),
                );
              },
              child: const Text(
                'Clear Data',
                style: TextStyle(color: AppColors.error),
              ),
            ),
          ],
        );
      },
    );
  }
}
