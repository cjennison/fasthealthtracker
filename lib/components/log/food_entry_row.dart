import 'package:fasthealthcheck/models/wellness.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

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

  String _generateFoodSubText(FoodEntry foodEntry) {
    List<FoodItem> foodItems =
        foodEntry.foodItemQuantities.map((item) => item.foodItem).toList();
    String foodListString = "";
    if (foodItems.isNotEmpty) {
      foodListString = foodItems.map((item) => item.name).join(", ");
      return "$foodListString (${foodEntry.quantity})";
    }
    return "${foodEntry.quantity} of ${foodEntry.name}";
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
            setState(() {
              isEditing = !isEditing;
            });
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
                    icon: Icon(Icons.edit, color: Colors.blue),
                    onPressed: () {},
                  ),
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
            );
          }).toList(),
      ],
    );
  }
}
