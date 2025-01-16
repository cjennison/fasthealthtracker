import 'package:fasthealthcheck/components/utils/show_snackbar.dart';
import 'package:fasthealthcheck/constants/error_codes.dart';
import 'package:fasthealthcheck/navigator_key.dart';
import 'package:fasthealthcheck/services/api_service.dart';
import 'package:fasthealthcheck/services/service_locator.dart';
import 'package:fasthealthcheck/services/user_service.dart';

class SessionManager {
  final UserService userService = getIt<UserService>();
  final ApiService apiService = getIt<ApiService>();

  void handleInvalidToken() {
    userService.logout();
    apiService.removeAuthToken();

    print(
        "Invalid token detected. Logging out and navigating to login screen.");

    // Navigate to the login screen
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/splash',
      (route) => false, // Remove all previous routes
    );

    showSnackbar(
        navigatorKey.currentContext!,
        errorMessages[ErrorCodes.invalidToken].userFriendlyMessage,
        SnackbarType.error);
  }
}
