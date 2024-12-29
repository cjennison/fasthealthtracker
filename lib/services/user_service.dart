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
      _currentUser = User(
        age: user['age'],
        weight: user['weight'],
        username: user['username'],
        activityLevel: user['activityLevel'],
      );
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

  void logout() {
    _currentUser = null;
    LocalStorageService().clearAllData();
  }
}
