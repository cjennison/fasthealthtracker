import 'package:fasthealthcheck/models/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:fasthealthcheck/services/wellness_service.dart';
import 'package:fasthealthcheck/services/user_service.dart';

class WellnessBars extends StatelessWidget {
  const WellnessBars({super.key});

  @override
  Widget build(BuildContext context) {
    UserService userService = Provider.of<UserService>(context);
    User currentUser = userService.currentUser!;

    return Consumer<WellnessService>(
      builder: (context, wellnessService, child) {
        final double caloriesConsumed =
            wellnessService.caloriesConsumed.toDouble();
        final double caloriesAvailable =
            currentUser.userProfile!.calorieGoal.toDouble();

        // If the calories consumed are greater than the target, set max to the target
        double maxCalories = caloriesConsumed > caloriesAvailable
            ? caloriesConsumed
            : caloriesAvailable;

        // If calories burned exceeds the exercise goal, set that max to the burned
        double maxCaloriesBurned = wellnessService.exerciseBurned.toDouble() >
                wellnessService.exerciseGoal.toDouble()
            ? wellnessService.exerciseBurned.toDouble()
            : wellnessService.exerciseGoal.toDouble();

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
              context: context,
              label: 'Calories eaten',
              value: caloriesConsumed,
              originalMaximum: caloriesAvailable,
              maxValue: maxCalories,
              color: Colors.orange,
              overflowColor: Colors.red,
            ),
            const SizedBox(height: 16),
            _buildStackedBar(
              context: context,
              label: 'Burned Calories through Exercise',
              value: wellnessService.exerciseBurned.toDouble(),
              originalMaximum: wellnessService.exerciseGoal.toDouble(),
              maxValue: maxCaloriesBurned,
              color: Colors.blue,
              overflowColor: Colors.green,
            ),
            _buildWaterIcons(context),
          ],
        );
      },
    );
  }

  Widget _buildStackedBar({
    required BuildContext context,
    required String label,
    required double value,
    required double originalMaximum,
    required double maxValue,
    required Color color,
    required Color overflowColor,
  }) {
    double mainBarValue = value < originalMaximum ? value : originalMaximum;
    // mainBarWidth is the width of the main bar never exceeding the original maximum.
    // If the value exceeds the original maximum, the main bar width is the width of the original maximum
    //  and the width is reduced by the ration difference between the originalMaximum and the maxValue
    double mainBarWidth =
        value < originalMaximum ? value / maxValue : originalMaximum / maxValue;
    double excessBarWidth =
        value > originalMaximum ? (value - originalMaximum) / maxValue : 0.0;

    return LayoutBuilder(builder: (context, constraints) {
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
                  widthFactor: mainBarWidth + excessBarWidth,
                  child: Row(
                    children: [
                      // Main Bar
                      Flexible(
                        flex: (mainBarWidth * 1000).toInt(),
                        child: Container(
                          height: 20,
                          decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.horizontal(
                              left: const Radius.circular(8),
                              right: excessBarWidth > 0
                                  ? Radius.zero
                                  : const Radius.circular(8),
                            ),
                          ),
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 4),
                          child: Text(
                            mainBarValue.toInt().toString(),
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      // Excess Bar (if it exists)
                      if (excessBarWidth > 0)
                        Flexible(
                          flex: (excessBarWidth * 1000).toInt(),
                          child: Container(
                            height: 20,
                            decoration: BoxDecoration(
                              color: overflowColor,
                              borderRadius: const BorderRadius.horizontal(
                                right: Radius.circular(8),
                              ),
                            ),
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 4),
                            child: Text(
                              value.toInt().toString(),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
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
                          if ((index < 4 && index > 0) &&
                              notchValue >
                                  (value +
                                      value *
                                          0.25)) // Random number I chose to prevent overlapping
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
    });
  }

  Widget _buildWaterIcons(BuildContext context) {
    return Consumer<WellnessService>(
      builder: (context, wellnessService, child) {
        int totalGlasses = wellnessService.glassesOfWater;
        int recommendedGlasses = WellnessService.recommendedGlassesOfWater;
        int overflowGlasses = totalGlasses - recommendedGlasses;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Glasses of Water',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  // Render the recommended glasses
                  ...List.generate(recommendedGlasses, (index) {
                    bool isFilled = index < totalGlasses;
                    return GestureDetector(
                      onTap: isFilled
                          ? () {
                              Provider.of<WellnessService>(context,
                                      listen: false)
                                  .setWater(index);
                            }
                          : () {
                              Provider.of<WellnessService>(context,
                                      listen: false)
                                  .setWater(index + 1);
                            },
                      child: CircleAvatar(
                        backgroundColor:
                            isFilled ? Colors.blue : Colors.grey[300],
                        child: Icon(
                          Icons.local_drink,
                          color: isFilled ? Colors.white : Colors.blue,
                        ),
                      ),
                    );
                  }),
                  // Render the overflow icon if there are extra glasses
                  if (overflowGlasses > 0)
                    GestureDetector(
                      onTap: () {
                        Provider.of<WellnessService>(context, listen: false)
                            .setWater(totalGlasses - 1);
                      },
                      child: CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Text(
                          '+$overflowGlasses',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
