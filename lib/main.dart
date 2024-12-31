import 'package:fasthealthcheck/components/home/profile_view.dart';
import 'package:fasthealthcheck/components/login_view.dart';
import 'package:fasthealthcheck/components/onboarding/new_user_view.dart';
import 'package:fasthealthcheck/components/splash_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:fasthealthcheck/components/exercise/exercise_input_view.dart';
import 'package:fasthealthcheck/components/food/food_input_view.dart';
import 'package:fasthealthcheck/components/home/home_view.dart';
import 'package:fasthealthcheck/components/log/activity_log_view.dart';
import 'package:fasthealthcheck/services/wellness_service.dart';
import 'package:fasthealthcheck/services/user_service.dart';
import 'package:fasthealthcheck/components/startup.dart';

void main() {
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
        routes: {
          '/splash': (context) => const SplashView(),
          '/login': (context) => const LoginView(),
          '/onboarding': (context) => const NewUserView(),
          '/app': (context) => const HomeView(),
          '/food': (context) => const FoodInputView(),
          '/exercise': (context) => const ExerciseInputView(),
          '/log': (context) => const ActivityLogView(),
          '/profile': (context) => const ProfileView(),
        },
        onUnknownRoute: (settings) => MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(title: Text('Unknown Route')),
                body: Center(child: Text('Page not found')),
              ),
            ));
  }
}
