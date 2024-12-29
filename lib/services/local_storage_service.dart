import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();

  factory LocalStorageService() {
    return _instance;
  }

  LocalStorageService._internal();

  Future<void> saveUser(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(userData));
  }

  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
  }

  Future<Map<String, dynamic>?> fetchUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString('user');
      if (userString == null) {
        return null;
      }
      return jsonDecode(userString);
    } catch (e) {
      print("Error fetching user: $e");
      return null;
    }
  }

  Future<void> saveWellnessData(Map<String, dynamic> wellnessData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('wellness', jsonEncode(wellnessData));
  }

  Future<Map<String, dynamic>?> fetchWellnessData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final wellnessString = prefs.getString('wellness');
      if (wellnessString == null) {
        return null;
      }
      return jsonDecode(wellnessString);
    } catch (e) {
      print("Error fetching wellness data: $e");
      return null;
    }
  }
}
