import 'dart:convert';
import 'package:fasthealthcheck/services/api/classes/api_exception.dart';
import 'package:fasthealthcheck/services/api/classes/api_wellness.dart';
import 'package:fasthealthcheck/services/api_service.dart';

class ApiWellnessService extends ApiService {
  ApiWellnessService() : super.protected() {
    // Set the auth token from the ApiService
    setAuthToken(ApiService().authToken ?? '');
  }

  // Fetch wellness data for a range of dates
  Future<List<dynamic>> getWellnessDataByDateRange(
      String userId, String startDate, String endDate) async {
    final endpoint =
        "/wellness/users/$userId/daterange?startDate=$startDate&endDate=$endDate";
    final response = await get(endpoint);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch wellness data: ${response.body}");
    }
  }

  // Fetch wellness data for a specific date
  Future<Map<String, dynamic>> getWellnessDataByDate(
      String userId, String date) async {
    final endpoint = "/wellness/users/$userId/$date";
    final response = await get(endpoint);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          "Failed to fetch wellness data for date: ${response.body}");
    }
  }

  // Fetch wellness streak number
  Future<Map<String, dynamic>> getWellnessStreak(String userId) async {
    final endpoint = "/wellness/users/$userId/streak";
    final response = await get(endpoint);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          "Failed to fetch wellness data for date: ${response.body}");
    }
  }

  // Add new wellness data for a specific date
  Future<Map<String, dynamic>> createWellnessData(
      String userId, String date, int glassesOfWater) async {
    final endpoint = "/wellness";
    final response = await post(endpoint, {
      "userId": userId,
      "date": date,
      "glassesOfWater": glassesOfWater,
    });
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw ApiException(
        message: "Failed to create wellness data",
        statusCode: response.statusCode,
      );
    }
  }

  // Update wellness data by ID
  Future<Map<String, dynamic>> updateWellnessData(
      String id, Map<String, dynamic> data) async {
    final endpoint = "/wellness/$id";
    final payload = {
      "glassesOfWater": data["glassesOfWater"],
    };
    final response = await put(endpoint, payload);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to update wellness data: ${response.body}");
    }
  }

  // Add a food entry to wellness data
  Future<Map<String, dynamic>> addFoodEntry(
      String wellnessDataId, FoodEntryPayload data) async {
    final endpoint = "/wellness/$wellnessDataId/food";
    final response = await post(endpoint, data.toJson());
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to add food entry: ${response.body}");
    }
  }

  // Add an exercise entry to wellness data
  Future<Map<String, dynamic>> addExerciseEntry(
      String wellnessDataId, ExerciseEntryPayload data) async {
    final endpoint = "/wellness/$wellnessDataId/exercise";
    final response = await post(endpoint, data.toJson());
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to add exercise entry: ${response.body}");
    }
  }

  // Add a food entry to wellness data
  Future<Map<String, dynamic>> deleteFoodEntry(
      String wellnessDataId, String foodEntryId) async {
    final endpoint = "/wellness/$wellnessDataId/food/$foodEntryId";
    final response = await delete(endpoint);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to add food entry: ${response.body}");
    }
  }

  // Add an exercise entry to wellness data
  Future<Map<String, dynamic>> deleteExerciseEntry(
      String wellnessDataId, String exerciseEntryId) async {
    final endpoint = "/wellness/$wellnessDataId/exercise/$exerciseEntryId";
    final response = await delete(endpoint);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to add exercise entry: ${response.body}");
    }
  }
}
