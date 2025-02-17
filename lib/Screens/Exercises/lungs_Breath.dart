import 'dart:async';
import 'package:flutter/material.dart';

class Breath extends StatefulWidget {
  const Breath({super.key, required this.duration});
  final duration;

  @override
  _Breath createState() => _Breath();
}

class _Breath extends State<Breath> {
  Timer? _timer;
  int _start = 20;
  bool _isRunning = false;

  void _startTimer(int duration) {
    setState(() {
      _start = duration;
      _isRunning = true;
    });
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_start > 0) {
        setState(() {
          _start--;
        });
      } else {
        timer.cancel();
        setState(() {
          _isRunning = false;
        });
      }
    });
  }

  void _stopTimer() {
    if (_timer != null) {
      _timer!.cancel();
      setState(() {
        _isRunning = false;
      });
    }
  }

  void _continueTimer() {
    if (_start > 0 && !_isRunning) {
      setState(() {
        _isRunning = true;
      });
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        if (_start > 0) {
          setState(() {
            _start--;
          });
        } else {
          timer.cancel();
          setState(() {
            _isRunning = false;
          });
        }
      });
    }}

  @override
  void dispose() {
    super.dispose();
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _startTimer(widget.duration as int);
  }

  String formatTime(int seconds) {
    int minutes = (seconds / 60).floor();
    int remainingSeconds = seconds % 60;
    return '$minutes minute${minutes == 1 ? '' : 's'} and $remainingSeconds second${remainingSeconds == 1 ? '' : 's'}';
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text("Timer 🏋️"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Hold Your Breath!",
              style: TextStyle(color: Colors.blueAccent,fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Plank Image
            Image.asset(
              "images/exercises/lungs.png", // Replace with your own plank image
              height: 200,
            ),

            SizedBox(height: 20),
            Container(
              height: 150,
              width: 150,
              child: CircularProgressIndicator(
                value: (widget.duration - _start) / widget.duration,
                backgroundColor: Colors.grey[300],
                color: Colors.green,
                strokeWidth: 13,
              ),
            ),
            SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${formatTime(_start)}'
                  ,style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.purple),
                ),
              ],
            ),

            SizedBox(height: 20),
            ElevatedButton(
              onPressed:(){setState(() {
                _stopTimer();
              });
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Timer Stopped')));} ,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                "Stop Timer",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            SizedBox(height: 20,),
            ElevatedButton(
              onPressed:(){
                setState(() {
                  _continueTimer();
                });
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Timer Continue')));},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                "Start Timer",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
