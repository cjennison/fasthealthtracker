import 'dart:convert';
import 'package:fasthealthcheck/services/session_manager.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

import 'package:fasthealthcheck/services/api/classes/api_exception.dart';

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  String? _authToken;

  void setAuthToken(String token) {
    _authToken = token;
  }

  void removeAuthToken() {
    _authToken = null;
  }

  String? get authToken => _authToken;

  Future<http.Response> _handleRequest(
      Future<http.Response> Function() request) async {
    try {
      final response = await request();

      if (response.statusCode == 401) {
        final body = jsonDecode(response.body);
        if (body['errorCode'] == 'invalid_token') {
          // Handle invalid token globally
          final sessionManager = GetIt.instance<SessionManager>();
          sessionManager.handleInvalidToken();
        }
      }

      return response;
    } catch (e) {
      rethrow;
    }
  }

  Future<http.Response> post(String endpoint, Map<String, dynamic> body) async {
    return _handleRequest(() {
      final url = Uri.parse("$baseUrl$endpoint");
      return http.post(
        url,
        headers: {
          "Content-Type": "application/json",
          if (_authToken != null) "Authorization": "Bearer $_authToken"
        },
        body: jsonEncode(body),
      );
    });
  }

  Future<http.Response> put(String endpoint, Map<String, dynamic> body) async {
    return _handleRequest(() {
      final url = Uri.parse("$baseUrl$endpoint");
      return http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          if (_authToken != null) "Authorization": "Bearer $_authToken"
        },
        body: jsonEncode(body),
      );
    });
  }

  Future<http.Response> get(String endpoint) async {
    return _handleRequest(() {
      final url = Uri.parse("$baseUrl$endpoint");
      return http.get(
        url,
        headers: {
          "Content-Type": "application/json",
          if (_authToken != null) "Authorization": "Bearer $_authToken"
        },
      );
    });
  }

  Future<http.Response> delete(String endpoint) async {
    return _handleRequest(() {
      final url = Uri.parse("$baseUrl$endpoint");
      return http.delete(
        url,
        headers: {
          "Content-Type": "application/json",
          if (_authToken != null) "Authorization": "Bearer $_authToken"
        },
      );
    });
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response =
        await post("/auth/login", {"email": email, "password": password});
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _authToken = data['token'];
      return data;
    } else {
      throw ApiException(
          message: "Login failed: ${response.body}",
          statusCode: response.statusCode);
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
