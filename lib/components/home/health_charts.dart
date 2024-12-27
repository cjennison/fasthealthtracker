import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pie_chart/pie_chart.dart';

enum LegendShape { circle, rectangle }

class HealthCharts extends StatelessWidget {
  final double caloriesConsumed;
  final double caloriesRemaining;
  final double exerciseBurned;

  const HealthCharts({
    super.key,
    required this.caloriesConsumed,
    required this.caloriesRemaining,
    required this.exerciseBurned,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final screenWidth = constraints.maxWidth;
      final isWideScreen = screenWidth > 480;

      var chart1 = _buildDonutChart(
        context,
        title: 'Calories',
        primaryValue: caloriesConsumed,
        secondaryValue: caloriesRemaining,
      );
      var chart2 = _buildDonutChart(
        context,
        title: 'Exercise',
        primaryValue: exerciseBurned,
        secondaryValue: caloriesRemaining + exerciseBurned,
      );

      if (isWideScreen) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Center charts horizontally
              children: [
                chart1,
                const SizedBox(width: 70), // Add spacing between charts
                chart2,
              ],
            ),
          ],
        );
      } else {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment:
                  MainAxisAlignment.center, // Center charts vertically
              children: [
                chart1,
                const SizedBox(height: 20), // Add spacing between charts
                chart2,
              ],
            ),
          ],
        );
      }
    });
  }

  Widget _buildDonutChart(
    BuildContext context, {
    required String title,
    required double primaryValue,
    required double secondaryValue,
  }) {
    final dataMap = <String, double>{
      "Ready": secondaryValue,
      "Remaining": primaryValue,
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
}
