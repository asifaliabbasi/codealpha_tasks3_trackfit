import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/services/auth_service.dart';

// Auth state class
class AuthState {
  final bool isLoading;
  final bool isLoggedIn;
  final int? userId;
  final Map<String, dynamic>? user;
  final Map<String, dynamic>? userProfile;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.isLoggedIn = false,
    this.userId,
    this.user,
    this.userProfile,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isLoggedIn,
    int? userId,
    Map<String, dynamic>? user,
    Map<String, dynamic>? userProfile,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
      userId: userId ?? this.userId,
      user: user ?? this.user,
      userProfile: userProfile ?? this.userProfile,
      error: error ?? this.error,
    );
  }
}

// Auth notifier
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService = AuthService();

  AuthNotifier() : super(const AuthState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);
    try {
      await _authService.initialize();

      if (_authService.isLoggedIn) {
        state = state.copyWith(
          isLoading: false,
          isLoggedIn: true,
          userId: _authService.currentUserId,
          user: _authService.currentUser,
          userProfile: _authService.currentUserProfile,
        );
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<AuthResult> login({
    required String usernameOrEmail,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _authService.login(
        usernameOrEmail: usernameOrEmail,
        password: password,
      );

      if (result.success) {
        state = state.copyWith(
          isLoading: false,
          isLoggedIn: true,
          userId: _authService.currentUserId,
          user: _authService.currentUser,
          userProfile: _authService.currentUserProfile,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result.message,
        );
      }

      return result;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return AuthResult.error('Login failed. Please try again.');
    }
  }

  Future<AuthResult> register({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _authService.register(
        username: username,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
      );

      if (result.success) {
        state = state.copyWith(
          isLoading: false,
          isLoggedIn: true,
          userId: _authService.currentUserId,
          user: _authService.currentUser,
          userProfile: _authService.currentUserProfile,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result.message,
        );
      }

      return result;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return AuthResult.error('Registration failed. Please try again.');
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    try {
      await _authService.logout();
      state = state.copyWith(
        isLoading: false,
        isLoggedIn: false,
        userId: null,
        user: null,
        userProfile: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<AuthResult> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmNewPassword: confirmNewPassword,
      );

      state = state.copyWith(isLoading: false);
      return result;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return AuthResult.error('Failed to change password. Please try again.');
    }
  }

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
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _authService.updateProfile(
        name: name,
        age: age,
        height: height,
        weight: weight,
        gender: gender,
        bio: bio,
        fitnessLevel: fitnessLevel,
        activityLevel: activityLevel,
      );

      if (result.success) {
        await _authService.refreshUserData();
        state = state.copyWith(
          isLoading: false,
          userProfile: _authService.currentUserProfile,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result.message,
        );
      }

      return result;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      return AuthResult.error('Failed to update profile. Please try again.');
    }
  }

  Future<void> refreshUserData() async {
    try {
      await _authService.refreshUserData();
      state = state.copyWith(
        user: _authService.currentUser,
        userProfile: _authService.currentUserProfile,
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Auth provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

// Convenience providers
final isLoggedInProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoggedIn;
});

final currentUserProvider = Provider<Map<String, dynamic>?>((ref) {
  return ref.watch(authProvider).user;
});

final currentUserProfileProvider = Provider<Map<String, dynamic>?>((ref) {
  return ref.watch(authProvider).userProfile;
});

final currentUserIdProvider = Provider<int?>((ref) {
  return ref.watch(authProvider).userId;
});

final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});

final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).error;
});
