import 'package:flutter/material.dart';

class FoodEntry {
  final String name;
  final String quantity;
  final int calories;

  FoodEntry({
    required this.name,
    required this.quantity,
    required this.calories,
  });
}

class ExerciseEntry {
  final String name;
  final String type;
  final String intensity;
  final int caloriesBurned;

  ExerciseEntry({
    required this.name,
    required this.type,
    required this.intensity,
    required this.caloriesBurned,
  });
}

class WellnessService extends ChangeNotifier {
  int _caloriesConsumed = 0;
  int _exerciseBurned = 0;
  int _dailyGlassesOfWater = 0;

  static const int recommendedGlassesOfWater = 8;

  final List<FoodEntry> foodEntries = [];
  final List<ExerciseEntry> exerciseEntries = [];

  int get caloriesConsumed => _caloriesConsumed;
  int get exerciseBurned => _exerciseBurned;
  int get exerciseGoal => 1000;
  int get caloriesRemaining => 2000 - _caloriesConsumed + _exerciseBurned;
  int get glassesOfWater => _dailyGlassesOfWater;

  void addCalories(String foodName, String quantity, int calories) {
    _caloriesConsumed += calories;
    foodEntries
        .add(FoodEntry(name: foodName, quantity: quantity, calories: calories));
    notifyListeners();
  }

  void _burnCalories(int calories) {
    _exerciseBurned += calories;
    notifyListeners();
  }

  void addWater() {
    _dailyGlassesOfWater++;
    notifyListeners();
  }

  void removeWater() {
    _dailyGlassesOfWater--;
    notifyListeners();
  }

  void resetForToday() {
    _caloriesConsumed = 0;
    _exerciseBurned = 0;
    notifyListeners();
  }

  void deleteFoodEntryByIndex(int index) {
    final foodEntry = foodEntries[index];
    _caloriesConsumed -= foodEntry.calories;
    foodEntries.removeAt(index);
    notifyListeners();
  }

  void logExercise(
      String name, String type, String intensity, int caloriesBurned) {
    exerciseEntries.add(ExerciseEntry(
      name: name,
      type: type,
      intensity: intensity,
      caloriesBurned: caloriesBurned,
    ));
    _burnCalories(caloriesBurned);
    notifyListeners();
  }

  void deleteExerciseEntryByIndex(int index) {
    final exerciseEntry = exerciseEntries[index];
    _exerciseBurned -= exerciseEntry.caloriesBurned;
    exerciseEntries.removeAt(index);
    notifyListeners();
  }
}
