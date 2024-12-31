import 'package:flutter/material.dart';

class SplashView extends StatelessWidget {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Main content in the center
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(flex: 3),
                const Text(
                  'Gesundr',
                  style: TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Quickly track your daily health in seconds.',
                  style: TextStyle(fontSize: 20, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                Spacer(),
                // Buttons at the bottom
                Column(
                  children: [
                    Column(
                      children: [
                        const Text(
                          'Join for free now!',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/onboarding');
                          },
                          child: const Text('Register'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Column(
                      children: [
                        const Text(
                          'Already have an account?',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/login');
                          }, // Disabled button
                          child: const Text('Log In'),
                        ),
                      ],
                    ),
                  ],
                ),
                Spacer(flex: 3)
              ],
            ),
          ),
        ],
      ),
    );
  }
}
