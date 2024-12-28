import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:fasthealthcheck/services/wellness_service.dart';

class ExerciseInputView extends StatefulWidget {
  const ExerciseInputView({super.key});

  @override
  State<ExerciseInputView> createState() => _ExerciseInputViewState();
}

class _ExerciseInputViewState extends State<ExerciseInputView> {
  final TextEditingController exerciseController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String exerciseType = "Cardio";
  String exerciseIntensity = "Normal";
  bool showCaloriesSlider = false;
  double caloriesBurned = 100; // Default calories for slider

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Exercise"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Step 1: Select Exercise Type
              const Text("Exercise Type", style: TextStyle(fontSize: 18)),
              DropdownButton<String>(
                value: exerciseType,
                items: const [
                  DropdownMenuItem(value: "Cardio", child: Text("Cardio")),
                  DropdownMenuItem(value: "Strength", child: Text("Strength")),
                ],
                onChanged: (value) {
                  setState(() {
                    exerciseType = value!;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Step 2: Input Exercise Name
              const Text("Exercise Name", style: TextStyle(fontSize: 18)),
              TextFormField(
                controller: exerciseController,
                decoration: const InputDecoration(
                  labelText: "What kind of exercise did you do?",
                ),
                validator: (value) =>
                    value!.isEmpty ? "Please enter a name" : null,
              ),
              const SizedBox(height: 20),

              // Step 3: Select Exercise Intensity
              const Text("Intensity", style: TextStyle(fontSize: 18)),
              DropdownButton<String>(
                value: exerciseIntensity,
                items: const [
                  DropdownMenuItem(value: "Easy", child: Text("Easy")),
                  DropdownMenuItem(value: "Normal", child: Text("Normal")),
                  DropdownMenuItem(value: "Hard", child: Text("Hard")),
                ],
                onChanged: (value) {
                  setState(() {
                    exerciseIntensity = value!;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Optional: Set Calories Burned Myself
              if (!showCaloriesSlider)
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showCaloriesSlider = true;
                    });
                  },
                  child: const Text("Set Calories Burned Myself"),
                ),

              // Calories Slider
              if (showCaloriesSlider)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Set Calories Burned",
                        style: TextStyle(fontSize: 18)),
                    Slider(
                      value: caloriesBurned,
                      min: 0,
                      max: 1000,
                      divisions: 100,
                      label: "${caloriesBurned.toInt()}",
                      onChanged: (value) {
                        setState(() {
                          caloriesBurned = value;
                        });
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              showCaloriesSlider = false;
                            });
                          },
                          child: const Text("Cancel"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              _submitExercise(context, caloriesBurned.toInt());
                            }
                          },
                          child: const Text("Submit"),
                        ),
                      ],
                    ),
                  ],
                ),

              // Step 4: Submit Button for Normal Flow
              if (!showCaloriesSlider)
                ElevatedButton(
                  onPressed: () {
                    int calculatedCalories = _calculateCalories();
                    if (_formKey.currentState!.validate()) {
                      _submitExercise(context, calculatedCalories.toInt());
                    }
                  },
                  child: const Text("Submit Exercise"),
                ),
            ],
          ),
        ),
      ),
    );
  }

  int _calculateCalories() {
    // Mocked calorie calculation based on intensity and type
    int baseCalories = exerciseType == "Cardio" ? 150 : 100;
    if (exerciseIntensity == "Easy") {
      return baseCalories;
    } else if (exerciseIntensity == "Normal") {
      return baseCalories + 50;
    } else {
      return baseCalories + 100;
    }
  }

  void _submitExercise(BuildContext context, int calories) {
    final exerciseName = exerciseController.text.isEmpty
        ? exerciseType
        : exerciseController.text;

    Provider.of<WellnessService>(context, listen: false)
        .logExercise(exerciseName, exerciseType, exerciseIntensity, calories);

    Navigator.pop(context);
  }
}
