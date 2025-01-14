import 'package:fasthealthcheck/components/log/food_entry_row.dart';
import 'package:fasthealthcheck/models/wellness.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:fasthealthcheck/services/wellness_service.dart';

class ActivityLogView extends StatelessWidget {
  const ActivityLogView({super.key});

  @override
  Widget build(BuildContext context) {
    WellnessService wellnessService = Provider.of<WellnessService>(context);

    String formattedDate =
        DateFormat.yMMMMd().format(wellnessService.selectedDate);

    String generateExerciseSubText(ExerciseEntry exerciseEntry) {
      return "${exerciseEntry.type} (${exerciseEntry.intensity}, ${exerciseEntry.duration} min)";
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Activity Log for $formattedDate"),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 450;
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 800),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Consumer<WellnessService>(
                  builder: (context, wellnessService, child) {
                    final foodEntries =
                        wellnessService.currentDateWellnessData.foodEntries;
                    final exerciseEntries =
                        wellnessService.currentDateWellnessData.exerciseEntries;

                    if (foodEntries.isEmpty && exerciseEntries.isEmpty) {
                      return Center(
                        child: Text("No activity logged for $formattedDate."),
                      );
                    }

                    return Center(
                      child: ListView(
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
                            // Horizontal ruler
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  height: 1,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          ...foodEntries.asMap().entries.map((
                            entry,
                          ) {
                            final index = entry.key;
                            final foodEntry = entry.value;
                            return FoodEntryWithItems(
                              context: context,
                              foodEntry: foodEntry,
                              index: index,
                              isSmallScreen: isSmallScreen,
                              buildLogEntry: _buildLogEntry,
                              showDeleteConfirmationDialog:
                                  _showDeleteConfirmationDialog,
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
                              subText: generateExerciseSubText(exerciseEntry),
                              calories: exerciseEntry.caloriesBurned,
                              type: 'exercise',
                              onEdit: () {},
                              onDelete: () {
                                _showDeleteConfirmationDialog(context, () {
                                  Provider.of<WellnessService>(context,
                                          listen: false)
                                      .deleteExerciseEntryByIndex(index);
                                });
                              },
                            );
                          }),
                        ],
                      ),
                    );
                  },
                ),
              ),
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
      required String type,
      required VoidCallback onEdit,
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
              if (type == "food")
                IconButton(
                    icon: const Icon(Icons.edit, color: Colors.grey),
                    onPressed: onEdit),
              if (type == "exercise") SizedBox(width: 40),
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
