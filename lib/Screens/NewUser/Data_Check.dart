import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../Database/DataBase_Helper.dart';
import '../home_Screen.dart';

class DataCheck extends StatefulWidget {
  const DataCheck({super.key});

  @override
  State<DataCheck> createState() => _DataCheckState();
}

class _DataCheckState extends State<DataCheck> {
  Future<void> _checkDataAndNavigate() async {
    final db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> result = await db.query('goals');

    if (result.isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Fitness_Tracker()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => Workout_Screen()),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _checkDataAndNavigate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}