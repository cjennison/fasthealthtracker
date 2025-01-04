import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import 'package:fasthealthcheck/models/user.dart';
import 'package:fasthealthcheck/models/wellness.dart';

import 'package:fasthealthcheck/services/api/api_wellness_service.dart';
import 'package:fasthealthcheck/services/user_service.dart';

String formatToDateOnly(DateTime dateTime) {
  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  return formatter.format(dateTime);
}

class WellnessService extends ChangeNotifier {
  final Map<String, DateWellnessData> _wellnessData = {};
  final DateTime today = DateTime.now();
  final DateTime formattedToday =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  int streak = 0;

  static const int recommendedGlassesOfWater = 8;

  String get currentDate => formatToDateOnly(formattedToday);

  DateWellnessData get todayWellnessData {
    final dayWellnessData = _wellnessData[currentDate];
    if (dayWellnessData == null) {
      getOrCreateDateWellnessData(formattedToday);
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

  int get currentStreak => streak;

  /// dayWellnessData is a map with the following structure:
  /// {
  ///  foodEntries: List<Map<String, dynamic>>,
  ///  exerciseEntries: List<Map<String, dynamic>>,
  ///  _glassesOfWater: int,
  /// }

  Future<void> initializeWellnessData() async {
    print("Initializing wellness data for $formattedToday");
    await getOrCreateDateWellnessData(formattedToday);

    final streakData = await ApiWellnessService()
        .getWellnessStreak(UserService().currentUser!.id);
    streak = streakData['streak'];

    notifyListeners();
  }

  Future<DateWellnessData> getOrCreateDateWellnessData(DateTime date) async {
    final String formattedDate = formatToDateOnly(date);
    User user = UserService().currentUser!;
    try {
      final wellnessDataJson = await ApiWellnessService()
          .getWellnessDataByDate(user.id, formattedDate);

      DateWellnessData wellnessData =
          DateWellnessData.getWellnessDataFromJson(wellnessDataJson);

      _wellnessData[formattedDate] = wellnessData;
      return wellnessData;
    } catch (e) {
      // Create a new DateWellnessData object for the date
      final newWellnessData = await ApiWellnessService()
          .createWellnessData(UserService().currentUser!.id, formattedDate, 0);

      final wellnessData =
          DateWellnessData.getWellnessDataFromJson(newWellnessData);
      _wellnessData[formattedDate] = wellnessData;

      return wellnessData;
    }
  }

  Future<void> updateWellnessData(DateWellnessData wellnessData) async {
    try {
      await ApiWellnessService().updateWellnessData(wellnessData.id, {
        'glassesOfWater': wellnessData.glassesOfWater,
      });
    } catch (e) {
      print("Error updating wellness data: $e");
    }
  }

  // Modifiers
  //  NOTE: These current modify the object by its reference in the map
  //    Eventually the object should be provided by the function and then updated and replaced in the map

  Future<void> addCalories(
      String foodName, String quantity, int calories) async {
    final payload = {
      "name": foodName,
      "quantity": quantity,
      "calories": calories,
    };

    try {
      final data = await ApiWellnessService()
          .addFoodEntry(todayWellnessData.id, payload);
      FoodEntry foodEntry = FoodEntry.getFoodEntryFromJson(data);

      todayWellnessData.foodEntries.add(foodEntry);
    } catch (e) {
      print("Error adding food entry: $e");
    }

    notifyListeners();
  }

  void addWater() {
    todayWellnessData.glassesOfWater++;
    updateWellnessData(todayWellnessData);
    notifyListeners();
  }

  void removeWater() {
    todayWellnessData.glassesOfWater--;
    updateWellnessData(todayWellnessData);
    notifyListeners();
  }

  void deleteFoodEntryByIndex(int index) {
    FoodEntry foodEntry = todayWellnessData.foodEntries[index];

    // Remove from API (Asynchronous operation)
    ApiWellnessService().deleteFoodEntry(todayWellnessData.id, foodEntry.id);

    // Remove local Entry
    todayWellnessData.foodEntries.removeAt(index);
    notifyListeners();
  }

  Future<void> logExercise(
      String name, String type, String intensity, int caloriesBurned) async {
    final payload = {
      "name": name,
      "type": type,
      "intensity": intensity,
      "caloriesBurned": caloriesBurned,
    };

    try {
      final data = await ApiWellnessService()
          .addExerciseEntry(todayWellnessData.id, payload);
      ExerciseEntry exerciseEntry =
          ExerciseEntry.getExerciseEntryFromJson(data);

      todayWellnessData.exerciseEntries.add(exerciseEntry);
    } catch (e) {
      print("Error adding exercise entry: $e");
    }
    notifyListeners();
  }

  //
  void deleteExerciseEntryByIndex(int index) {
    ExerciseEntry exerciseEntry = todayWellnessData.exerciseEntries[index];

    // Remove from API (Asynchronous operation)
    ApiWellnessService()
        .deleteExerciseEntry(todayWellnessData.id, exerciseEntry.id);

    // Remove local Entry
    todayWellnessData.exerciseEntries.removeAt(index);

    notifyListeners();
  }

  void clearWellnessData() {
    _wellnessData.clear();
    notifyListeners();
  }
}
