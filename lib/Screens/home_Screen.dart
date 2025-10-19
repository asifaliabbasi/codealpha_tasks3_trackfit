import 'dart:async';

import 'package:fitness_tracker_app/Screens/exercises_History.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pedometer/pedometer.dart';
import 'package:flutter/services.dart';
import 'package:confetti/confetti.dart';
import '../Database/DataBase_Helper.dart';
import '../widgets/animated_counter.dart';
import '../widgets/weekly_chart.dart';
import '../widgets/streak_widget.dart';
import 'achievements_screen.dart';
import 'bmi_calculator.dart';
import 'water_tracker.dart';
import 'profile_screen.dart';
import 'Exercises/plank.dart';
import 'Exercises/lungs_Breath.dart';
import 'Exercises/pushUps.dart';
import 'Exercises/steps.dart';

class Fitness_Tracker extends StatefulWidget {
  @override
  _Fitness_TrackerState createState() => _Fitness_TrackerState();
}

class _Fitness_TrackerState extends State<Fitness_Tracker> {
  int currentIndex = 0; // Track the selected tab index

  List<Map<String, dynamic>> _fitnessScore = [];
  Future<void> _loadFitnessTrack() async {
    final List<Map<String, dynamic>> data =
        await DatabaseHelper.instance.getFitness();
    if (mounted) {
      setState(() {
        _fitnessScore = data;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadFitnessTrack();
  }

  final List<Widget> screens = [
    Dashboard(),
    Workout_Screen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex], // Display the selected screen
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.grey[200],
        selectedItemColor: Colors.redAccent,
        unselectedItemColor: Colors.black,
        currentIndex: currentIndex, // Track selected tab
        // Fitts' Law: Larger touch targets for navigation
        type: BottomNavigationBarType.fixed,
        iconSize: 28, // Larger icons for better visibility
        selectedFontSize: 14,
        unselectedFontSize: 12,
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Dashboard"),
          BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center), label: "Goals"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}

//DashBoard Screen
class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> with TickerProviderStateMixin {
  late Stream<StepCount> _stepCountStream;
  int totalPlank = 0;
  int totalLungs = 0;
  int totalPushups = 0;
  int totalSteps = 0;
  int streakDays = 0;
  late ConfettiController _confettiController;

  void _calculateTotals() {
    totalPlank = 0;
    totalLungs = 0;
    totalPushups = 0;
    totalSteps = 0;

    for (var fitnessData in _fitnessScore) {
      totalPlank += int.tryParse(fitnessData['plank']) ?? 0;
      totalLungs += int.tryParse(fitnessData['lungs']) ?? 0;
      totalPushups += (fitnessData['pushups'] ?? 0) as int;
      totalSteps += (fitnessData['steps'] ?? 0) as int;
      print('Steps are: $totalSteps');
      setState(() {});
    }

    setState(() {});
  }

  String formatTime(int seconds) {
    int minutes = (seconds / 60).floor();
    int remainingSeconds = seconds % 60;
    return '$minutes ${minutes == 1 ? '' : 'm'} : $remainingSeconds ${remainingSeconds == 1 ? '' : 's'}';
  }

  //Database functions
  List<Map<String, dynamic>> _fitnessScore = [];
  Future<void> _loadFitnessTrack() async {
    final List<Map<String, dynamic>> data =
        await DatabaseHelper.instance.getFitness();
    if (mounted) {
      setState(() {
        _fitnessScore = data;
        _calculateTotals();
        _calculateStreak();
      });
    }
  }

  Future<void> _addFitnessTrack(
      String Tplank, String Tlungs, int Tpushups, int Tsteps) async {
    try {
      await DatabaseHelper.instance
          .saveWorkouts(Tpushups, Tplank, Tlungs, Tsteps);
      await _loadFitnessTrack(); // Ensure Track reload after adding a new one
    } catch (e) {
      print('Error adding fitness track: $e');
    }
  }

  int pushUpsGoal = 0;
  int stepsGoal = 0;

  List<Map<String, dynamic>> _fitnessGoals = [];
  Future<void> _loadGoals() async {
    final List<Map<String, dynamic>> data =
        await DatabaseHelper.instance.getGoals();
    if (mounted) {
      setState(() {
        _fitnessGoals = data;
      });
    }
  }

  TextEditingController timeMDuration = TextEditingController();
  TextEditingController timeSDuration = TextEditingController();
  TextEditingController _pushUps = TextEditingController();

  void startPlank() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Plank"),
          content: Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Get ready to do Plank!"),
                SizedBox(height: 10),
                Image.asset(
                  'images/exercises/plank.png',
                  height: 150,
                  width: 150,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 50,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        controller: timeMDuration,
                        decoration: InputDecoration(
                            labelText: 'M',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(2),
                                borderSide: BorderSide(width: 5))),
                      ),
                    ),
                    SizedBox(width: 20),
                    Text(':'),
                    SizedBox(width: 20),
                    Container(
                      width: 50,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText: 'S',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(2),
                                borderSide: BorderSide(width: 5))),
                        controller: timeSDuration,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (timeMDuration.text.isNotEmpty ||
                    timeSDuration.text.isNotEmpty) {
                  int seconds = int.tryParse(timeSDuration.text) ?? 0;
                  int minutes = int.tryParse(timeMDuration.text) ?? 0;
                  int duration = (minutes * 60) + seconds;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Plank(
                        duration: duration,
                      ),
                    ),
                  );
                  _addFitnessTrack('$duration', '', 0, 0);
                  setState(() {});
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please Enter Time')));
                }
              },
              child: Text("Start"),
            ),
          ],
        );
      },
    );
  }

  void startPushUps() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("PushUps"),
          content: Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text("Get ready to do PushUps!"),
                SizedBox(height: 10),
                Image.asset(
                  'images/exercises/pushups.png',
                  width: 150,
                  height: 150,
                ),
                SizedBox(
                  height: 20,
                ),
                TextField(
                  keyboardType: TextInputType.number,
                  controller: _pushUps,
                  decoration: InputDecoration(
                      hintText: 'PushUps you want to do!',
                      labelText: 'PushUps',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(2),
                          borderSide: BorderSide(width: 5))),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context), child: Text('Cancel')),
            TextButton(
              onPressed: () {
                if (_pushUps.text.isNotEmpty) {
                  int PUSHUPS = int.parse(_pushUps.text);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PushUps(
                          pushups: PUSHUPS,
                        ),
                      ));
                  setState(() {
                    print(_fitnessScore);
                    _loadFitnessTrack();
                    _addFitnessTrack('', '', PUSHUPS, 0);
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please Enter PushUps')));
                }
              },
              child: Text("Done"),
            ),
          ],
        );
      },
    );
  }

  void startLungs() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Lungs Test "),
          content: Card(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Get ready to Hold Your Breath!"),
                SizedBox(height: 10),
                Icon(FontAwesomeIcons.lungs),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 50,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        controller: timeMDuration,
                        decoration: InputDecoration(
                            labelText: 'M',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(2),
                                borderSide: BorderSide(width: 5))),
                      ),
                    ),
                    SizedBox(width: 20),
                    Text(':'),
                    SizedBox(width: 20),
                    Container(
                      width: 50,
                      child: TextField(
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelText: 'S',
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(2),
                                borderSide: BorderSide(width: 5))),
                        controller: timeSDuration,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (timeSDuration.text.isNotEmpty ||
                    timeMDuration.text.isNotEmpty) {
                  int seconds = int.tryParse(timeSDuration.text) ?? 0;
                  int minutes = int.tryParse(timeMDuration.text) ?? 0;
                  int duration = (minutes * 60) + seconds;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Breath(
                        duration: duration,
                      ),
                    ),
                  );
                  _addFitnessTrack('', '$duration', 0, 0);
                  setState(() {});
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Please Enter Time')));
                }
              },
              child: Text("Start"),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: Duration(seconds: 3));
    _loadFitnessTrack();
    _loadGoals();
    _calculateStreak();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _calculateStreak() {
    if (_fitnessScore.isEmpty) {
      setState(() {
        streakDays = 0;
      });
      return;
    }

    int streak = 0;
    DateTime? lastDate;

    for (var workout in _fitnessScore) {
      DateTime workoutDate = DateTime.parse(workout['date']);
      DateTime workoutDay =
          DateTime(workoutDate.year, workoutDate.month, workoutDate.day);

      if (lastDate == null) {
        streak = 1;
        lastDate = workoutDay;
      } else {
        Duration difference = lastDate.difference(workoutDay);
        if (difference.inDays == 1) {
          streak++;
          lastDate = workoutDay;
        } else if (difference.inDays > 1) {
          break;
        }
      }
    }

    setState(() {
      streakDays = streak;
    });
  }

  TextEditingController pushUps = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Stack(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: 20),
                  Text(
                    " Dashboard 🏋️",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 30),
                  _buildHeader(),
                  SizedBox(height: 20),
                  // Streak Widget
                  StreakWidget(streakDays: streakDays),
                  SizedBox(height: 20),
                  // Quick Actions
                  _buildQuickActions(),
                  SizedBox(height: 20),
                  _buildAnalyticsCard(),
                  SizedBox(height: 20),
                  // Weekly Chart
                  if (_fitnessScore.isNotEmpty)
                    WeeklyChart(fitnessData: _fitnessScore),
                  SizedBox(height: 20),
                  _buildPopularExercises(),
                  SizedBox(height: 20),
                ],
              ),
            ),
          ),
          // Confetti overlay
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Welcome Back!",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black)),
            Text("Track your progress",
                style: TextStyle(fontSize: 14, color: Colors.black54)),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          'Achievements',
          FontAwesomeIcons.trophy,
          Colors.amber,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AchievementsScreen(
                  totalPushups: totalPushups,
                  totalSteps: totalSteps,
                  streakDays: streakDays,
                ),
              ),
            );
          },
        ),
        SizedBox(width: 12), // Fitts' Law: Adequate spacing between targets
        _buildActionButton(
          'BMI',
          FontAwesomeIcons.weight,
          Colors.teal,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => BMICalculator()),
            );
          },
        ),
        SizedBox(width: 12), // Fitts' Law: Adequate spacing between targets
        _buildActionButton(
          'Water',
          FontAwesomeIcons.glassWater,
          Colors.blue,
          () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => WaterTracker()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButton(
      String label, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        // Fitts' Law: Minimum 44x44dp touch target
        width: 100,
        height: 100,
        padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: color, size: 32), // Larger icon for better visibility
            SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.purple.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(2, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildGoalTracker(),
            SizedBox(height: 15),
            Text(
              'Workout Progress',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 15),
            _buildStatRow(FontAwesomeIcons.stopwatch, 'Plank Duration',
                formatTime(totalPlank), Colors.orange),
            _buildStatRow(FontAwesomeIcons.running, 'Lungs Duration',
                formatTime(totalLungs), Colors.greenAccent),
            _buildStatRow(FontAwesomeIcons.dumbbell, 'Push-ups',
                '$totalPushups reps', Colors.orangeAccent,
                isNumeric: true, numericValue: totalPushups),
            _buildStatRow(FontAwesomeIcons.walking, 'Total Steps',
                '$totalSteps', Colors.redAccent,
                isNumeric: true, numericValue: totalSteps),
            Align(
                alignment: Alignment.topRight,
                child: Row(
                  children: [
                    TextButton(
                        onPressed: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ExercisesHistory(),
                              ));
                        },
                        child: Text('Show History')),
                    SizedBox(
                      width: 10,
                    ),
                    TextButton(
                        onPressed: () async {
                          await DatabaseHelper.instance.clearWorkouts();
                          setState(() {
                            _loadFitnessTrack();
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text("Scores cleared successfully!")));
                            _fitnessScore
                                .clear(); // Clear the local list as well
                          });
                        },
                        child: Text('Reset Progress')),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value, Color color,
      {bool isNumeric = false, int? numericValue}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, color: color, size: 22),
          SizedBox(width: 12),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70),
          ),
          Spacer(),
          isNumeric && numericValue != null
              ? Row(
                  children: [
                    AnimatedCounter(
                      value: numericValue,
                      textStyle: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      label.contains('Push-ups') ? ' reps' : '',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                )
              : Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildGoalTracker() {
    Map<String, dynamic> Goals = _fitnessGoals.first;
    int Steps = Goals['Steps'] as int;
    int pushUPS = Goals['pushUps'] as int;

    // Check if goals are achieved and trigger confetti
    if ((totalSteps >= Steps || totalPushups >= pushUPS) &&
        !_confettiController.state.toString().contains('playing')) {
      Future.delayed(Duration(milliseconds: 500), () {
        _confettiController.play();
      });
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Fitness Goals Progress",
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[200]),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Steps Progress
            Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: (totalSteps / Steps).clamp(0.0, 1.0),
                        backgroundColor: Colors.grey[300],
                        color: Colors.redAccent,
                        strokeWidth: 6,
                      ),
                    ),
                    Image.asset(
                      'images/exercises/steps.png',
                      scale: 20,
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "${(totalSteps / Steps * 100).clamp(0, 100).toStringAsFixed(1)}%",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Steps",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  "$totalSteps / $Steps",
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            ),

            // Push-ups Progress

            Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: CircularProgressIndicator(
                        value: (totalPushups / pushUPS).clamp(0.0, 1.0),
                        backgroundColor: Colors.grey[300],
                        color: Colors.orangeAccent,
                        strokeWidth: 6,
                      ),
                    ),
                    Image.asset(
                      'images/exercises/pushups.png',
                      scale: 40,
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "${(totalPushups / pushUPS * 100).clamp(0, 100).toStringAsFixed(1)}%",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Push-ups",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                Text(
                  "$totalPushups / $pushUPS",
                  style: TextStyle(color: Colors.black54),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPopularExercises() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Popular Exercises",
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
        SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            InkWell(
                onTap: () {
                  startPushUps();
                },
                child: _buildExerciseCard(
                    "PushUps", "images/exercises/home_workout.png")),
            SizedBox(width: 16), // Fitts' Law: Adequate spacing between targets
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PedometerScreen(),
                    ));
                setState(() {});
              },
              child: _buildExerciseCard("Steps", "images/exercises/steps.png"),
            ),
          ],
        ),
        SizedBox(height: 20), // Increased vertical spacing
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            InkWell(
                onTap: startPlank,
                child:
                    _buildExerciseCard("Plank", "images/exercises/plank.png")),
            SizedBox(width: 16), // Fitts' Law: Adequate spacing between targets
            InkWell(
                onTap: startLungs,
                child:
                    _buildExerciseCard("Lungs", "images/exercises/lungs.png")),
          ],
        ),
      ],
    );
  }

  Widget _buildExerciseCard(String title, String imagePath) {
    return Hero(
      tag: 'exercise_$title',
      child: Container(
        // Fitts' Law: Larger touch target for better accessibility
        width: MediaQuery.of(context).size.width * 0.42,
        height: 180, // Fixed height for consistent touch targets
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              spreadRadius: 2,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(imagePath, height: 100), // Slightly smaller image
            SizedBox(height: 12), // Increased spacing
            Text(title,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

//Workouts Screen
class Workout_Screen extends StatefulWidget {
  const Workout_Screen({super.key});

  @override
  _Workout_ScreenState createState() => _Workout_ScreenState();
}

class _Workout_ScreenState extends State<Workout_Screen> {
  final TextEditingController pushupController = TextEditingController();
  final TextEditingController stepsController = TextEditingController();

  List<Map<String, dynamic>> _fitnessGoals = [];
  Future<void> _loadGoals() async {
    final List<Map<String, dynamic>> data =
        await DatabaseHelper.instance.getGoals();
    if (mounted) {
      setState(() {
        _fitnessGoals = data;
        ();
      });
    }
  }

  Future<void> _addGoals(int pushups, int steps) async {
    await DatabaseHelper.instance.addGoals(pushups, steps);
    // Ensure Track reload after adding a new one
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 20,
            ),
            Text(
              'Goals 🎯',
              style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            SizedBox(height: 20),
            Text(
              "Set Your Fitness Goals",
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black),
            ),
            SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 1,
                crossAxisSpacing: 10,
                mainAxisSpacing: 20,
                children: [
                  buildGoalCard(
                    "Push-ups Goal",
                    "images/exercises/pushups.png", // Add a push-up related image
                    pushupController,
                  ),
                  buildGoalCard(
                    "Steps Goal",
                    "images/exercises/steps.png", // Add a steps-related image
                    stepsController,
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Fitts' Law: Larger button with adequate touch target
            Container(
              width: double.infinity,
              height: 56, // Minimum 44dp height + padding
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  // Handle goal submission
                  int pushupGoal = int.tryParse(pushupController.text) ?? 0;
                  int stepsGoal = int.tryParse(stepsController.text) ?? 0;
                  if (pushupController.text.isNotEmpty &&
                      stepsController.text.isNotEmpty) {
                    _addGoals(pushupGoal, stepsGoal);
                    setState(() {
                      _loadGoals();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Your Goal is set now Get ready')));
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Fitness_Tracker(),
                          ));
                    });
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Please Set Both Goals')));
                  }
                },
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Center(
                    child: Text("Save Goals",
                        style: TextStyle(fontSize: 18, color: Colors.black)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGoalCard(
    String title,
    String imagePath,
    TextEditingController controller,
  ) {
    return Container(
      // Fitts' Law: Larger touch target for better accessibility
      width: MediaQuery.of(context).size.width * 0.85,
      height: 280, // Increased height for better proportions
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          )
        ],
      ),
      padding: EdgeInsets.all(20), // Increased padding
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            imagePath,
            height: 120, // Reduced image height for better balance
          ),
          SizedBox(height: 16), // Increased spacing
          Text(title,
              style: TextStyle(
                fontSize: 20, // Larger text
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center),
          SizedBox(height: 16), // Increased spacing
          Container(
            height: 56, // Fitts' Law: Minimum touch target height
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              style: TextStyle(
                color: Colors.black,
                fontSize: 16, // Larger text
              ),
              decoration: InputDecoration(
                hintText: "ie 50",
                labelText: 'Set Goal',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16, // Adequate padding for touch
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//Profile Screen
