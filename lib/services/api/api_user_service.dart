import 'dart:convert';
import 'package:fasthealthcheck/services/api_service.dart';

class ApiUserService extends ApiService {
  // Constructor
  ApiUserService() : super.protected() {
    // Set the auth token from the ApiService
    setAuthToken(ApiService().authToken ?? '');
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
