import 'package:fasthealthcheck/components/home/home_view.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:fasthealthcheck/components/onboarding/onboarding_view.dart';
import 'components/onboarding/onboarding_controller.dart';

void main() {
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => OnboardingController()),
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
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        initialRoute: '/onboarding',
        routes: {
          '/onboarding': (context) => const OnboardingView(),
          '/app': (context) => const HomeView(),
        },
        onUnknownRoute: (settings) => MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(title: Text('Unknown Route')),
                body: Center(child: Text('Page not found')),
              ),
            ));
  }
}
