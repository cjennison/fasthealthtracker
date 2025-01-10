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

  Future<Map<String, dynamic>> updateUserProfile(
      String id, Map<String, dynamic> userProfile) async {
    final response =
        await baseApiService.put("/users/$id/profile", userProfile);
    return baseApiService.handleApiResponse(response);
  }
}
