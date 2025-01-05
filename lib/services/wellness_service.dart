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
  // Constants
  static const int recommendedGlassesOfWater = 8;

  final Map<String, DateWellnessData> _wellnessData = {};
  final DateTime today = DateTime.now();
  DateTime _selectedDate = DateTime.now();

  int streak = 0;

  // selectedDate is the date that the user is currently viewing as a DateTime
  DateTime get selectedDate => _selectedDate;

  // currentDateFormatted is the selectedDate formatted as a string for the wellnessData map
  String get currentDateFormatted => formatToDateOnly(_selectedDate);
  set selectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  DateWellnessData get currentDateWellnessData {
    final dayWellnessData = _wellnessData[currentDateFormatted];
    if (dayWellnessData == null) {
      return _wellnessData[currentDateFormatted]!;
    }
    return dayWellnessData;
  }

  //  TODO: Implement the following getters to get true data
  int get exerciseGoal => 1000;

  // Each getting gets the values below for the current date in the wellnessData map
  int get glassesOfWater => () {
        final dayWellnessData = _wellnessData[currentDateFormatted];
        return dayWellnessData?.glassesOfWater ?? 0;
      }();

  int get caloriesConsumed => () {
        final dayWellnessData = _wellnessData[currentDateFormatted];
        if (dayWellnessData != null) {
          return dayWellnessData.foodEntries
              .fold(0, (sum, entry) => sum + entry.calories);
        }
        return 0;
      }();

  int get exerciseBurned => () {
        final dayWellnessData = _wellnessData[currentDateFormatted];
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
    print("Initializing wellness data for $_selectedDate");
    await getOrCreateDateWellnessData(_selectedDate);

    final streakData = await ApiWellnessService()
        .getWellnessStreak(UserService().currentUser!.id);
    streak = streakData['streak'];

    notifyListeners();
  }

  Future<void> refreshWellnessData() async {
    await getOrCreateDateWellnessData(_selectedDate);
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
          .addFoodEntry(currentDateWellnessData.id, payload);
      FoodEntry foodEntry = FoodEntry.getFoodEntryFromJson(data);

      currentDateWellnessData.foodEntries.add(foodEntry);
    } catch (e) {
      print("Error adding food entry: $e");
    }

    notifyListeners();
  }

  void addWater() {
    currentDateWellnessData.glassesOfWater++;
    updateWellnessData(currentDateWellnessData);
    notifyListeners();
  }

  void removeWater() {
    currentDateWellnessData.glassesOfWater--;
    updateWellnessData(currentDateWellnessData);
    notifyListeners();
  }

  void deleteFoodEntryByIndex(int index) {
    FoodEntry foodEntry = currentDateWellnessData.foodEntries[index];

    // Remove from API (Asynchronous operation)
    ApiWellnessService()
        .deleteFoodEntry(currentDateWellnessData.id, foodEntry.id);

    // Remove local Entry
    currentDateWellnessData.foodEntries.removeAt(index);
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
          .addExerciseEntry(currentDateWellnessData.id, payload);
      ExerciseEntry exerciseEntry =
          ExerciseEntry.getExerciseEntryFromJson(data);

      currentDateWellnessData.exerciseEntries.add(exerciseEntry);
    } catch (e) {
      print("Error adding exercise entry: $e");
    }
    notifyListeners();
  }

  //
  void deleteExerciseEntryByIndex(int index) {
    ExerciseEntry exerciseEntry =
        currentDateWellnessData.exerciseEntries[index];

    // Remove from API (Asynchronous operation)
    ApiWellnessService()
        .deleteExerciseEntry(currentDateWellnessData.id, exerciseEntry.id);

    // Remove local Entry
    currentDateWellnessData.exerciseEntries.removeAt(index);

    notifyListeners();
  }

  void clearWellnessData() {
    _wellnessData.clear();
    notifyListeners();
  }
}
