import 'package:fasthealthcheck/models/user.dart';
import 'package:flutter/material.dart';

import 'package:fasthealthcheck/services/user_service.dart';
import 'package:provider/provider.dart';

class OnboardingController extends ChangeNotifier {
  final GlobalKey<FormState> step1FormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> step2FormKey = GlobalKey<FormState>();

  /// The activity level of the user
  String activityLevel = 'low';

  int _defaultAge = 25;
  double _defaultWeight = 150.0;
  String _defaultUsername = '';

  int age = 25;
  double weight = 150.0;
  String username = '';

  void setActivityLevel(String value) {
    activityLevel = value;
    notifyListeners();
  }

  void setAge(int value) {
    age = value;
    notifyListeners();
  }

  void setWeight(double value) {
    weight = value;
    notifyListeners();
  }

  void setUsername(String value) {
    username = value;
    notifyListeners();
  }

  /// Validates the form, creates a [UserInfo] object, and navigates to /home
  void submitForm(BuildContext context) {
    if (step1FormKey.currentState!.validate() &&
        step2FormKey.currentState!.validate()) {
      final userInfo = User(
        age: age,
        weight: weight,
        username: username,
        activityLevel: activityLevel,
      );

      Provider.of<UserService>(context, listen: false).saveUser(userInfo);

      // Reset the controller
      username = _defaultUsername;
      age = _defaultAge;
      weight = _defaultWeight;

      Navigator.pushNamedAndRemoveUntil(
        context,
        '/app',
        (route) => false,
      );
    }
  }

  /// Optionally, a dispose to clean up controllers (good practice)
  @override
  void dispose() {
    super.dispose();
  }
}
