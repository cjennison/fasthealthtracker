import 'dart:convert';
import 'package:fasthealthcheck/services/api_service.dart';

class ApiUserService extends ApiService {
  // Constructor
  ApiUserService() : super.protected() {
    // Set the auth token from the ApiService
    setAuthToken(ApiService().authToken ?? '');
  }

  Future<Map<String, dynamic>> getUserVerificationStatus(String id) async {
    final response = await get("/auth/users/$id/verification-status");
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception(
          "Failed to get user verification status: ${response.body}");
    }
  }

  Future<Map<String, dynamic>> resendUserVerificationEmail(String email) async {
    final response = await post(
        "/auth/resend-verification", {"email": email, "type": "email"});
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception(
          "Failed to resend user verification email: ${response.body}");
    }
  }

  Future<Map<String, dynamic>> postVerificationCode(
      String id, String email, String verificationCode) async {
    final response = await post("/auth/users/$id/verify", {
      "email": email,
      "type": "email",
      "verificationCode": verificationCode,
    });
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception("Failed to post verification code: ${response.body}");
    }
  }

  Future<Map<String, dynamic>> updateUserProfile(
      String id, Map<String, dynamic> userProfile) async {
    final response = await put("/users/$id/profile", userProfile);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception("Failed to update user profile: ${response.body}");
    }
  }
}
