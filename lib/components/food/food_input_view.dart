import 'package:fasthealthcheck/models/wellness.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:fasthealthcheck/services/wellness_service.dart';

class FoodInputView extends StatefulWidget {
  const FoodInputView({super.key});

  @override
  State<FoodInputView> createState() => _FoodInputViewState();
}

class _FoodInputViewState extends State<FoodInputView> {
  final TextEditingController foodController = TextEditingController();
  String selectedQuantity = "some";

  bool showCaloriesInput = false;
  int calories = 300; // Mocked value

  bool isProcessing = false;

  Future<void> handleAdd() async {
    setState(() {
      isProcessing = true;
    });
    try {
      FoodEntry newEntry =
          await Provider.of<WellnessService>(context, listen: false)
              .addCalories(foodController.text, selectedQuantity,
                  showCaloriesInput ? calories : null); // Mocked value

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Added ${newEntry.name} with calories: ${newEntry.calories} to food log"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      print(e);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to add food. Please try again."),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Food"),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: foodController,
                  decoration: const InputDecoration(
                    labelText: "Enter food",
                  ),
                ),
                DropdownButton<String>(
                  value: selectedQuantity,
                  items: const [
                    DropdownMenuItem(value: "some", child: Text("Some")),
                    DropdownMenuItem(value: "half", child: Text("Half")),
                    DropdownMenuItem(
                        value: "full", child: Text("Enough to be full")),
                    DropdownMenuItem(value: "extra", child: Text("A lot")),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedQuantity = value!;
                    });
                  },
                ),
                // Calories Slider
                if (!showCaloriesInput)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showCaloriesInput = true;
                      });
                    },
                    child: const Text("Set Calories Myself"),
                  ),
                if (showCaloriesInput)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Set Calories Burned",
                          style: TextStyle(fontSize: 18)),
                      Row(
                        children: [
                          Text(calories.toString(),
                              style: TextStyle(fontSize: 18)),
                          Slider(
                            value: calories.toDouble(),
                            min: 0,
                            max: 2000,
                            divisions: 50,
                            label: "$calories",
                            onChanged: (value) {
                              setState(() {
                                calories = value.toInt();
                              });
                            },
                          ),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                showCaloriesInput = false;
                                calories = 300; // Reset to mocked value
                              });
                            },
                            child: const Text("Cancel"),
                          ),
                        ],
                      ),
                    ],
                  ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: handleAdd,
                  child: isProcessing
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            value: null,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          "Add Food",
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
