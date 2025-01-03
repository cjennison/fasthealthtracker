import 'package:fasthealthcheck/components/home/home_button_bar.dart';
import 'package:fasthealthcheck/components/home/user_summary_widget.dart';
import 'package:fasthealthcheck/components/home/wellness_bars.dart';
import 'package:flutter/material.dart';

import 'package:fasthealthcheck/services/user_service.dart';
import 'package:fasthealthcheck/services/wellness_service.dart';
import 'package:provider/provider.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final userService = Provider.of<UserService>(context);

    if (userService.currentUser == null) {
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
      Provider.of<WellnessService>(context, listen: false).addWater();
    }

    return Scaffold(body: LayoutBuilder(builder: (context, constraints) {
      return Consumer<WellnessService>(
          builder: (context, wellnessService, constraints) {
        return Stack(
          children: [
            Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: userService.currentUser != null
                      ? [
                          UserSummaryWidget(user: userService.currentUser!),
                          SizedBox(height: 20),
                          Expanded(child: WellnessBars()),
                          /*
                          Expanded(
                            child: HealthCharts(),
                          ),
                          */
                          HomeButtonBar(
                              onFoodTap: onFoodTap,
                              onExerciseTap: onExerciseTap,
                              onWaterTap: onWaterTap)
                        ]
                      : [],
                ))
          ],
        );
      });
    }));
  }
}
