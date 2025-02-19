import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../Database/DataBase_Helper.dart';

class ExercisesHistory extends StatefulWidget {
  const ExercisesHistory({super.key});

  @override
  State<ExercisesHistory> createState() => _ExercisesHistoryState();
}

class _ExercisesHistoryState extends State<ExercisesHistory> {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Workout History',style: TextStyle(color: Colors.grey[200],fontWeight: FontWeight.w500),),
        centerTitle: true,

      ),
      body: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: Column(
          children: [
            Column(
              children: _fitnessScore.map((fitnessData) {
                return Card(
                  margin: EdgeInsets.all(10),
                  child: ListTile(
                    title: Text(
                        'Workout ${fitnessData['id']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date: ${DateTime.parse(fitnessData['date']).toLocal().toIso8601String().split('.')[0]}'),
                        Text('Plank: ${fitnessData['plank']}'),
                        Text('Lungs: ${fitnessData['lungs']}'),
                        Text('Pushups: ${fitnessData['pushups']}'),
                        Text('Steps: ${fitnessData['steps']}'),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
