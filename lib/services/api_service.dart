import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  ApiService.protected();

  String? get baseUrl {
    return dotenv.get('API_BASE_URL');
  }

  String? _authToken;

  void setAuthToken(String token) {
    _authToken = token;
  }

  void removeAuthToken() {
    _authToken = null;
  }

  String? get authToken => _authToken;

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse("$baseUrl$endpoint");
    return await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        if (_authToken != null) "Authorization": "Bearer $_authToken"
      },
      body: jsonEncode(body),
    );
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    final url = Uri.parse("$baseUrl$endpoint");
    return await http.put(
      url,
      headers: {
        "Content-Type": "application/json",
        if (_authToken != null) "Authorization": "Bearer $_authToken"
      },
      body: jsonEncode(body),
    );
  }

  Future<http.Response> get(String endpoint) async {
    final url = Uri.parse("$baseUrl$endpoint");
    return await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        if (_authToken != null) "Authorization": "Bearer $_authToken"
      },
    );
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response =
        await post("/auth/login", {"email": email, "password": password});
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _authToken = data['token'];
      return data;
    } else {
      throw Exception("Login failed: ${response.body}");
    }
  }

  Future<Map<String, dynamic>> signup(
      String email, String username, String password) async {
    final response = await post("/auth/signup", {
      "email": email,
      "username": username,
      "password": password,
    });
    if (response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Signup failed: ${response.body}");
    }
  }

  Future<Map<String, dynamic>> fetchCurrentUser() async {
    final response = await get("/auth/currentUser");
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to fetch current user: ${response.body}");
    }
  }
}
