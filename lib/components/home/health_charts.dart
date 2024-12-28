import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

import 'package:fasthealthcheck/services/wellness_service.dart';

class HealthCharts extends StatelessWidget {
  const HealthCharts({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, lConstraints) {
        return Consumer<WellnessService>(
          builder: (context, wellnessService, constraints) {
            final isWideScreen = lConstraints.maxWidth > 480;

            final calorieChart = CalorieChart(
              caloriesConsumed: wellnessService.caloriesConsumed.toDouble(),
              caloriesRemaining: wellnessService.caloriesRemaining.toDouble(),
            );

            final exerciseChart = ExerciseChart(
              exerciseBurned: wellnessService.exerciseBurned.toDouble(),
              caloriesRemaining: wellnessService.exerciseGoal.toDouble(),
            );

            if (isWideScreen) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      calorieChart,
                      const SizedBox(width: 70),
                      exerciseChart,
                    ],
                  ),
                ],
              );
            } else {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      calorieChart,
                      const SizedBox(height: 20),
                      exerciseChart,
                    ],
                  ),
                ],
              );
            }
          },
        );
      },
    );
  }
}

class CalorieChart extends StatelessWidget {
  final double caloriesConsumed;
  final double caloriesRemaining;

  const CalorieChart({
    super.key,
    required this.caloriesConsumed,
    required this.caloriesRemaining,
  });

  @override
  Widget build(BuildContext context) {
    return _buildDonutChart(
      title: 'Calories Eaten',
      primaryValue: caloriesConsumed,
      secondaryValue: caloriesRemaining,
    );
  }
}

class ExerciseChart extends StatelessWidget {
  final double exerciseBurned;
  final double caloriesRemaining;

  const ExerciseChart({
    super.key,
    required this.exerciseBurned,
    required this.caloriesRemaining,
  });

  @override
  Widget build(BuildContext context) {
    return _buildDonutChart(
      title: 'Calories Burned',
      primaryValue: exerciseBurned,
      secondaryValue: caloriesRemaining + exerciseBurned,
    );
  }
}

Widget _buildDonutChart({
  required String title,
  required double primaryValue,
  required double secondaryValue,
}) {
  final dataMap = <String, double>{
    "Completed": primaryValue,
    "Remaining": secondaryValue,
  };

  final colorList = <Color>[
    const Color.fromARGB(255, 180, 139, 24),
    const Color.fromARGB(255, 68, 120, 150),
  ];

  final chart = PieChart(
    dataMap: dataMap,
    animationDuration: const Duration(milliseconds: 800),
    chartLegendSpacing: 0,
    chartRadius: 160,
    colorList: colorList,
    initialAngleInDegree: 270,
    chartType: ChartType.ring,
    centerText: title,
    legendOptions: LegendOptions(
      showLegends: false,
    ),
    chartValuesOptions: ChartValuesOptions(
      showChartValueBackground: false,
      showChartValues: true,
      showChartValuesInPercentage: false,
      showChartValuesOutside: false,
      decimalPlaces: 0,
      chartValueStyle: const TextStyle(
        color: Colors.black,
        fontSize: 16,
      ),
    ),
  );

  return SizedBox(
    width: 200,
    height: 200,
    child: Stack(
      alignment: Alignment.center,
      children: [
        chart,
      ],
    ),
  );
}
