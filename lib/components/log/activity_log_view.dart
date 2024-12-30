import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:fasthealthcheck/services/wellness_service.dart';

class ActivityLogView extends StatelessWidget {
  const ActivityLogView({super.key});

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat.yMMMMd().format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Text("Activity Log for $formattedDate"),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 450;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Consumer<WellnessService>(
              builder: (context, wellnessService, child) {
                final foodEntries =
                    wellnessService.todayWellnessData.foodEntries;
                final exerciseEntries =
                    wellnessService.todayWellnessData.exerciseEntries;

                if (foodEntries.isEmpty && exerciseEntries.isEmpty) {
                  return const Center(
                    child: Text("No activity logged today."),
                  );
                }

                return ListView(
                  children: [
                    Row(
                      children: [
                        const Text("Activity Entries",
                            style: TextStyle(fontSize: 18)),
                        const Spacer(),
                        Text(
                          "Calories",
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                    ...foodEntries.asMap().entries.map((entry) {
                      final index = entry.key;
                      final foodEntry = entry.value;
                      return _buildLogEntry(
                        context,
                        isSmallScreen,
                        icon: Icons.restaurant,
                        iconColor: Colors.orange,
                        name: foodEntry.name,
                        subText: foodEntry.quantity,
                        calories: foodEntry.calories,
                        onDelete: () {
                          _showDeleteConfirmationDialog(context, () {
                            Provider.of<WellnessService>(context, listen: false)
                                .deleteFoodEntryByIndex(index);
                          });
                        },
                      );
                    }),
                    ...exerciseEntries.asMap().entries.map((entry) {
                      final index = entry.key;
                      final exerciseEntry = entry.value;
                      return _buildLogEntry(
                        context,
                        isSmallScreen,
                        icon: Icons.fitness_center,
                        iconColor: Colors.blue,
                        name: exerciseEntry.name,
                        subText:
                            "${exerciseEntry.type} (${exerciseEntry.intensity})",
                        calories: exerciseEntry.caloriesBurned,
                        onDelete: () {
                          _showDeleteConfirmationDialog(context, () {
                            Provider.of<WellnessService>(context, listen: false)
                                .deleteExerciseEntryByIndex(index);
                          });
                        },
                      );
                    }),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildLogEntry(BuildContext context, bool isSmallScreen,
      {required IconData icon,
      required Color iconColor,
      required String name,
      required String subText,
      required int calories,
      required VoidCallback onDelete}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 32),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: Theme.of(context).textTheme.bodyLarge,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subText,
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey),
                ),
              ],
            ),
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "$calories",
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: onDelete,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog(
      BuildContext context, VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Confirm Deletion"),
          content: const Text("Are you sure you want to delete this entry?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                onConfirm(); // Perform deletion
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }
}
