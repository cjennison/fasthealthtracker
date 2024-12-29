import 'package:fasthealthcheck/models/user.dart';
import 'package:fasthealthcheck/services/local_storage_service.dart';

class UserService {
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
    }
  }

  void saveUser(User user) async {
    _currentUser = user;
    await LocalStorageService().saveUser(user.toJson());
  }

  void logout() {
    _currentUser = null;
    LocalStorageService().clearAllData();
  }
}
