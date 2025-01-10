import 'dart:convert';
import 'package:fasthealthcheck/services/api/classes/api_exception.dart';
import 'package:fasthealthcheck/services/api/classes/api_wellness.dart';
import 'package:fasthealthcheck/services/api_service.dart';

class ApiWellnessService {
  final ApiService baseApiService;
  ApiWellnessService({required this.baseApiService});

  // Fetch wellness data for a range of dates (unused)
  Future<Map<String, dynamic>> getWellnessDataByDateRange(
      String userId, String startDate, String endDate) async {
    final endpoint =
        "/wellness/users/$userId/daterange?startDate=$startDate&endDate=$endDate";
    final response = await baseApiService.get(endpoint);
    return baseApiService.handleApiResponse(response);
  }

  // Fetch wellness data for a specific date
  Future<Map<String, dynamic>> getWellnessDataByDate(
      String userId, String date) async {
    final endpoint = "/wellness/users/$userId/$date";
    final response = await baseApiService.get(endpoint);
    return baseApiService.handleApiResponse(response);
  }

  // Fetch wellness streak number
  Future<Map<String, dynamic>> getWellnessStreak(String userId) async {
    final endpoint = "/wellness/users/$userId/streak";
    final response = await baseApiService.get(endpoint);
    return baseApiService.handleApiResponse(response);
  }

  // Add new wellness data for a specific date
  Future<Map<String, dynamic>> createWellnessData(
      String userId, String date, int glassesOfWater) async {
    final endpoint = "/wellness";
    final response = await baseApiService.post(endpoint, {
      "userId": userId,
      "date": date,
      "glassesOfWater": glassesOfWater,
    });
    return baseApiService.handleApiResponse(response);
  }

  // Update wellness data by ID
  Future<Map<String, dynamic>> updateWellnessData(
      String id, Map<String, dynamic> data) async {
    final endpoint = "/wellness/$id";
    final payload = {
      "glassesOfWater": data["glassesOfWater"],
    };
    final response = await baseApiService.put(endpoint, payload);
    return baseApiService.handleApiResponse(response);
  }

  // Add a food entry to wellness data
  Future<Map<String, dynamic>> addFoodEntry(
      String wellnessDataId, FoodEntryPayload data) async {
    final endpoint = "/wellness/$wellnessDataId/food";
    final response = await baseApiService.post(endpoint, data.toJson());
    return baseApiService.handleApiResponse(response);
  }

  // Add an exercise entry to wellness data
  Future<Map<String, dynamic>> addExerciseEntry(
      String wellnessDataId, ExerciseEntryPayload data) async {
    final endpoint = "/wellness/$wellnessDataId/exercise";
    final response = await baseApiService.post(endpoint, data.toJson());
    return baseApiService.handleApiResponse(response);
  }

  // Add a food entry to wellness data
  Future<Map<String, dynamic>> deleteFoodEntry(
      String wellnessDataId, String foodEntryId) async {
    final endpoint = "/wellness/$wellnessDataId/food/$foodEntryId";
    final response = await baseApiService.delete(endpoint);
    return baseApiService.handleApiResponse(response);
  }

  // Add an exercise entry to wellness data
  Future<Map<String, dynamic>> deleteExerciseEntry(
      String wellnessDataId, String exerciseEntryId) async {
    final endpoint = "/wellness/$wellnessDataId/exercise/$exerciseEntryId";
    final response = await baseApiService.delete(endpoint);
    return baseApiService.handleApiResponse(response);
  }
}
