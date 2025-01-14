import 'package:fasthealthcheck/services/api/classes/api_wellness.dart';
import 'package:fasthealthcheck/services/service_locator.dart';
import 'package:get_it/get_it.dart';
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

  final ApiWellnessService apiWellnessService = getIt<ApiWellnessService>();
  final UserService userService = GetIt.instance<UserService>();
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
    User currentUser = UserService().currentUser!;
    final consumed = caloriesConsumed;
    final burned = exerciseBurned;
    return currentUser.userProfile!.calorieGoal - consumed + burned;
  }

  int get currentStreak => streak;

  Future<DateWellnessData> initializeWellnessData() async {
    print("Initializing wellness data for $_selectedDate");
    DateWellnessData wellnessData =
        await getOrCreateDateWellnessData(_selectedDate);

    final streakData = await apiWellnessService
        .getWellnessStreak(UserService().currentUser!.id);
    streak = streakData['streak'];

    notifyListeners();

    return wellnessData;
  }

  Future<DateWellnessData> refreshWellnessData() async {
    DateWellnessData wellnessData =
        await getOrCreateDateWellnessData(_selectedDate);
    notifyListeners();

    return wellnessData;
  }

  Future<DateWellnessData> getOrCreateDateWellnessData(DateTime date) async {
    final String formattedDate = formatToDateOnly(date);
    User user = UserService().currentUser!;
    try {
      final wellnessDataJson = await apiWellnessService.getWellnessDataByDate(
          user.id, formattedDate);

      print("Wellness Data: $wellnessDataJson");

      DateWellnessData wellnessData =
          DateWellnessData.getWellnessDataFromJson(wellnessDataJson);

      _wellnessData[formattedDate] = wellnessData;
      return wellnessData;
    } catch (e) {
      print(e);

      print("Creating new wellness data for $formattedDate");
      // Create a new DateWellnessData object for the date
      final newWellnessData = await apiWellnessService.createWellnessData(
          UserService().currentUser!.id, formattedDate, 0);

      final wellnessData =
          DateWellnessData.getWellnessDataFromJson(newWellnessData);
      _wellnessData[formattedDate] = wellnessData;

      return wellnessData;
    }
  }

  Future<void> updateWellnessData(DateWellnessData wellnessData) async {
    try {
      await apiWellnessService.updateWellnessData(wellnessData.id, {
        'glassesOfWater': wellnessData.glassesOfWater,
      });
    } catch (e) {
      print("Error updating wellness data: $e");
    }
  }

  // Modifiers
  //  NOTE: These current modify the object by its reference in the map
  //    Eventually the object should be provided by the function and then updated and replaced in the map

  Future<FoodEntry> addCalories(
      String foodName, String quantity, int? calories) async {
    final FoodEntryPayload payload = FoodEntryPayload(
        name: foodName, quantity: quantity, calories: calories);

    try {
      final data = await apiWellnessService.addFoodEntry(
          currentDateWellnessData.id, payload);

      FoodEntry foodEntry = FoodEntry.getFoodEntryFromJson(data);

      currentDateWellnessData.foodEntries.add(foodEntry);
      notifyListeners();

      return foodEntry;
    } catch (e) {
      print("Error adding food entry: $e");
      rethrow;
    }
  }

  void setWater(int? glasses) {
    currentDateWellnessData.glassesOfWater = glasses ?? 0;
    updateWellnessData(currentDateWellnessData);
    notifyListeners();
  }

  Future<void> updateFoodEntry(String wellnessDataId, String foodEntryId,
      int newCalories, int entryIndex) async {
    // Update in API (Asynchronous operation)
    final data = await apiWellnessService
        .updateFoodEntry(currentDateWellnessData.id, foodEntryId, {
      'calories': newCalories,
    });

    final updatedFoodEntry = FoodEntry.getFoodEntryFromJson(data);

    // Update local Entry
    currentDateWellnessData.foodEntries[entryIndex] = updatedFoodEntry;

    notifyListeners();
  }

  void deleteFoodEntryByIndex(int index) {
    FoodEntry foodEntry = currentDateWellnessData.foodEntries[index];

    // Remove from API (Asynchronous operation)
    apiWellnessService.deleteFoodEntry(
        currentDateWellnessData.id, foodEntry.id);

    // Remove local Entry
    currentDateWellnessData.foodEntries.removeAt(index);
    notifyListeners();
  }

  Future<ExerciseEntry> logExercise(String name, String type, String intensity,
      int duration, int? caloriesBurned) async {
    final ExerciseEntryPayload payload = ExerciseEntryPayload(
      name: name,
      type: type,
      intensity: intensity,
      duration: duration,
      caloriesBurned: caloriesBurned,
    );

    try {
      final data = await apiWellnessService.addExerciseEntry(
          currentDateWellnessData.id, payload);
      ExerciseEntry exerciseEntry =
          ExerciseEntry.getExerciseEntryFromJson(data);

      currentDateWellnessData.exerciseEntries.add(exerciseEntry);
      notifyListeners();

      return exerciseEntry;
    } catch (e) {
      print("Error adding exercise entry: $e");
      rethrow;
    }
  }

  void deleteExerciseEntryByIndex(int index) {
    ExerciseEntry exerciseEntry =
        currentDateWellnessData.exerciseEntries[index];

    // Remove from API (Asynchronous operation)
    apiWellnessService.deleteExerciseEntry(
        currentDateWellnessData.id, exerciseEntry.id);

    // Remove local Entry
    currentDateWellnessData.exerciseEntries.removeAt(index);

    notifyListeners();
  }

  Future<void> updateFoodItemQuantity(String wellnessDataId, String foodEntryId,
      String foodItemId, String newQuantity, int entryIndex) async {
    try {
      final updatedFoodEntryJson =
          await apiWellnessService.updateFoodItemQuantity(
        foodEntryId,
        foodItemId,
        quantity: newQuantity,
      );
      final updatedFoodEntry =
          FoodEntry.getFoodEntryFromJson(updatedFoodEntryJson);

      // Replace the old entry with the updated one
      currentDateWellnessData.foodEntries[entryIndex] = updatedFoodEntry;
      notifyListeners();
    } catch (e) {
      print("Error updating food item quantity: $e");
      rethrow;
    }
  }

  Future<void> deleteFoodItemQuantity(String wellnessDataId, String foodEntryId,
      String foodItemId, int entryIndex) async {
    try {
      final updatedFoodEntryJson =
          await apiWellnessService.deleteFoodItemQuantity(
        foodEntryId,
        foodItemId,
      );

      // If this was the last food item quantity, delete the food entry
      //  This is determine by the food entry having no food item quantities
      if (updatedFoodEntryJson['foodItemQuantities'].isEmpty) {
        // This is not amazing, but it works
        //    This is a chain of async operations that are not awaited
        deleteFoodEntryByIndex(entryIndex);
        return;
      }

      final updatedFoodEntry =
          FoodEntry.getFoodEntryFromJson(updatedFoodEntryJson);

      // Replace the old entry with the updated one
      currentDateWellnessData.foodEntries[entryIndex] = updatedFoodEntry;
      notifyListeners();
    } catch (e) {
      print("Error deleting food item quantity: $e");
      rethrow;
    }
  }

  void clearWellnessData() {
    _wellnessData.clear();
    notifyListeners();
  }
}
