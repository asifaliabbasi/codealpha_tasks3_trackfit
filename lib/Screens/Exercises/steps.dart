import 'package:fitness_tracker_app/Screens/home_Screen.dart';
import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Database/DataBase_Helper.dart';

class PedometerScreen extends StatefulWidget {
  @override
  _PedometerScreenState createState() => _PedometerScreenState();
}

class _PedometerScreenState extends State<PedometerScreen> with SingleTickerProviderStateMixin {
  late Stream<StepCount> _stepCountStream;
  late Stream<PedestrianStatus> _pedestrianStatusStream;
  String _status = 'Unknown';
  int _steps = 0;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _requestPermission();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
  }

  Future<void> _loadSteps() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _steps = prefs.getInt('steps') ?? 0;
    });
  }

  void _resetSteps() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('steps', 0);
    setState(() {
      _steps = 0;
    });
  }

  void _requestPermission() async {
    var status = await Permission.activityRecognition.request();
    if (status.isGranted) {
      initPedometer();
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Permission required"),
          content: Text("This app needs activity recognition permission to track steps."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  void initPedometer() {
    _stepCountStream = Pedometer.stepCountStream;
    _pedestrianStatusStream = Pedometer.pedestrianStatusStream;

    _stepCountStream.listen(onStepCount).onError(onStepCountError);
    _pedestrianStatusStream.listen(onPedestrianStatus).onError(onPedestrianStatusError);
  }

  Future<void> onStepCount(StepCount event) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _steps = event.steps;
      _controller.forward(from: 0);
    });
    await prefs.setInt('steps', _steps);
  }

  void onPedestrianStatus(PedestrianStatus event) {
    setState(() {
      _status = event.status;
    });
  }

  void onStepCountError(error) {
    setState(() {
      _steps = 0;
    });
  }

  void onPedestrianStatusError(error) {
    setState(() {
      _status = 'Unknown';
    });
  }

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

  Future<void> _addFitnessTrack(String Tplank, String Tlungs, int Tpushups, int Tsteps) async {
    try {
      await DatabaseHelper.instance.saveWorkouts(Tpushups, Tplank, Tlungs, Tsteps);
      await _loadFitnessTrack(); // Ensure Track reload after adding a new one
    } catch (e) {
      print('Error adding fitness track: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text("Pedometer", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('images/exercises/steps.png',scale: 5,),
              SizedBox(height: 20,),
              ScaleTransition(
                scale: _animation,
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4))
                    ],
                  ),
                  child: Text(
                    "Steps: $_steps",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              Text(
                "Status: $_status",
                style: TextStyle(fontSize: 18, color: Colors.blueAccent),
              ),
              SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                  elevation: 5,
                ),
                child: Text("Start Tracking", style: TextStyle(fontSize: 16)),
                onPressed: () {
                  initPedometer();
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                  elevation: 5,
                ),
                onPressed: () async {
                  _resetSteps();
                  setState(() {
                    _addFitnessTrack('', '', 0, _steps);
                    Navigator.pushReplacement(
                        context, MaterialPageRoute(builder: (context) => Fitness_Tracker()));
                  });
                },
                child: Text(
                  'Finish',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
