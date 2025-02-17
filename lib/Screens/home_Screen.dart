import 'dart:async';

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pedometer/pedometer.dart';
import 'package:flutter/services.dart';
import '../Database/DataBase_Helper.dart';
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
        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "DashBoard"),
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

class _DashboardState extends State<Dashboard> {
  late Stream<StepCount> _stepCountStream;
  int totalPlank = 0;
  int totalLungs = 0;
  int totalPushups = 0;
  int totalSteps = 0;

  void _calculateTotals() {
    totalPlank = 0;
    totalLungs = 0;
    totalPushups = 0;
    totalSteps = 0;

    for (var fitnessData in _fitnessScore) {
      totalPlank += int.tryParse(fitnessData['plank']) ?? 0 ;
      totalLungs += int.tryParse(fitnessData['lungs']) ?? 0 ;
      totalPushups += (fitnessData['pushups'] ?? 0) as int;
      totalSteps += (fitnessData['steps'] ?? 0) as int;
      print('Steps are: $totalSteps');
      setState(() {

      });
    }

    setState(() {
    });
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
      });
    }
  }

  Future<void> _addFitnessTrack(String Tplank, String Tlungs, int Tpushups, int Tsteps) async {
    try {
      await DatabaseHelper.instance.saveWorkouts(Tpushups, Tplank, Tlungs, Tsteps);
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
          content: Column(
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
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
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
                setState(() {

                });
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
          content: Column(
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
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context), child: Text('Cancel')),
            TextButton(
              onPressed: () {
                int PUSHUPS = int.parse(_pushUps.text) ?? 0;
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PushUps(pushups: PUSHUPS,),
                    ));
                setState(() {
                  print(_fitnessScore);
                  _loadFitnessTrack();
                  _addFitnessTrack('', '', PUSHUPS, 0);
                });
              },
              child: Text("Done"),
            ),
          ],
        );
      },
    );
  }

  void startJumpJacks() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Jump Jacks"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Get ready to do Jump Jacks!"),
              SizedBox(height: 10),
              Text(
                '🏃🏼',
                style: TextStyle(fontSize: 50),
              )
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
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
          content: Column(
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
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
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
                _addFitnessTrack('','$duration', 0, 0);
                setState(() {

                });
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
    _loadFitnessTrack();
    _loadGoals();
  }

  TextEditingController pushUps = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 20,
              ),
              Text(
                " Dashboard 🏋️",
                style: TextStyle(color: Colors.black, fontSize: 20,fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 30,
              ),
              _buildHeader(),
              SizedBox(height: 20),
              _buildAnalyticsCard(),
              SizedBox(height: 20),
              _buildPopularExercises(),
            ],
          ),
        ),
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
            _buildStatRow(FontAwesomeIcons.stopwatch, 'Plank Duration', formatTime(totalPlank), Colors.orange),
            _buildStatRow(FontAwesomeIcons.running, 'Lungs Duration', formatTime(totalLungs), Colors.greenAccent),
            _buildStatRow(FontAwesomeIcons.dumbbell, 'Push-ups', '$totalPushups reps', Colors.orangeAccent),
            _buildStatRow(FontAwesomeIcons.walking, 'Total Steps', '$totalSteps', Colors.redAccent),
            Align(
                alignment: Alignment.topRight,
                child: Row(
                  children: [
                    TextButton(
                        onPressed: (){
                          setState(() {
                            print(_fitnessScore.last.toString());
                         _calculateTotals();
                                });
            }, child: Text('Show History')),
                    SizedBox(width: 10,),
                    TextButton(onPressed: ()async{
                      await DatabaseHelper.instance.clearWorkouts();
                      setState(() {
                        _loadFitnessTrack();
                        ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Scores cleared successfully!")));
                        _fitnessScore.clear(); // Clear the local list as well
                      });
                    }, child: Text('Reset Progress')),
                  ],
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value, Color color) {
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
          Text(
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
    int Steps  = Goals['Steps'] as int;
    int pushUPS = Goals['pushUps'] as int;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          "Fitness Goals Progress",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[200]),
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
                    Image.asset('images/exercises/steps.png',scale: 20,),
                   ],
                ),
                SizedBox(height: 10,),
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
                    Image.asset('images/exercises/pushups.png',scale: 40,),

                  ],
                ),
                SizedBox(height: 10,),
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
            InkWell(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context) => PedometerScreen(),));
                setState(() {

                });
              },
              child: _buildExerciseCard(
                  "Steps", "images/exercises/steps.png"),
            ),
          ],
        ),
        SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            InkWell(
                onTap: startPlank,
                child:
                    _buildExerciseCard("Plank", "images/exercises/plank.png")),
            InkWell(
                onTap: startLungs,
                child: _buildExerciseCard("Lungs", "images/exercises/lungs.png")),
          ],
        ),
      ],
    );
  }

  Widget _buildExerciseCard(String title, String imagePath) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.4,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      child: Column(
        children: [
          Image.asset(imagePath, height: 120),
          SizedBox(height: 10),
          Text(title,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black)),
        ],
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
            Text('Goals 🎯',style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold,color: Colors.black),),
            SizedBox(height: 20),
            Text(
              "Set Your Fitness Goals",
              style: TextStyle(
                  fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
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
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                // Handle goal submission
                int pushupGoal = int.tryParse(pushupController.text) ?? 0;
                int stepsGoal = int.tryParse(stepsController.text) ?? 0;
                if(pushupController.text.isNotEmpty && stepsController.text.isNotEmpty) {
                  _addGoals(pushupGoal, stepsGoal);
                  setState(() {
                    _loadGoals();
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Your Goal is set now Get ready')));
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => Fitness_Tracker(),));
                  });
                }

                else{
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please Set Both Goals')));
                }

                },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Center(
                  child: Text("Save Goals", style: TextStyle(fontSize: 18,color: Colors.black)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildGoalCard(String title, String imagePath, TextEditingController controller,) {
    return Container(
        width: 200,
        height: 200,
        decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(imagePath,height: 200,),
          SizedBox(height: 10),
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            style: TextStyle(color: Colors.black),
            decoration: InputDecoration(
              hintText: "ie 50",
              labelText: 'set goal',
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            ),
          ),
        ],
      ),
    );
  }
}

//Profile Screen
class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<Map<String, dynamic>> profileData = [];
  bool isLoading = true; // Added loading flag

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final List<Map<String, dynamic>> data = await DatabaseHelper.instance.getProfile();

    if (mounted) {
      setState(() {
        profileData = data;
        isLoading = false; // Stop showing loading indicator
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: isLoading
          ? Center(child: CircularProgressIndicator()) // Show loader while fetching data
          : profileData.isEmpty
          ? _buildNoProfileUI() // Handle empty profile case
          : _buildProfileUI(), // Show profile if data exists
    );
  }

  Widget _buildNoProfileUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(FontAwesomeIcons.user, size: 80, color: Colors.grey),
          SizedBox(height: 15),
          Text(
            "No Profile Found",
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
          SizedBox(height: 10),
          ElevatedButton(
            onPressed: (){
              _editProfile();
            },// Opens edit screen to add profile
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: Text("Create Profile", style: GoogleFonts.poppins(fontSize: 16, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileUI() {
    Map<String, dynamic> userProfile = profileData.first; // Load first profile entry

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header Section
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 40),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade400, Colors.purple.shade600],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(30),
              bottomRight: Radius.circular(30),
            ),
          ),
          child: Column(
            children: [
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  child: Icon(
                    FontAwesomeIcons.user,
                    size: 50,
                    color: Colors.purple.shade400,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                userProfile['Name'] ?? "N/A",
                style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              SizedBox(height: 5),
              Text(
                userProfile['bio'] ?? "N/A",
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.white70),
              ),
              SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed:(){
                  setState(() {
                    _editProfile();
                  });},
                icon: Icon(FontAwesomeIcons.edit, size: 16, color: Colors.white),
                label: Text("Edit Profile", style: GoogleFonts.poppins(fontSize: 16, color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white24,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 20),
        _buildInfoCard(FontAwesomeIcons.user, "Gender", "${userProfile['Gender']}"),
        _buildInfoCard(FontAwesomeIcons.user, "Age", "${userProfile['Age']} years"),
        _buildInfoCard(FontAwesomeIcons.rulerVertical, "Height", "${userProfile['Height']} cm"),
        _buildInfoCard(FontAwesomeIcons.weight, "Weight", "${userProfile['Weight']} kg"),
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String label, String value) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(2, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.purple.shade400, size: 28),
          SizedBox(width: 15),
          Text(
            label,
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.black87),
          ),
          Spacer(),
          Text(
            value,
            style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Future<void> _editProfile() async {
    // If no profile exists, set default empty values
    Map<String, dynamic> currentProfile = profileData.isNotEmpty
        ? profileData.first
        : {"Name":"" ,"Age": 0, "Height": 0, "Weight": 0, "Gender":"Gender", "bio":'Bio'};

    TextEditingController nameController = TextEditingController(text: currentProfile['Name']);
    TextEditingController ageController = TextEditingController(text: currentProfile['Age'].toString());
    TextEditingController heightController = TextEditingController(text: currentProfile['Height'].toString());
    TextEditingController weightController = TextEditingController(text: currentProfile['Weight'].toString());
    TextEditingController genderController = TextEditingController(text: currentProfile['Gender']);
    TextEditingController bioController = TextEditingController(text: currentProfile['bio']);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16,
            right: 16,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                profileData.isEmpty ? "Add Profile" : "Edit Profile",
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15),
              _buildTextField("Name", nameController),
              _buildTextField("Age", ageController, isNumber: true),
              _buildTextField("Height (ft)", heightController, isNumber: true),
              _buildTextField("Weight (kg)", weightController, isNumber: true),
              _buildTextField("Gender", genderController),
              _buildTextField("Bio", bioController),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if(profileData.isNotEmpty){
                  await _addProfile(
                    int.parse(ageController.text),
                    int.parse(heightController.text),
                    int.parse(weightController.text),
                    genderController.text,
                    nameController.text,
                    bioController.text
                  );}
                  else{
                    await _updateProfile(
                        int.parse(ageController.text),
                        int.parse(heightController.text),
                        int.parse(weightController.text),
                        genderController.text,
                        nameController.text,
                        bioController.text
                    );
                  }
                  await _loadProfileData(); // Refresh UI
                  Navigator.pop(context); // Close bottom sheet
                },
                child: Text(profileData.isEmpty ? "Create Profile" : "Save Changes",
                    style: GoogleFonts.poppins(fontSize: 16)),
              ),
            ],
          ),
        );
      },
    );
  }


// Helper Function to Create TextFields
  Widget _buildTextField(String label, TextEditingController controller, {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.black45,
        ),
      ),
    );
  }

// Updates Existing Profile Instead of Adding a New One
  Future<void> _updateProfile(int age, int height, int weight, String gender, String name,Bio) async {
    if (profileData.isNotEmpty) {
      await DatabaseHelper.instance.updateProfile(name, age, height, weight, gender,Bio);
    } else {
      await DatabaseHelper.instance.addProfile(name, age, height, weight, gender,Bio);
    }
    await _loadProfileData();
  }


  Future<void> _addProfile(int age, int height, int weight, String gender, String name,String Bio) async {
    await DatabaseHelper.instance.addProfile(name, age, height, weight, gender,Bio);
    await _loadProfileData();
  }
}
