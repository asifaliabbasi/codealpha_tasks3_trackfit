import 'package:flutter/material.dart';
import 'dart:async';

class Plank extends StatefulWidget {
  const Plank({super.key, required this.duration});
  final duration;

  @override
  _PlankState createState() => _PlankState();
}

class _PlankState extends State<Plank> {
  Timer? _timer;
  int _start = 0;
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
        title: Text("Plank Timer 🏋️"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Hold the Plank!",
              style: TextStyle(color: Colors.blue,fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Plank Image
            Image.asset(
              "images/exercises/plank.png", // Replace with your own plank image
              height: 200,
            ),

            SizedBox(height: 20),


            SizedBox(height: 10),
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
              onPressed: (){
                setState(() {
                  _stopTimer();
                });
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Timer Stopped')));},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                "Stop Plank",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
            SizedBox(height: 20,),
            ElevatedButton(
              onPressed:() {

                setState(() {
                  _continueTimer();
                });
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Timer Continue')));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text(
                "Start Plank",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}



