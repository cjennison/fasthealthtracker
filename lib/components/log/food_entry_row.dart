import 'package:fasthealthcheck/constants/quantities.dart';
import 'package:fasthealthcheck/models/wellness.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:fasthealthcheck/services/wellness_service.dart';

class FoodEntryWithItems extends StatefulWidget {
  final BuildContext context;
  final FoodEntry foodEntry;
  final int index;
  final bool isSmallScreen;
  final Widget Function(BuildContext, bool,
      {required IconData icon,
      required Color iconColor,
      required String name,
      required String subText,
      required int calories,
      required String type,
      required VoidCallback onEdit,
      required VoidCallback onDelete}) buildLogEntry;
  final void Function(BuildContext context, VoidCallback onConfirm)
      showDeleteConfirmationDialog;

  const FoodEntryWithItems({
    required this.context,
    required this.foodEntry,
    required this.index,
    required this.isSmallScreen,
    required this.buildLogEntry,
    required this.showDeleteConfirmationDialog,
    super.key,
  });

  @override
  State<FoodEntryWithItems> createState() => _FoodEntryWithItemsState();
}

class _FoodEntryWithItemsState extends State<FoodEntryWithItems> {
  bool isEditing = false;
  bool updateFailed = false;

  String _generateFoodSubText(FoodEntry foodEntry) {
    String foodListString = "";
    if (foodEntry.foodItemQuantities.isNotEmpty) {
      foodListString = foodEntry.foodItemQuantities
          .map((item) => "${item.foodItem.name} (${item.quantity})")
          .join(", ");
      return foodListString;
    }
    return "${foodEntry.quantity} of ${foodEntry.name}";
  }

  Future<void> _updateFoodItemQuantity(BuildContext context,
      FoodItemQuantity foodItemQuantity, String newQuantity) async {
    WellnessService wellnessService =
        Provider.of<WellnessService>(context, listen: false);
    DateWellnessData currentDateWellnessData =
        wellnessService.currentDateWellnessData;
    try {
      await Provider.of<WellnessService>(context, listen: false)
          .updateFoodItemQuantity(
              currentDateWellnessData.id,
              widget.foodEntry.id,
              foodItemQuantity.foodItem.id,
              newQuantity,
              widget.index);

      Navigator.of(context).pop(null);
    } catch (e) {
      print("Error updating food item quantity: $e");
      setState(() {
        updateFailed = true;
      });
      rethrow;
    }
  }

  Future<void> _updateFoodEntryCalories(
      BuildContext context, int newCalories) async {
    WellnessService wellnessService =
        Provider.of<WellnessService>(context, listen: false);
    DateWellnessData currentDateWellnessData =
        wellnessService.currentDateWellnessData;
    try {
      await Provider.of<WellnessService>(context, listen: false)
          .updateFoodEntry(currentDateWellnessData.id, widget.foodEntry.id,
              newCalories.toInt(), widget.index);

      Navigator.of(context).pop(null);
    } catch (e) {
      print("Error updating food item calories: $e");
      setState(() {
        updateFailed = true;
      });
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    WellnessService wellnessService = Provider.of<WellnessService>(context);
    DateWellnessData currentDateWellnessData =
        wellnessService.currentDateWellnessData;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.buildLogEntry(
          context,
          widget.isSmallScreen,
          icon: Icons.restaurant,
          iconColor: Colors.orange,
          name: widget.foodEntry.name,
          subText: _generateFoodSubText(widget.foodEntry),
          calories: widget.foodEntry.calories,
          type: 'food',
          onEdit: () {
            // If the food entry has quantities, then set the boolean to isEditing
            if (widget.foodEntry.foodItemQuantities.isNotEmpty) {
              setState(() {
                isEditing = !isEditing;
              });
              return;
            } else {
              // Otherwise, open the calorie modal
              _openEditCaloriesModal(context, widget.foodEntry);
            }
          },
          onDelete: () {
            widget.showDeleteConfirmationDialog(context, () {
              Provider.of<WellnessService>(context, listen: false)
                  .deleteFoodEntryByIndex(widget.index);
            });
          },
        ),
        if (isEditing && widget.foodEntry.foodItemQuantities.isNotEmpty)
          ...widget.foodEntry.foodItemQuantities.map((foodItemQuantity) {
            return ListTile(
              title: Text(foodItemQuantity.foodItem.name),
              subtitle: Text("Quantity: ${foodItemQuantity.quantity}"),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      widget.showDeleteConfirmationDialog(context, () {
                        Provider.of<WellnessService>(context, listen: false)
                            .deleteFoodItemQuantity(
                          currentDateWellnessData.id,
                          widget.foodEntry.id,
                          foodItemQuantity.foodItem.id,
                          widget.index,
                        );
                      });
                    },
                  ),
                ],
              ),
              onTap: () => _openEditQuantityModal(context, foodItemQuantity),
            );
          }).toList(),
      ],
    );
  }

  void _openEditCaloriesModal(BuildContext context, FoodEntry foodEntry) async {
    int currentCalories = foodEntry.calories;

    await showModalBottomSheet<int>(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, StateSetter setState) {
          return SizedBox(
            height:
                MediaQuery.of(context).size.height * 0.5, // Half-screen height
            child: Padding(
              padding: EdgeInsets.only(
                top: 16,
                left: 16,
                right: 16,
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Edit Calories for ${foodEntry.name}",
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text("Calories:"),
                      SizedBox(width: 16),
                      Text(
                        "$currentCalories",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  Slider(
                    value: currentCalories.toDouble(),
                    min: 0,
                    max: 2000,
                    divisions: 200,
                    label: "$currentCalories",
                    onChanged: (double value) {
                      setState(() {
                        currentCalories = value.toInt();
                      });
                    },
                  ),
                  const Spacer(),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(null); // Cancel
                        },
                        child: const Text("Cancel"),
                      ),
                      ElevatedButton(
                          onPressed: () {
                            _updateFoodEntryCalories(context, currentCalories);
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue),
                          child: Text(
                            'Save',
                            style: TextStyle(color: Colors.white),
                          )),
                    ],
                  ),
                ],
              ),
            ),
          );
        });
      },
    );
  }

  void _openEditQuantityModal(
      BuildContext context, FoodItemQuantity foodItemQuantity) {
    String selectedQuantity = foodItemQuantity.quantity;

    setState(() {
      updateFailed = false;
    });

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.33,
          child: Padding(
            padding: EdgeInsets.only(
              top: 16,
              left: 16,
              right: 16,
              bottom: MediaQuery.of(context).viewInsets.bottom +
                  16, // Adjust for keyboard
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Edit Quantity for ${foodItemQuantity.foodItem.name}",
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedQuantity,
                  decoration: InputDecoration(
                    labelText: 'Quantity',
                    errorText:
                        updateFailed ? 'Failed to update quantity' : null,
                    border: const OutlineInputBorder(),
                  ),
                  items: Quantities.map((String quantity) {
                    return DropdownMenuItem<String>(
                      value: quantity,
                      child: Text(getQuantitiesDisplayName(quantity)),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    selectedQuantity = newValue ?? selectedQuantity;
                  },
                ),
                const Spacer(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () => Navigator.of(context).pop(null),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                        onPressed: () {
                          _updateFoodItemQuantity(
                              context, foodItemQuantity, selectedQuantity);
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue),
                        child: Text(
                          'Save',
                          style: TextStyle(color: Colors.white),
                        )),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
