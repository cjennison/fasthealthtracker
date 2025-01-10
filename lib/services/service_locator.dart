import 'package:fasthealthcheck/services/api/api_user_service.dart';
import 'package:fasthealthcheck/services/api/api_wellness_service.dart';
import 'package:fasthealthcheck/services/api_service.dart';
import 'package:fasthealthcheck/services/session_manager.dart';
import 'package:fasthealthcheck/services/user_service.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final GetIt getIt = GetIt.instance;

void setupServiceLocator() {
  String baseUrl = dotenv.get('API_BASE_URL');

  // Register ApiService
  getIt.registerSingleton<ApiService>(ApiService(baseUrl: baseUrl));

  // Register Subservices
  getIt.registerSingleton<ApiUserService>(
    ApiUserService(baseApiService: getIt<ApiService>()),
  );
  // Register ApiWellnessService and pass the singleton ApiService
  getIt.registerSingleton<ApiWellnessService>(
    ApiWellnessService(baseApiService: getIt<ApiService>()),
  );

  // Register UserService
  getIt.registerSingleton<UserService>(UserService());

  // Register SessionManager
  getIt.registerSingleton<SessionManager>(SessionManager());
}
