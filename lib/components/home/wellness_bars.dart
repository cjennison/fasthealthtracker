import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:fasthealthcheck/services/wellness_service.dart';

class WellnessBars extends StatelessWidget {
  const WellnessBars({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WellnessService>(
      builder: (context, wellnessService, child) {
        final double caloriesConsumed =
            wellnessService.caloriesConsumed.toDouble();
        final double caloriesAvailable = 2000.0; // Example target

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Wellness Overview',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            _buildStackedBar(
              label: 'Calories eaten',
              value: caloriesConsumed,
              maxValue: caloriesAvailable,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            _buildStackedBar(
              label: 'Burned Calories through Exercise',
              value: wellnessService.exerciseBurned.toDouble(),
              maxValue: wellnessService.exerciseGoal.toDouble(),
              color: Colors.blue,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStackedBar({
    required String label,
    required double value,
    required double maxValue,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              FractionallySizedBox(
                widthFactor: value / maxValue,
                child: Stack(
                  children: [
                    Container(
                      height: 20,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    Positioned(
                      right: 4,
                      top: 0,
                      child: Text(
                        value.toInt().toString(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned.fill(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(5, (index) {
                    final double notchValue = maxValue * (index / 4);
                    return Column(
                      children: [
                        const SizedBox(height: 2),
                        if ((index < 4 && index > 0) && notchValue > value)
                          Text(
                            notchValue.toInt().toString(),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[900],
                            ),
                          ),
                      ],
                    );
                  }),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '0',
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
              Text(
                maxValue.toInt().toString(),
                style: const TextStyle(
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}