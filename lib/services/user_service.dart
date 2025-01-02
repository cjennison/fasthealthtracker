import 'package:fasthealthcheck/models/user.dart';
import 'package:fasthealthcheck/services/api/api_user_service.dart';
import 'package:fasthealthcheck/services/api_service.dart';
import 'package:fasthealthcheck/services/local_storage_service.dart';
import 'package:flutter/material.dart';

class UserService extends ChangeNotifier {
  static final UserService _instance = UserService._internal();

  factory UserService() {
    return _instance;
  }

  UserService._internal();

  User? _currentUser;

  User? get currentUser => _currentUser;

  Future<void> initializeUser() async {
    // Check if an Auth token exists, if so attempt to get the current user from the API
    final authToken = await LocalStorageService().fetchAuthToken();
    if (authToken != null) {
      ApiService().setAuthToken(authToken);

      // Fetch currentUser
      try {
        final userData = await ApiService().fetchCurrentUser();
        print("User data: $userData");
        final User user = getUserFromJson(userData);
        saveUser(user);
      } catch (e) {
        print("Error fetching user: $e");
      }
    }
  }

  void saveUser(User user) async {
    _currentUser = user;
    notifyListeners();
  }

  Future<void> updateUserProfile(String id, UserProfile userProfile) async {
    // Create a new map of the User object with the updated userProfile
    final updatedUser = _currentUser!.copyWith(userProfile: userProfile);

    //  Optimistic save
    saveUser(updatedUser);

    try {
      await ApiUserService().updateUserProfile(id, userProfile.toJson());
    } catch (e) {
      print("Error updating user profile: $e");
    }
  }

  Future<User> registerUser({
    required String username,
    required String email,
    required String password,
  }) async {
    final result = await ApiService().signup(email, username, password);
    ApiService().setAuthToken(result['token']);
    LocalStorageService().saveAuthToken(result['token']);

    // Fetch currentUser and save it
    final userData = await ApiService().fetchCurrentUser();
    final User user = getUserFromJson(userData);
    saveUser(user);

    return user;
  }

  Future<void> login(
      BuildContext context, String email, String password) async {
    try {
      final result = await ApiService().login(email, password);
      ApiService().setAuthToken(result['token']);
      LocalStorageService().saveAuthToken(result['token']);

      final userData = await ApiService().fetchCurrentUser();
      final User user = getUserFromJson(userData);
      saveUser(user);

      Navigator.pushNamedAndRemoveUntil(context, '/app', (route) => false);
    } catch (e) {
      rethrow;
    }
  }

  User getUserFromJson(Map<String, dynamic> userData) {
    return User.fromJson({
      "id": userData['_id'],
      "username": userData['username'],
      "email": userData['email'],
      "userProfile": {
        "id": userData['userProfile']['_id'],
        "age": userData['userProfile']['age'],
        "weight": userData['userProfile']['weight'],
        "activityLevel": userData['userProfile']['activityLevel'],
      },
    });
  }

  void logout() {
    _currentUser = null;
    LocalStorageService().clearAllData();
    ApiService().removeAuthToken();
  }
}
