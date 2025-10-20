import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Database/DataBase_Helper.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  static const String _userKey = 'current_user_id';
  static const String _isLoggedInKey = 'is_logged_in';

  // Current user data
  int? _currentUserId;
  Map<String, dynamic>? _currentUser;
  Map<String, dynamic>? _currentUserProfile;

  // Getters
  int? get currentUserId => _currentUserId;
  Map<String, dynamic>? get currentUser => _currentUser;
  Map<String, dynamic>? get currentUserProfile => _currentUserProfile;
  bool get isLoggedIn => _currentUserId != null;

  // Initialize auth service
  Future<void> initialize() async {
    await _loadCurrentUser();
  }

  // Load current user from SharedPreferences
  Future<void> _loadCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt(_userKey);
      final isLoggedIn = prefs.getBool(_isLoggedInKey) ?? false;

      if (userId != null && isLoggedIn) {
        _currentUserId = userId;
        _currentUser = await _dbHelper.getUserByUsername(''); // We'll get by ID
        _currentUserProfile = await _dbHelper.getUserProfile(userId);
      }
    } catch (e) {
      print('Error loading current user: $e');
      await logout();
    }
  }

  // Save current user to SharedPreferences
  Future<void> _saveCurrentUser(int userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_userKey, userId);
      await prefs.setBool(_isLoggedInKey, true);
    } catch (e) {
      print('Error saving current user: $e');
    }
  }

  // Clear current user from SharedPreferences
  Future<void> _clearCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      await prefs.setBool(_isLoggedInKey, false);
    } catch (e) {
      print('Error clearing current user: $e');
    }
  }

  // Generate salt for password hashing
  String _generateSalt() {
    final random = Random.secure();
    final saltBytes = List<int>.generate(32, (i) => random.nextInt(256));
    return base64Encode(saltBytes);
  }

  // Hash password with salt
  String _hashPassword(String password, String salt) {
    final key = utf8.encode(password);
    final saltBytes = base64Decode(salt);
    final hmac = Hmac(sha256, saltBytes);
    final digest = hmac.convert(key);
    return digest.toString();
  }

  // Validate password strength
  bool _isPasswordStrong(String password) {
    if (password.length < 8) return false;
    
    bool hasUpperCase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowerCase = password.contains(RegExp(r'[a-z]'));
    bool hasDigits = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialCharacters = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));
    
    return hasUpperCase && hasLowerCase && hasDigits && hasSpecialCharacters;
  }

  // Validate email format
  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Validate username format
  bool _isValidUsername(String username) {
    return RegExp(r'^[a-zA-Z0-9_]{3,20}$').hasMatch(username);
  }

  // Register new user
  Future<AuthResult> register({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    try {
      // Validation
      if (!_isValidUsername(username)) {
        return AuthResult.error('Username must be 3-20 characters long and contain only letters, numbers, and underscores');
      }

      if (!_isValidEmail(email)) {
        return AuthResult.error('Please enter a valid email address');
      }

      if (!_isPasswordStrong(password)) {
        return AuthResult.error('Password must be at least 8 characters long and contain uppercase, lowercase, numbers, and special characters');
      }

      if (password != confirmPassword) {
        return AuthResult.error('Passwords do not match');
      }

      // Check if username already exists
      final existingUserByUsername = await _dbHelper.getUserByUsername(username);
      if (existingUserByUsername != null) {
        return AuthResult.error('Username already exists');
      }

      // Check if email already exists
      final existingUserByEmail = await _dbHelper.getUserByEmail(email);
      if (existingUserByEmail != null) {
        return AuthResult.error('Email already registered');
      }

      // Hash password
      final salt = _generateSalt();
      final passwordHash = _hashPassword(password, salt);

      // Create user
      final userId = await _dbHelper.createUser(username, email, passwordHash, salt);
      if (userId == -1) {
        return AuthResult.error('Failed to create user account');
      }

      // Save current user
      _currentUserId = userId;
      _currentUser = await _dbHelper.getUserByUsername(username);
      await _saveCurrentUser(userId);

      return AuthResult.success('Account created successfully');
    } catch (e) {
      print('Registration error: $e');
      return AuthResult.error('Registration failed. Please try again.');
    }
  }

  // Login user
  Future<AuthResult> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    try {
      // Find user by username or email
      Map<String, dynamic>? user;
      if (_isValidEmail(usernameOrEmail)) {
        user = await _dbHelper.getUserByEmail(usernameOrEmail);
      } else {
        user = await _dbHelper.getUserByUsername(usernameOrEmail);
      }

      if (user == null) {
        return AuthResult.error('Invalid username/email or password');
      }

      // Verify password
      final storedSalt = user['salt'] as String;
      final storedPasswordHash = user['password_hash'] as String;
      final inputPasswordHash = _hashPassword(password, storedSalt);

      if (inputPasswordHash != storedPasswordHash) {
        return AuthResult.error('Invalid username/email or password');
      }

      // Check if account is active
      if (user['is_active'] != 1) {
        return AuthResult.error('Account is deactivated');
      }

      // Update last login
      await _dbHelper.updateLastLogin(user['id']);

      // Save current user
      _currentUserId = user['id'];
      _currentUser = user;
      _currentUserProfile = await _dbHelper.getUserProfile(user['id']);
      await _saveCurrentUser(user['id']);

      return AuthResult.success('Login successful');
    } catch (e) {
      print('Login error: $e');
      return AuthResult.error('Login failed. Please try again.');
    }
  }

  // Logout user
  Future<void> logout() async {
    try {
      _currentUserId = null;
      _currentUser = null;
      _currentUserProfile = null;
      await _clearCurrentUser();
    } catch (e) {
      print('Logout error: $e');
    }
  }

  // Change password
  Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    try {
      if (_currentUserId == null) {
        return AuthResult.error('User not logged in');
      }

      if (!_isPasswordStrong(newPassword)) {
        return AuthResult.error('New password must be at least 8 characters long and contain uppercase, lowercase, numbers, and special characters');
      }

      if (newPassword != confirmNewPassword) {
        return AuthResult.error('New passwords do not match');
      }

      // Get current user data
      final user = _currentUser;
      if (user == null) {
        return AuthResult.error('User data not found');
      }

      // Verify current password
      final storedSalt = user['salt'] as String;
      final storedPasswordHash = user['password_hash'] as String;
      final currentPasswordHash = _hashPassword(currentPassword, storedSalt);

      if (currentPasswordHash != storedPasswordHash) {
        return AuthResult.error('Current password is incorrect');
      }

      // Generate new salt and hash
      final newSalt = _generateSalt();
      final newPasswordHash = _hashPassword(newPassword, newSalt);

      // Update password in database
      final db = await _dbHelper.database;
      final result = await db.update(
        'users',
        {
          'password_hash': newPasswordHash,
          'salt': newSalt,
        },
        where: 'id = ?',
        whereArgs: [_currentUserId],
      );

      if (result > 0) {
        // Update current user data
        _currentUser!['password_hash'] = newPasswordHash;
        _currentUser!['salt'] = newSalt;
        return AuthResult.success('Password changed successfully');
      } else {
        return AuthResult.error('Failed to update password');
      }
    } catch (e) {
      print('Change password error: $e');
      return AuthResult.error('Failed to change password. Please try again.');
    }
  }

  // Reset password (for future implementation with email verification)
  Future<AuthResult> resetPassword({
    required String email,
  }) async {
    try {
      final user = await _dbHelper.getUserByEmail(email);
      if (user == null) {
        return AuthResult.error('No account found with this email');
      }

      // TODO: Implement email verification and password reset
      return AuthResult.error('Password reset not implemented yet');
    } catch (e) {
      print('Reset password error: $e');
      return AuthResult.error('Password reset failed. Please try again.');
    }
  }

  // Update user profile
  Future<AuthResult> updateProfile({
    required String name,
    required int age,
    required double height,
    required double weight,
    required String gender,
    String? bio,
    String? fitnessLevel,
    String? activityLevel,
  }) async {
    try {
      if (_currentUserId == null) {
        return AuthResult.error('User not logged in');
      }

      // Validation
      if (name.trim().isEmpty) {
        return AuthResult.error('Name cannot be empty');
      }

      if (age < 13 || age > 120) {
        return AuthResult.error('Please enter a valid age');
      }

      if (height < 50 || height > 300) {
        return AuthResult.error('Please enter a valid height (50-300 cm)');
      }

      if (weight < 20 || weight > 500) {
        return AuthResult.error('Please enter a valid weight (20-500 kg)');
      }

      if (!['male', 'female', 'other'].contains(gender.toLowerCase())) {
        return AuthResult.error('Please select a valid gender');
      }

      // Check if profile exists
      final existingProfile = await _dbHelper.getUserProfile(_currentUserId!);
      
      final updates = {
        'name': name.trim(),
        'age': age,
        'height': height,
        'weight': weight,
        'gender': gender.toLowerCase(),
        'bio': bio?.trim(),
        'fitness_level': fitnessLevel ?? 'beginner',
        'activity_level': activityLevel ?? 'moderate',
      };

      int result;
      if (existingProfile != null) {
        result = await _dbHelper.updateUserProfile(_currentUserId!, updates);
      } else {
        result = await _dbHelper.createUserProfile(
          _currentUserId!,
          name.trim(),
          age,
          height,
          weight,
          gender.toLowerCase(),
          bio: bio?.trim(),
          fitnessLevel: fitnessLevel,
          activityLevel: activityLevel,
        );
      }

      if (result > 0) {
        _currentUserProfile = await _dbHelper.getUserProfile(_currentUserId!);
        return AuthResult.success('Profile updated successfully');
      } else {
        return AuthResult.error('Failed to update profile');
      }
    } catch (e) {
      print('Update profile error: $e');
      return AuthResult.error('Failed to update profile. Please try again.');
    }
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    if (_currentUserId == null) return null;
    
    try {
      _currentUserProfile = await _dbHelper.getUserProfile(_currentUserId!);
      return _currentUserProfile;
    } catch (e) {
      print('Get user profile error: $e');
      return null;
    }
  }

  // Refresh user data
  Future<void> refreshUserData() async {
    if (_currentUserId == null) return;
    
    try {
      _currentUser = await _dbHelper.getUserByUsername(_currentUser!['username']);
      _currentUserProfile = await _dbHelper.getUserProfile(_currentUserId!);
    } catch (e) {
      print('Refresh user data error: $e');
    }
  }
}

// Auth result class
class AuthResult {
  final bool success;
  final String message;

  AuthResult._(this.success, this.message);

  factory AuthResult.success(String message) => AuthResult._(true, message);
  factory AuthResult.error(String message) => AuthResult._(false, message);
}
