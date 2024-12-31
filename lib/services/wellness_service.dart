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

class DateWellnessData {
  final List<FoodEntry> foodEntries;
  final List<ExerciseEntry> exerciseEntries;
  int glassesOfWater;
  final DateTime date;

  DateWellnessData({
    required this.foodEntries,
    required this.exerciseEntries,
    required this.glassesOfWater,
    required this.date,
  });

  Map<String, dynamic> toJson() {
    return {
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
      'glassesOfWater': glassesOfWater,
      'date': DateTime(date.year, date.month, date.day).toString(),
    };
  }
}

class WellnessService extends ChangeNotifier {
  final Map<String, DateWellnessData> _wellnessData = {};
  final DateTime today = DateTime.now();
  final DateTime formattedToday =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  static const int recommendedGlassesOfWater = 8;

  String get currentDate => formattedToday.toString();

  DateWellnessData get todayWellnessData {
    final dayWellnessData = _wellnessData[currentDate];
    if (dayWellnessData == null) {
      getOrCreateDateWellnessData(today);
      return _wellnessData[currentDate]!;
    }
    return dayWellnessData;
  }

  int get exerciseGoal => 1000;

  // Each getting gets the values below for the current date in the wellnessData map
  int get glassesOfWater => () {
        final dayWellnessData = _wellnessData[currentDate];
        return dayWellnessData?.glassesOfWater ?? 0;
      }();

  int get caloriesConsumed => () {
        final dayWellnessData = _wellnessData[currentDate];
        if (dayWellnessData != null) {
          return dayWellnessData.foodEntries
              .fold(0, (sum, entry) => sum + entry.calories);
        }
        return 0;
      }();

  int get exerciseBurned => () {
        final dayWellnessData = _wellnessData[currentDate];
        if (dayWellnessData != null) {
          return dayWellnessData.exerciseEntries
              .fold(0, (sum, entry) => sum + entry.caloriesBurned);
        }
        return 0;
      }();

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
    final dateRangeWellnessData =
        await LocalStorageService().fetchWellnessData();
    if (dateRangeWellnessData != null) {
      // dateRangeWellnessData is a map with the following structure:
      // {
      //   'yyyy-mm-dd': dayWellnessData,
      //   'yyyy-mm-dd': dayWellnessData,
      //}

      dateRangeWellnessData.forEach((key, value) {
        final dayWellnessData = DateWellnessData(
          foodEntries: value['foodEntries']
              .map<FoodEntry>((entry) => FoodEntry(
                    name: entry['name'],
                    quantity: entry['quantity'],
                    calories: entry['calories'],
                  ))
              .toList(),
          exerciseEntries: value['exerciseEntries']
              .map<ExerciseEntry>((entry) => ExerciseEntry(
                    name: entry['name'],
                    type: entry['type'],
                    intensity: entry['intensity'],
                    caloriesBurned: entry['caloriesBurned'],
                  ))
              .toList(),
          glassesOfWater: value['glassesOfWater'],
          date: DateTime.parse(key),
        );

        _wellnessData[key] = dayWellnessData;
      });
    } else {
      _wellnessData[formattedToday.toString()] = DateWellnessData(
        foodEntries: [],
        exerciseEntries: [],
        glassesOfWater: 0,
        date: formattedToday,
      );
    }

    notifyListeners();
  }

  void getOrCreateDateWellnessData(DateTime date) {
    final formattedDate = DateTime(date.year, date.month, date.day);
    if (!_wellnessData.containsKey(formattedDate.toString())) {
      _wellnessData[formattedDate.toString()] = DateWellnessData(
        foodEntries: [],
        exerciseEntries: [],
        glassesOfWater: 0,
        date: formattedDate,
      );
    }
  }

  Future<void> saveWellnessData() async {
    // Save all of the _wellnessData map to local storage
    final dateRangeWellnessData = _wellnessData.map((key, value) {
      return MapEntry(key, value.toJson());
    });

    await LocalStorageService().saveWellnessData(dateRangeWellnessData);
  }

  void addCalories(String foodName, String quantity, int calories) {
    todayWellnessData.foodEntries
        .add(FoodEntry(name: foodName, quantity: quantity, calories: calories));
    saveWellnessData();
    notifyListeners();
  }

  void addWater() {
    todayWellnessData.glassesOfWater++;
    saveWellnessData();
    notifyListeners();
  }

  void removeWater() {
    todayWellnessData.glassesOfWater++;
    saveWellnessData();
    notifyListeners();
  }

  void deleteFoodEntryByIndex(int index) {
    todayWellnessData.foodEntries.removeAt(index);
    saveWellnessData();
    notifyListeners();
  }

  void logExercise(
      String name, String type, String intensity, int caloriesBurned) {
    todayWellnessData.exerciseEntries.add(ExerciseEntry(
      name: name,
      type: type,
      intensity: intensity,
      caloriesBurned: caloriesBurned,
    ));
    saveWellnessData();
    notifyListeners();
  }

  void deleteExerciseEntryByIndex(int index) {
    todayWellnessData.exerciseEntries.removeAt(index);
    saveWellnessData();
    notifyListeners();
  }

  void clearWellnessData() {
    todayWellnessData.glassesOfWater = 0;
    todayWellnessData.foodEntries.clear();
    todayWellnessData.exerciseEntries.clear();
    notifyListeners();
  }
}
