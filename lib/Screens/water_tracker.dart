import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:percent_indicator/percent_indicator.dart';

class WaterTracker extends StatefulWidget {
  const WaterTracker({Key? key}) : super(key: key);

  @override
  State<WaterTracker> createState() => _WaterTrackerState();
}

class _WaterTrackerState extends State<WaterTracker>
    with SingleTickerProviderStateMixin {
  int _waterIntake = 0;
  final int _dailyGoal = 2000; // ml
  late AnimationController _controller;
  late Animation<double> _waveAnimation;

  @override
  void initState() {
    super.initState();
    _loadWaterIntake();
    _controller = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    )..repeat();

    _waveAnimation = Tween<double>(begin: 0, end: 1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadWaterIntake() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    final lastDate = prefs.getString('waterDate') ?? '';

    if (lastDate == today) {
      setState(() {
        _waterIntake = prefs.getInt('waterIntake') ?? 0;
      });
    } else {
      await prefs.setString('waterDate', today);
      await prefs.setInt('waterIntake', 0);
      setState(() {
        _waterIntake = 0;
      });
    }
  }

  Future<void> _addWater(int amount) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _waterIntake += amount;
      if (_waterIntake > _dailyGoal) _waterIntake = _dailyGoal;
    });
    await prefs.setInt('waterIntake', _waterIntake);
  }

  Future<void> _resetWater() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _waterIntake = 0;
    });
    await prefs.setInt('waterIntake', 0);
  }

  @override
  Widget build(BuildContext context) {
    final percentage = (_waterIntake / _dailyGoal).clamp(0.0, 1.0);

    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(
          'Water Tracker',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _resetWater,
            tooltip: 'Reset',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(30),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircularPercentIndicator(
                    radius: 100,
                    lineWidth: 15,
                    percent: percentage,
                    center: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          FontAwesomeIcons.glassWater,
                          size: 50,
                          color: Colors.white,
                        ),
                        SizedBox(height: 10),
                        Text(
                          '$_waterIntake ml',
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    progressColor: Colors.white,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    circularStrokeCap: CircularStrokeCap.round,
                    animation: true,
                    animationDuration: 1000,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Daily Goal: $_dailyGoal ml',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      color: Colors.white70,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '${(percentage * 100).toStringAsFixed(0)}% Complete',
                    style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            Text(
              'Add Water Intake',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 20),
            Wrap(
              spacing: 20, // Fitts' Law: Increased spacing between targets
              runSpacing: 20, // Fitts' Law: Increased vertical spacing
              alignment: WrapAlignment.center,
              children: [
                _buildWaterButton(100, Icons.local_drink),
                _buildWaterButton(250, Icons.coffee),
                _buildWaterButton(500, Icons.water_drop),
                _buildWaterButton(1000, Icons.sports_bar),
              ],
            ),
            SizedBox(height: 30),
            if (percentage >= 1.0)
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade400, Colors.green.shade600],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.3),
                      blurRadius: 15,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.celebration, color: Colors.white, size: 30),
                    SizedBox(width: 10),
                    Text(
                      'Goal Achieved! 🎉',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            SizedBox(height: 30),
            _buildBenefitsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterButton(int amount, IconData icon) {
    return InkWell(
      onTap: () => _addWater(amount),
      child: Container(
        // Fitts' Law: Larger touch target for better accessibility
        width: 160,
        height: 120, // Fixed height for consistent touch targets
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 44, color: Colors.blue), // Larger icon
            SizedBox(height: 12), // Increased spacing
            Text(
              '+$amount ml',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitsCard() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Benefits of Staying Hydrated',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 15),
          _buildBenefitItem('💪 Improves physical performance'),
          _buildBenefitItem('🧠 Enhances brain function'),
          _buildBenefitItem('⚡ Boosts energy levels'),
          _buildBenefitItem('🌟 Promotes healthy skin'),
          _buildBenefitItem('🔥 Aids in weight management'),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(Icons.check_circle, color: Colors.blue, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
