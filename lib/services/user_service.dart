import 'package:fasthealthcheck/models/user.dart';

class UserService {
  static final UserService _instance = UserService._internal();

  factory UserService() {
    return _instance;
  }

  UserService._internal();

  User? _currentUser;

  User? get currentUser => _currentUser;

  void saveUser(User user) {
    _currentUser = user;
  }

  void clearUser() {
    _currentUser = null;
  }

  // Mocked responses or additional methods can go here
  Future<User> mockFetchUser() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    return User(
      age: 30,
      weight: 160,
      username: "Mock User",
      activityLevel: "active",
    );
  }
}
