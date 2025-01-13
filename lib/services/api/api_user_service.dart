import 'package:fasthealthcheck/services/api_service.dart';

class ApiUserService {
  final ApiService baseApiService;
  ApiUserService({required this.baseApiService});

  Future<Map<String, dynamic>> getUserVerificationStatus(String id) async {
    final response =
        await baseApiService.get("/auth/users/$id/verification-status");
    return baseApiService.handleApiResponse(response);
  }

  Future<Map<String, dynamic>> resendUserVerificationEmail(String email) async {
    final response = await baseApiService
        .post("/auth/resend-verification", {"email": email, "type": "email"});
    return baseApiService.handleApiResponse(response);
  }

  Future<Map<String, dynamic>> postVerificationCode(
      String id, String email, String verificationCode) async {
    final response = await baseApiService.post("/auth/users/$id/verify", {
      "email": email,
      "type": "email",
      "verificationCode": verificationCode,
    });
    return baseApiService.handleApiResponse(response);
  }

  Future<Map<String, dynamic>> changePassword(
      String id, Map<String, dynamic> changePasswordPayload) async {
    final response = await baseApiService.put(
        "/auth/users/$id/password", changePasswordPayload);
    return baseApiService.handleApiResponse(response);
  }

  Future<Map<String, dynamic>> updateUserProfile(
      String id, Map<String, dynamic> userProfile) async {
    final response =
        await baseApiService.put("/users/$id/profile", userProfile);
    return baseApiService.handleApiResponse(response);
  }

  Future<Map<String, dynamic>> updateUserPreferences(
      String id, Map<String, dynamic> userPreferences) async {
    final response =
        await baseApiService.put("/users/$id/preferences", userPreferences);
    return baseApiService.handleApiResponse(response);
  }

  Future<Map<String, dynamic>> getCalorieTarget(
      String id, String? activityLevel) async {
    String url = "/users/$id/recommended-calorie-goal";
    if (activityLevel != null) {
      url += "?activityLevel=$activityLevel";
    }
    final response = await baseApiService.get(url);
    return baseApiService.handleApiResponse(response);
  }
}
