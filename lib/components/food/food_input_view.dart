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

  bool isProcessing = false;

  Future<void> handleAdd() async {
    setState(() {
      isProcessing = true;
    });
    try {
      await Provider.of<WellnessService>(context, listen: false).addCalories(
          foodController.text, selectedQuantity, 300); // Mocked value
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
      body: Padding(
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
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: handleAdd,
              child: isProcessing
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        value: null,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      "Add Food",
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
