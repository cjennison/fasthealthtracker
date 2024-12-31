import 'package:fasthealthcheck/models/user.dart';
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
    final user = await LocalStorageService().fetchUser();
    if (user != null) {
      _currentUser = User.fromJson(user);
      notifyListeners();
    }
  }

  void saveUser(User user) async {
    _currentUser = user;
    await LocalStorageService().saveUser(user.toJson());
    notifyListeners();
  }

  void clearUser() {
    _currentUser = null;
    LocalStorageService().clearUser();
    notifyListeners();
  }

  Future<User> registerUser({
    required String username,
    required String password,
  }) async {
    // Placeholder for future functionality to call API to register a user
    debugPrint("Register function called");

    // Return the confirmed new user (without password)
    return User(
      username: username,

      // default values for new user
      age: 25,
      weight: 150.0,
      activityLevel: 'medium',
    );
  }

  void login() {
    // Placeholder for future functionality
    debugPrint("Login function called");
  }

  void logout() {
    _currentUser = null;
    LocalStorageService().clearAllData();
  }
}
