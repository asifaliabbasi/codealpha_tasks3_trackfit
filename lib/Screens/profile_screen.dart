import 'package:fitness_tracker_app/Database/DataBase_Helper.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<Map<String, dynamic>> profileData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final List<Map<String, dynamic>> data =
        await DatabaseHelper.instance.getProfile();

    if (mounted) {
      setState(() {
        profileData = data;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : profileData.isEmpty
              ? _buildNoProfileUI()
              : _buildProfileUI(),
    );
  }

  Widget _buildNoProfileUI() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(FontAwesomeIcons.user, size: 80, color: Colors.grey),
          SizedBox(height: 20),
          Text(
            "No Profile Found",
            style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black54),
          ),
          SizedBox(height: 15),
          Container(
            width: double.infinity,
            height: 56, // Fitts' Law: Minimum touch target height
            child: ElevatedButton(
              onPressed: () {
                _editProfile();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text("Create Profile",
                  style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileUI() {
    Map<String, dynamic> userProfile = profileData.first;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section with Profile Info
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.purple.shade400, Colors.purple.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25),
              ),
            ),
            child: Column(
              children: [
                // Profile Picture
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    color: Colors.white,
                  ),
                  child: Icon(
                    FontAwesomeIcons.user,
                    size: 50,
                    color: Colors.purple.shade400,
                  ),
                ),
                SizedBox(height: 15),
                // Name
                Text(
                  userProfile['Name'] ?? "John Doe",
                  style: GoogleFonts.poppins(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                SizedBox(height: 5),
                // Bio/Title
                Text(
                  userProfile['bio'] ?? "Fitness Enthusiast",
                  style:
                      GoogleFonts.poppins(fontSize: 16, color: Colors.white70),
                ),
                SizedBox(height: 10),
                // Join Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.white70),
                    SizedBox(width: 5),
                    Text(
                      "Joined October 2024",
                      style: GoogleFonts.poppins(
                          fontSize: 14, color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 30),

          // My Stats Section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "My Stats",
              style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
          ),
          SizedBox(height: 15),

          // Stats Grid
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              childAspectRatio: 1.3,
              children: [
                _buildStatCard(
                  Icons.height,
                  "Height",
                  "${userProfile['Height']} cm",
                  Colors.blue,
                ),
                _buildStatCard(
                  Icons.monitor_weight,
                  "Weight",
                  "${userProfile['Weight']} kg",
                  Colors.green,
                ),
                _buildStatCard(
                  Icons.flag,
                  "Goal",
                  "65 kg",
                  Colors.orange,
                ),
                _buildStatCard(
                  Icons.local_fire_department,
                  "Streak",
                  "1 day",
                  Colors.red,
                ),
              ],
            ),
          ),
          SizedBox(height: 30),

          // Recent Achievements Section
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Recent Achievements",
              style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
            ),
          ),
          SizedBox(height: 15),

          // Achievements List
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildAchievementItem(
                    Icons.emoji_events,
                    "First Workout",
                    "Completed your first session",
                    true,
                  ),
                  SizedBox(height: 15),
                  _buildAchievementItem(
                    Icons.star,
                    "Goal Setter",
                    "Set your first fitness goal",
                    true,
                  ),
                  SizedBox(height: 15),
                  _buildAchievementItem(
                    Icons.weekend,
                    "Week Warrior",
                    "Maintain a 7-day streak",
                    false,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 30),

          // Action Buttons
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // Settings Button
                Container(
                  width: double.infinity,
                  height: 56, // Fitts' Law: Minimum touch target height
                  margin: EdgeInsets.only(bottom: 16), // Increased spacing
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Settings functionality
                    },
                    icon: Icon(Icons.settings,
                        color: Colors.black87, size: 24), // Larger icon
                    label: Text(
                      "Settings",
                      style: GoogleFonts.poppins(
                          fontSize: 18, // Larger text
                          fontWeight: FontWeight.w600,
                          color: Colors.black87),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      elevation: 0,
                      side: BorderSide(color: Colors.grey.shade300, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                // Log Out Button
                Container(
                  width: double.infinity,
                  height: 56, // Fitts' Law: Minimum touch target height
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showLogoutDialog();
                    },
                    icon: Icon(Icons.logout,
                        color: Colors.white, size: 24), // Larger icon
                    label: Text(
                      "Log Out",
                      style: GoogleFonts.poppins(
                          fontSize: 18, // Larger text
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 30),
        ],
      ),
    );
  }

  // Helper method to build stat cards following Fitts' Law
  Widget _buildStatCard(
      IconData icon, String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: color,
            size: 32,
          ),
          SizedBox(height: 10),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 5),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helper method to build achievement items
  Widget _buildAchievementItem(
      IconData icon, String title, String subtitle, bool isCompleted) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted ? Colors.amber.shade100 : Colors.grey.shade100,
            ),
            child: Icon(
              icon,
              color: isCompleted ? Colors.amber.shade700 : Colors.grey.shade400,
              size: 24,
            ),
          ),
          SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isCompleted ? Colors.black87 : Colors.grey.shade500,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: isCompleted
                        ? Colors.grey.shade600
                        : Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Logout dialog following Fitts' Law principles
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: Text(
            "Log Out",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "Are you sure you want to log out?",
            style: GoogleFonts.poppins(fontSize: 16),
          ),
          actions: [
            Container(
              height: 44, // Fitts' Law: Adequate button height
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  minimumSize: Size(80, 44), // Fitts' Law: Minimum target size
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text(
                  "Cancel",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ),
            SizedBox(width: 8), // Fitts' Law: Adequate spacing between buttons
            Container(
              height: 44, // Fitts' Law: Adequate button height
              child: ElevatedButton(
                onPressed: () {
                  // Logout functionality
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  minimumSize: Size(80, 44), // Fitts' Law: Minimum target size
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                child: Text(
                  "Log Out",
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _editProfile() async {
    // If no profile exists, set default empty values
    Map<String, dynamic> currentProfile = profileData.isNotEmpty
        ? profileData.first
        : {
            "Name": "",
            "Age": 0,
            "Height": 0,
            "Weight": 0,
            "Gender": "Gender",
            "bio": 'Bio'
          };

    TextEditingController nameController =
        TextEditingController(text: currentProfile['Name']);
    TextEditingController ageController =
        TextEditingController(text: currentProfile['Age'].toString());
    TextEditingController heightController =
        TextEditingController(text: currentProfile['Height'].toString());
    TextEditingController weightController =
        TextEditingController(text: currentProfile['Weight'].toString());
    TextEditingController genderController =
        TextEditingController(text: currentProfile['Gender']);
    TextEditingController bioController =
        TextEditingController(text: currentProfile['bio']);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
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
                style: GoogleFonts.poppins(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 15),
              _buildTextField("Name", nameController),
              _buildTextField("Age", ageController, isNumber: true),
              _buildTextField("Height (ft)", heightController, isNumber: true),
              _buildTextField("Weight (kg)", weightController, isNumber: true),
              _buildTextField("Gender", genderController),
              _buildTextField("Bio", bioController),
              SizedBox(height: 20),
              Container(
                width: double.infinity,
                height: 56, // Fitts' Law: Larger button height
                child: ElevatedButton(
                  onPressed: () async {
                    if (profileData.isNotEmpty) {
                      await _updateProfile(
                          int.parse(ageController.text),
                          int.parse(heightController.text),
                          int.parse(weightController.text),
                          genderController.text,
                          nameController.text,
                          bioController.text);
                    } else {
                      await _addProfile(
                          int.parse(ageController.text),
                          int.parse(heightController.text),
                          int.parse(weightController.text),
                          genderController.text,
                          nameController.text,
                          bioController.text);
                    }
                    await _loadProfileData();
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: Size(
                        double.infinity, 56), // Fitts' Law: Full width button
                  ),
                  child: Text(
                      profileData.isEmpty ? "Create Profile" : "Save Changes",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      )),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

// Helper Function to Create TextFields following Fitts' Law
  Widget _buildTextField(String label, TextEditingController controller,
      {bool isNumber = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(
          vertical: 12), // Increased vertical padding
      child: Container(
        height: 56, // Fitts' Law: Minimum touch target height
        child: TextField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          style: GoogleFonts.poppins(fontSize: 16), // Larger text
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            filled: true,
            fillColor: Colors.grey[100],
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16, // Adequate padding for touch
            ),
            labelStyle: GoogleFonts.poppins(
              color: Colors.black54,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

// Updates Existing Profile Instead of Adding a New One
  Future<void> _updateProfile(
      int age, int height, int weight, String gender, String name, Bio) async {
    if (profileData.isNotEmpty) {
      await DatabaseHelper.instance
          .updateProfile(name, age, height, weight, gender, Bio);
    } else {
      await DatabaseHelper.instance
          .addProfile(name, age, height, weight, gender, Bio);
    }
    await _loadProfileData();
  }

  Future<void> _addProfile(int age, int height, int weight, String gender,
      String name, String Bio) async {
    await DatabaseHelper.instance
        .addProfile(name, age, height, weight, gender, Bio);
    await _loadProfileData();
  }
}
