import 'dart:convert';

import 'package:fasthealthcheck/constants/error_codes.dart';
import 'package:fasthealthcheck/models/wellness.dart';
import 'package:fasthealthcheck/services/api/classes/api_exception.dart';
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

  String exerciseType = "cardio";
  String exerciseIntensity = "moderate";
  bool showCaloriesSlider = false;
  double caloriesBurned = 100; // Default calories for slider
  int durationMinutes = 5; // Default duration
  bool isProcessing = false;

  // Error states
  bool hasContentModerationError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Exercise"),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Step 1: Select Exercise Type
                    const Text("Exercise Type", style: TextStyle(fontSize: 18)),
                    DropdownButton<String>(
                      value: exerciseType,
                      items: const [
                        DropdownMenuItem(
                            value: "cardio", child: Text("Cardio")),
                        DropdownMenuItem(
                            value: "strength", child: Text("Strength")),
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
                      decoration: InputDecoration(
                        labelText: "What kind of exercise did you do?",
                        errorText: hasContentModerationError
                            ? errorMessages[ErrorCodes.contentModeration]
                                .userFriendlyMessage
                            : null,
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
                        DropdownMenuItem(value: "easy", child: Text("Easy")),
                        DropdownMenuItem(
                            value: "moderate", child: Text("Moderate")),
                        DropdownMenuItem(value: "hard", child: Text("Hard")),
                      ],
                      onChanged: (value) {
                        setState(() {
                          exerciseIntensity = value!;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // Step 4: Select Duration
                    const Text("Duration (minutes)",
                        style: TextStyle(fontSize: 18)),
                    DropdownButton<int>(
                      value: durationMinutes,
                      items: List.generate(
                        120, // Up to 600 minutes in 5-minute intervals
                        (index) => DropdownMenuItem(
                          value: (index + 1) * 5,
                          child: Text("${(index + 1) * 5} minutes"),
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {
                          durationMinutes = value!;
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
                            ],
                          ),
                        ],
                      ),

                    // Step 5: Submit Button for Normal Flow
                    ElevatedButton(
                      onPressed: () {
                        int? calculatedCalories;
                        if (showCaloriesSlider) {
                          calculatedCalories = caloriesBurned.toInt();
                        }
                        if (_formKey.currentState!.validate()) {
                          _submitExercise(context, calculatedCalories);
                        }
                      },
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
                              "Submit Exercise",
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitExercise(BuildContext context, int? calories) async {
    setState(() {
      isProcessing = true;
      hasContentModerationError = false;
    });
    final exerciseName = exerciseController.text.isEmpty
        ? exerciseType
        : exerciseController.text;

    try {
      ExerciseEntry newEntry =
          await Provider.of<WellnessService>(context, listen: false)
              .logExercise(
        exerciseName,
        exerciseType,
        exerciseIntensity,
        durationMinutes,
        calories, // can be null if showCaloriesSlider is false
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              "Added ${newEntry.name} with calories: ${newEntry.caloriesBurned} to exercise log"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (err) {
      if (err is ApiException) {
        if (err.errorCode == ErrorCodes.contentModeration) {
          setState(() {
            hasContentModerationError = true;
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to add exercise: ${err.message}"),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Failed to add exercise. Please try again."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }
}
