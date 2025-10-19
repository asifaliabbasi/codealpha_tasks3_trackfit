import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math' as math;

class BMICalculator extends StatefulWidget {
  const BMICalculator({Key? key}) : super(key: key);

  @override
  State<BMICalculator> createState() => _BMICalculatorState();
}

class _BMICalculatorState extends State<BMICalculator>
    with SingleTickerProviderStateMixin {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  double? _bmi;
  String _category = '';
  Color _categoryColor = Colors.blue;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _calculateBMI() {
    final height = double.tryParse(_heightController.text);
    final weight = double.tryParse(_weightController.text);

    if (height != null && weight != null && height > 0) {
      setState(() {
        // Convert height from cm to meters
        _bmi = weight / math.pow(height / 100, 2);
        _updateCategory();
        _controller.reset();
        _controller.forward();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter valid height and weight')),
      );
    }
  }

  void _updateCategory() {
    if (_bmi == null) return;

    if (_bmi! < 18.5) {
      _category = 'Underweight';
      _categoryColor = Colors.blue;
    } else if (_bmi! < 25) {
      _category = 'Normal';
      _categoryColor = Colors.green;
    } else if (_bmi! < 30) {
      _category = 'Overweight';
      _categoryColor = Colors.orange;
    } else {
      _category = 'Obese';
      _categoryColor = Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: Text(
          'BMI Calculator',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.teal,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal, Colors.teal.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.teal.withOpacity(0.3),
                    blurRadius: 15,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Icon(
                    FontAwesomeIcons.weight,
                    size: 60,
                    color: Colors.white,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Body Mass Index',
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
            _buildInputCard(
              'Height (cm)',
              _heightController,
              FontAwesomeIcons.rulerVertical,
              Colors.blue,
            ),
            SizedBox(height: 20),
            _buildInputCard(
              'Weight (kg)',
              _weightController,
              FontAwesomeIcons.weight,
              Colors.orange,
            ),
            SizedBox(height: 30),
            // Fitts' Law: Larger button with adequate touch target
            Container(
              width: double.infinity,
              height: 56, // Minimum 44dp height + padding
              child: ElevatedButton(
                onPressed: _calculateBMI,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                child: Text(
                  'Calculate BMI',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            if (_bmi != null)
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  padding: EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: _categoryColor.withOpacity(0.3),
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'Your BMI',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        _bmi!.toStringAsFixed(1),
                        style: GoogleFonts.poppins(
                          fontSize: 60,
                          fontWeight: FontWeight.bold,
                          color: _categoryColor,
                        ),
                      ),
                      SizedBox(height: 10),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        decoration: BoxDecoration(
                          color: _categoryColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _category,
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _categoryColor,
                          ),
                        ),
                      ),
                      SizedBox(height: 20),
                      _buildBMIScale(),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputCard(String label, TextEditingController controller,
      IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding:
                EdgeInsets.all(16), // Increased padding for larger touch target
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28), // Larger icon
          ),
          SizedBox(width: 20),
          Expanded(
            child: Container(
              height: 56, // Fitts' Law: Minimum touch target height
              child: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                style: GoogleFonts.poppins(fontSize: 18), // Larger text
                decoration: InputDecoration(
                  labelText: label,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  labelStyle: GoogleFonts.poppins(
                    color: Colors.black54,
                    fontSize: 16,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16, // Adequate padding for touch
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBMIScale() {
    return Column(
      children: [
        _buildScaleItem('< 18.5', 'Underweight', Colors.blue),
        _buildScaleItem('18.5 - 24.9', 'Normal', Colors.green),
        _buildScaleItem('25.0 - 29.9', 'Overweight', Colors.orange),
        _buildScaleItem('≥ 30.0', 'Obese', Colors.red),
      ],
    );
  }

  Widget _buildScaleItem(String range, String label, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 10),
          Text(
            '$range - $label',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}
