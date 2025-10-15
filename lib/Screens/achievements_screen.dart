import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class AchievementsScreen extends StatefulWidget {
  final int totalPushups;
  final int totalSteps;
  final int streakDays;

  const AchievementsScreen({
    Key? key,
    required this.totalPushups,
    required this.totalSteps,
    required this.streakDays,
  }) : super(key: key);

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get achievements => [
        {
          'title': 'First Steps',
          'description': 'Complete your first workout',
          'icon': FontAwesomeIcons.shoePrints,
          'unlocked': widget.totalPushups > 0 || widget.totalSteps > 0,
          'color': Colors.blue,
        },
        {
          'title': 'Push Master',
          'description': 'Complete 100 push-ups',
          'icon': FontAwesomeIcons.dumbbell,
          'unlocked': widget.totalPushups >= 100,
          'color': Colors.orange,
        },
        {
          'title': 'Step Champion',
          'description': 'Walk 10,000 steps',
          'icon': FontAwesomeIcons.personWalking,
          'unlocked': widget.totalSteps >= 10000,
          'color': Colors.green,
        },
        {
          'title': 'Dedicated',
          'description': '7-day streak',
          'icon': FontAwesomeIcons.fire,
          'unlocked': widget.streakDays >= 7,
          'color': Colors.red,
        },
        {
          'title': 'Committed',
          'description': '30-day streak',
          'icon': FontAwesomeIcons.medal,
          'unlocked': widget.streakDays >= 30,
          'color': Colors.purple,
        },
        {
          'title': 'Push Elite',
          'description': 'Complete 500 push-ups',
          'icon': FontAwesomeIcons.trophy,
          'unlocked': widget.totalPushups >= 500,
          'color': Colors.amber,
        },
        {
          'title': 'Marathon Walker',
          'description': 'Walk 50,000 steps',
          'icon': FontAwesomeIcons.crown,
          'unlocked': widget.totalSteps >= 50000,
          'color': Colors.pink,
        },
        {
          'title': 'Legend',
          'description': '100-day streak',
          'icon': FontAwesomeIcons.star,
          'unlocked': widget.streakDays >= 100,
          'color': Colors.indigo,
        },
      ];

  @override
  Widget build(BuildContext context) {
    final unlockedCount = achievements.where((a) => a['unlocked']).length;

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(
          'Achievements',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.purple,
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple, Colors.purple.shade700],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Text(
                  '$unlockedCount / ${achievements.length}',
                  style: GoogleFonts.poppins(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Achievements Unlocked',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final achievement = achievements[index];
                final delay = index * 100;

                return SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(1, 0),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _controller,
                      curve: Interval(
                        delay / 1000,
                        (delay + 500) / 1000,
                        curve: Curves.easeOut,
                      ),
                    ),
                  ),
                  child: _buildAchievementCard(achievement),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(Map<String, dynamic> achievement) {
    final bool unlocked = achievement['unlocked'];

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: unlocked ? Colors.white : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: unlocked
                ? achievement['color'].withOpacity(0.3)
                : Colors.black12,
            blurRadius: unlocked ? 15 : 5,
            offset: Offset(0, unlocked ? 8 : 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        leading: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: unlocked
                ? achievement['color'].withOpacity(0.2)
                : Colors.grey.shade400,
            shape: BoxShape.circle,
          ),
          child: Icon(
            achievement['icon'],
            color: unlocked ? achievement['color'] : Colors.grey.shade600,
            size: 28,
          ),
        ),
        title: Text(
          achievement['title'],
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: unlocked ? Colors.black87 : Colors.grey.shade600,
          ),
        ),
        subtitle: Text(
          achievement['description'],
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: unlocked ? Colors.black54 : Colors.grey.shade500,
          ),
        ),
        trailing: unlocked
            ? Icon(Icons.check_circle, color: achievement['color'], size: 32)
            : Icon(Icons.lock, color: Colors.grey.shade500, size: 32),
      ),
    );
  }
}

