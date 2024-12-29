import 'package:fasthealthcheck/services/local_storage_service.dart';
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
  int _glassesOfWater = 0;

  static const int recommendedGlassesOfWater = 8;

  final List<FoodEntry> foodEntries = [];
  final List<ExerciseEntry> exerciseEntries = [];

  int get exerciseGoal => 1000;
  int get glassesOfWater => _glassesOfWater;

  int get caloriesConsumed =>
      foodEntries.fold(0, (sum, entry) => sum + entry.calories);

  int get exerciseBurned =>
      exerciseEntries.fold(0, (sum, entry) => sum + entry.caloriesBurned);

  int get caloriesRemaining {
    final consumed = caloriesConsumed;
    final burned = exerciseBurned;
    return 2000 - consumed + burned;
  }

  /// dayWellnessData is a map with the following structure:
  /// {
  ///  foodEntries: List<Map<String, dynamic>>,
  ///  exerciseEntries: List<Map<String, dynamic>>,
  ///  _glassesOfWater: int,
  /// }

  Future<void> initializeWellnessData() async {
    _glassesOfWater = 0;
    foodEntries.clear();
    exerciseEntries.clear();

    final dayWellnessData = await LocalStorageService().fetchWellnessData();
    if (dayWellnessData != null) {
      _glassesOfWater = dayWellnessData['glassesOfWater'];
      for (final foodEntry in dayWellnessData['foodEntries']) {
        foodEntries.add(FoodEntry(
          name: foodEntry['name'],
          quantity: foodEntry['quantity'],
          calories: foodEntry['calories'],
        ));
      }
      for (final exerciseEntry in dayWellnessData['exerciseEntries']) {
        exerciseEntries.add(ExerciseEntry(
          name: exerciseEntry['name'],
          type: exerciseEntry['type'],
          intensity: exerciseEntry['intensity'],
          caloriesBurned: exerciseEntry['caloriesBurned'],
        ));
      }
    }

    print(
        "initialized data: glasses:$_glassesOfWater, $foodEntries, $exerciseEntries");
    notifyListeners();
  }

  Future<void> saveWellnessData() async {
    final dayWellnessData = {
      'foodEntries': foodEntries
          .map((entry) => {
                'name': entry.name,
                'quantity': entry.quantity,
                'calories': entry.calories,
              })
          .toList(),
      'exerciseEntries': exerciseEntries
          .map((entry) => {
                'name': entry.name,
                'type': entry.type,
                'intensity': entry.intensity,
                'caloriesBurned': entry.caloriesBurned,
              })
          .toList(),
      'glassesOfWater': _glassesOfWater,
    };

    LocalStorageService().saveWellnessData(dayWellnessData);
  }

  void addCalories(String foodName, String quantity, int calories) {
    foodEntries
        .add(FoodEntry(name: foodName, quantity: quantity, calories: calories));
    saveWellnessData();
    notifyListeners();
  }

  void addWater() {
    _glassesOfWater++;
    saveWellnessData();
    notifyListeners();
  }

  void removeWater() {
    _glassesOfWater--;
    saveWellnessData();
    notifyListeners();
  }

  void deleteFoodEntryByIndex(int index) {
    foodEntries.removeAt(index);
    saveWellnessData();
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
    saveWellnessData();
    notifyListeners();
  }

  void deleteExerciseEntryByIndex(int index) {
    exerciseEntries.removeAt(index);
    saveWellnessData();
    notifyListeners();
  }
}
