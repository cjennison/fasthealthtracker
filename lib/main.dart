import 'package:fasthealthcheck/components/auth/forgotten_password_view.dart';
import 'package:fasthealthcheck/components/auth/reset_password_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:fasthealthcheck/components/home/profile_view.dart';
import 'package:fasthealthcheck/components/login_view.dart';
import 'package:fasthealthcheck/components/onboarding/new_user_view.dart';
import 'package:fasthealthcheck/components/splash_view.dart';
import 'package:fasthealthcheck/components/exercise/exercise_input_view.dart';
import 'package:fasthealthcheck/components/food/food_input_view.dart';
import 'package:fasthealthcheck/components/home/home_view.dart';
import 'package:fasthealthcheck/components/log/activity_log_view.dart';
import 'package:fasthealthcheck/services/wellness_service.dart';
import 'package:fasthealthcheck/services/user_service.dart';
import 'package:fasthealthcheck/services/service_locator.dart';

import 'package:fasthealthcheck/components/startup.dart';
import 'package:fasthealthcheck/navigator_key.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  setupServiceLocator();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => UserService()),
      ChangeNotifierProvider(create: (context) => WellnessService()),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Gesundr',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        initialRoute: '/',
        home: StartupView(),
        navigatorKey:
            navigatorKey, // Allows global navigation from anywhere in the app
        routes: {
          '/splash': (context) => const SplashView(),
          '/login': (context) => const LoginView(),
          '/onboarding': (context) => const NewUserView(),
          '/app': (context) => const HomeView(),
          '/food': (context) => const FoodInputView(),
          '/exercise': (context) => const ExerciseInputView(),
          '/log': (context) => const ActivityLogView(),
          '/profile': (context) => const ProfileView(),
          '/forgot-password': (context) => const ForgottenPasswordView(),
          '/reset-password': (context) => const ResetPasswordView(),
        },
        onUnknownRoute: (settings) => MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(title: Text('Unknown Route')),
                body: Center(child: Text('Page not found')),
              ),
            ));
  }
}
