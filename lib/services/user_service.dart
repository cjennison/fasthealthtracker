import 'package:fasthealthcheck/models/user.dart';
import 'package:fasthealthcheck/services/api/api_user_service.dart';
import 'package:fasthealthcheck/services/api_service.dart';
import 'package:fasthealthcheck/services/local_storage_service.dart';
import 'package:fasthealthcheck/services/service_locator.dart';
import 'package:flutter/material.dart';

class UserService extends ChangeNotifier {
  static final UserService _instance = UserService._internal();
  final ApiService apiService = getIt<ApiService>();
  final ApiUserService apiUserService = getIt<ApiUserService>();

  factory UserService() {
    return _instance;
  }

  UserService._internal();

  User? _currentUser;
  bool userIsVerified = false;

  User? get currentUser => _currentUser;
  bool get isUserVerified => userIsVerified;

  Future<void> initializeUser() async {
    // Check if an Auth token exists, if so attempt to get the current user from the API
    final authToken = await LocalStorageService().fetchAuthToken();
    if (authToken != null) {
      apiService.setAuthToken(authToken);
      LocalStorageService().saveAuthToken(authToken);

      // Fetch currentUser
      try {
        await getCurrentUser();
      } catch (e) {
        print("Error fetching user: $e");
        rethrow;
      }
    }
  }

  void saveUser(User user) async {
    _currentUser = user;
    notifyListeners();
  }

  Future<User?> getCurrentUser() async {
    try {
      // Fetch user details
      final userData = await apiService.fetchCurrentUser();
      final User user = User.getUserFromJson(userData);
      saveUser(user);

      print(user);

      // Fetch user verification status async (No await)
      fetchUserVerificationStatus(user.id);

      return user;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateUserProfile(String id, UserProfile userProfile) async {
    print("Updating user profile: $userProfile");
    // Create a new map of the User object with the updated userProfile
    final updatedUser = _currentUser!.copyWith(userProfile: userProfile);

    //  Optimistic save
    saveUser(updatedUser);

    try {
      await apiUserService.updateUserProfile(id, userProfile.toJson());
    } catch (e) {
      print("Error updating user profile: $e");
    }
  }

  Future<void> updateUserPreferences(
      String id, UserPreferences userPreferences) async {
    // Create a new map of the User object with the updated userProfile
    final updatedUser =
        _currentUser!.copyWith(userPreferences: userPreferences);

    //  Optimistic save
    saveUser(updatedUser);

    try {
      await apiUserService.updateUserPreferences(id, userPreferences.toJson());
    } catch (e) {
      print("Error updating user preferences: $e");
    }
  }

  Future<User> registerUser({
    required String username,
    required String email,
    required String password,
  }) async {
    final result = await apiService.signup(email, username, password);
    apiService.setAuthToken(result['token']);
    LocalStorageService().saveAuthToken(result['token']);

    // Fetch currentUser and save it
    try {
      User? currentUser = await getCurrentUser();
      if (currentUser != null) {
        return currentUser;
      } else {
        throw Exception("Error fetching user after registration");
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> login(
      BuildContext context, String email, String password) async {
    try {
      final result = await apiService.login(email, password);
      apiService.setAuthToken(result['token']);
      LocalStorageService().saveAuthToken(result['token']);

      // Fetch currentUser and save it
      User? currentUser = await getCurrentUser();
      if (currentUser == null) {
        throw Exception("Error fetching user after login");
      }

      Navigator.pushNamedAndRemoveUntil(context, '/app', (route) => false);
    } catch (e) {
      rethrow;
    }
  }

  Future<int> getCalorieTarget(String id, String? activityLevel) async {
    try {
      final data = await apiUserService.getCalorieTarget(id, activityLevel);
      return data['recommendedCalorieGoal'];
    } catch (e) {
      rethrow;
    }
  }

  Future<void> fetchUserVerificationStatus(String id) async {
    try {
      final data = await apiUserService.getUserVerificationStatus(id);
      userIsVerified = data['isEmailVerified'] || data['isSmsVerified'];
    } catch (e) {
      print("Error fetching user verification status: $e");
    }
  }

  Future<void> sendVerificationEmail(String email) async {
    try {
      await apiUserService.resendUserVerificationEmail(email);
    } catch (e) {
      print("Error sending verification email: $e");
    }
  }

  Future<void> verifyUser(
      String id, String email, String verificationCode) async {
    try {
      final data = await apiUserService.postVerificationCode(
          id, email, verificationCode);
      print("User verified: $data");
      fetchUserVerificationStatus(id);
    } catch (e) {
      rethrow; // Allow component to catch for error handling
    }
  }

  void logout() {
    _currentUser = null;
    LocalStorageService().clearAllData();
    apiService.removeAuthToken();
  }
}
