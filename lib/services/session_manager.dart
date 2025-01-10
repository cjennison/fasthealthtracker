import 'package:fasthealthcheck/navigator_key.dart';
import 'package:fasthealthcheck/services/api_service.dart';
import 'package:fasthealthcheck/services/service_locator.dart';
import 'package:fasthealthcheck/services/user_service.dart';
import 'package:flutter/material.dart';

class SessionManager {
  final UserService userService = getIt<UserService>();
  final ApiService apiService = getIt<ApiService>();

  void handleInvalidToken(BuildContext context) {
    userService.logout();
    apiService.removeAuthToken();

    // Navigate to the login screen
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/splash',
      (route) => false, // Remove all previous routes
    );
  }
}
