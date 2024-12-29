import 'package:flutter/material.dart';

class HomeButtonBar extends StatelessWidget {
  final VoidCallback onFoodTap;
  final VoidCallback onExerciseTap;
  final VoidCallback onWaterTap;

  const HomeButtonBar({
    super.key,
    required this.onFoodTap,
    required this.onExerciseTap,
    required this.onWaterTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      var isWideScreen = constraints.maxWidth > 350;

      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          isWideScreen
              ? ElevatedButton.icon(
                  onPressed: onFoodTap,
                  icon: const Icon(Icons.restaurant),
                  label: const Text('Food'),
                )
              : ElevatedButton(
                  onPressed: onFoodTap,
                  child: const Icon(Icons.restaurant),
                ),
          isWideScreen
              ? ElevatedButton.icon(
                  onPressed: onExerciseTap,
                  icon: const Icon(Icons.fitness_center),
                  label: const Text('Exercise'),
                )
              : ElevatedButton(
                  onPressed: onExerciseTap,
                  child: const Icon(Icons.fitness_center),
                ),
          isWideScreen
              ? ElevatedButton.icon(
                  onPressed: onWaterTap,
                  icon: const Icon(Icons.local_drink),
                  label: const Text('+ Water'),
                )
              : ElevatedButton(
                  onPressed: onWaterTap,
                  child: const Icon(Icons.local_drink),
                ),
        ],
      );
    });
  }
}
