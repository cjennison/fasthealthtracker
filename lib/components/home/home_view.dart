import 'package:fasthealthcheck/components/home/health_charts.dart';
import 'package:fasthealthcheck/components/home/home_button_bar.dart';
import 'package:fasthealthcheck/components/home/user_summary_widget.dart';
import 'package:flutter/material.dart';

import 'package:fasthealthcheck/services/user_service.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = UserService().currentUser;

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/onboarding');
      });
    }

    void onFoodTap() {
      Navigator.pushNamed(context, '/food');
    }

    void onExerciseTap() {
      Navigator.pushNamed(context, '/exercise');
    }

    void onWaterTap() {
      Navigator.pushNamed(context, '/water');
    }

    return Scaffold(body: LayoutBuilder(builder: (context, constraints) {
      return Stack(
        children: [
          Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: user != null
                    ? [
                        UserSummaryWidget(user: user),
                        SizedBox(height: 20),
                        Expanded(
                          child: HealthCharts(
                              caloriesConsumed: 690,
                              caloriesRemaining: 410,
                              exerciseBurned: 400),
                        ),
                        HomeButtonBar(
                            onFoodTap: onFoodTap,
                            onExerciseTap: onExerciseTap,
                            onWaterTap: onWaterTap)
                      ]
                    : [],
              ))
        ],
      );
    }));
  }
}
