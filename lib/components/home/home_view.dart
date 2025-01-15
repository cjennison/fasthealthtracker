import 'package:fasthealthcheck/components/home/home_button_bar.dart';
import 'package:fasthealthcheck/components/home/user_summary_widget.dart';
import 'package:fasthealthcheck/components/home/wellness_bars.dart';
import 'package:fasthealthcheck/models/wellness.dart';
import 'package:flutter/material.dart';

import 'package:fasthealthcheck/services/user_service.dart';
import 'package:fasthealthcheck/services/wellness_service.dart';
import 'package:provider/provider.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    initializeData();
  }

  Future<void> initializeData() async {
    final userService = Provider.of<UserService>(context, listen: false);

    if (userService.currentUser != null) {
      final wellnessService =
          Provider.of<WellnessService>(context, listen: false);

      await wellnessService.initializeWellnessData();
      setState(() {
        isLoading = false;
      });
    } else {
      // Something went wrong, go back to the splash screen
      Navigator.pushReplacementNamed(context, '/splash');
    }
  }

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
      final wellnessService =
          Provider.of<WellnessService>(context, listen: false);
      wellnessService
          .setWater(wellnessService.currentDateWellnessData.glassesOfWater + 1);
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
                )),
            if (isLoading)
              Container(
                color: Colors.black
                    // ignore: deprecated_member_use
                    .withOpacity(0.5), // Semi-transparent background
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        );
      });
    }));
  }
}
