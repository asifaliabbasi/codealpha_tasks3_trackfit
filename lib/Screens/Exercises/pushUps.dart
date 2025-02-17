import 'package:fitness_tracker_app/Screens/home_Screen.dart';
import 'package:flutter/material.dart';

class PushUps extends StatefulWidget {
  const PushUps({super.key, required this.pushups});
  final int pushups ;


  @override
  _PushUpsState createState() => _PushUpsState();
}

class _PushUpsState extends State<PushUps>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  int _pushups = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
  }

  void _incrementPushups() {
    setState(() {
      _pushups++;
      _controller.forward(from: 0);
    });
  }

  void _resetPushups() {
    setState(() {
      _pushups = 0;
    });
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
        title: Text("Pushup Motivation", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orangeAccent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Motivational Quote
              Text(
                "“Push yourself, because no one else is going to do it for you.”",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[700],
                ),
              ),
              SizedBox(height: 30),

              // Pushup Counter with Animation
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
                    "Pushups: $_pushups",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 60),

              // Progress Bar
              Container(
                height: 150,
                width: 150,
                child: CircularProgressIndicator(
                  value: _pushups / widget.pushups, // Assume goal of 50 pushups
                  backgroundColor: Colors.grey[300],
                  color: Colors.orangeAccent,
                  strokeWidth: 15,
                ),

              ),
              SizedBox(height: 40),
              Text('$_pushups/${widget.pushups}',style: TextStyle(color: Colors.black),),
              SizedBox(height: 50,),
              // Buttons
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orangeAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 30),
                  elevation: 5,
                ),
                child: Text("Do a Pushup", style: TextStyle(color: Colors.black,fontSize: 16)),
                onPressed: (){
                  if(_pushups!=widget.pushups ){
                    _incrementPushups();
                    setState(() {

                    });
                  }
                  else{
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Goal Completed')));
                  }
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
                onPressed: () {
                  _resetPushups();
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Fitness_Tracker(),));
                },
                child: Text(
                  'Finish Workout',
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
