int parseIntFromUnknown(dynamic value) {
  if (value is int) {
    return value;
  } else if (value is String) {
    return int.tryParse(value) ?? 0;
  } else if (value is double) {
    return value.toInt();
  } else {
    return 0;
  }
}

class FoodItem {
  final String units;
  final int cloriesPerUnit;

  FoodItem({
    required this.units,
    required this.cloriesPerUnit,
  });

  static FoodItem getFoodItemFromJson(Map<String, dynamic> json) {
    return FoodItem(
      units: json['units'],
      cloriesPerUnit: parseIntFromUnknown(json['cloriesPerUnit']),
    );
  }
}

class FoodEntry {
  String id;
  final String name;
  final String quantity;
  final int calories;
  final FoodItem? foodItem;

  FoodEntry({
    required this.id,
    required this.name,
    required this.quantity,
    required this.calories,
    this.foodItem,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'calories': calories,
    };
  }

  static FoodEntry getFoodEntryFromJson(Map<String, dynamic> json) {
    return FoodEntry(
      id: json['_id'],
      name: json['name'],
      quantity: json['quantity'],
      calories: parseIntFromUnknown(json['calories']),
      foodItem: json['foodItem'] != null
          ? FoodItem.getFoodItemFromJson(json['foodItem'])
          : null,
    );
  }
}

class ExerciseEntry {
  String id;
  final String name;
  final String type;
  final String intensity;
  final int caloriesBurned;

  ExerciseEntry({
    required this.id,
    required this.name,
    required this.type,
    required this.intensity,
    required this.caloriesBurned,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'intensity': intensity,
      'caloriesBurned': caloriesBurned,
    };
  }

  static ExerciseEntry getExerciseEntryFromJson(Map<String, dynamic> json) {
    return ExerciseEntry(
      id: json['_id'],
      name: json['name'],
      type: json['type'],
      intensity: json['intensity'],
      caloriesBurned: json['caloriesBurned'],
    );
  }
}

class DateWellnessData {
  String id;
  String userId;
  final List<FoodEntry> foodEntries;
  final List<ExerciseEntry> exerciseEntries;
  int glassesOfWater;
  final String date;

  DateWellnessData({
    required this.id,
    required this.userId,
    required this.foodEntries,
    required this.exerciseEntries,
    required this.glassesOfWater,
    required this.date,
  });

  @override
  String toString() {
    return 'DateWellnessData{id: $id, userId: $userId, foodEntries: $foodEntries, exerciseEntries: $exerciseEntries, glassesOfWater: $glassesOfWater, date: $date}';
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'foodEntries': foodEntries
          .map((entry) => FoodEntry.getFoodEntryFromJson(entry.toJson()))
          .toList(),
      'exerciseEntries': exerciseEntries
          .map(
              (entry) => ExerciseEntry.getExerciseEntryFromJson(entry.toJson()))
          .toList(),
      'glassesOfWater': glassesOfWater,
      'date': date,
    };
  }

  static DateWellnessData getWellnessDataFromJson(Map<String, dynamic> json) {
    return DateWellnessData(
      id: json['_id'],
      userId: json['userId'],
      date: json['date'],
      glassesOfWater: json['glassesOfWater'],
      foodEntries: json['foodEntries']
          .map<FoodEntry>((entry) => FoodEntry.getFoodEntryFromJson(entry))
          .toList(),
      exerciseEntries: json['exerciseEntries']
          .map<ExerciseEntry>((entry) => ExerciseEntry(
                id: entry['_id'],
                name: entry['name'],
                type: entry['type'],
                intensity: entry['intensity'],
                caloriesBurned: entry['caloriesBurned'],
              ))
          .toList(),
    );
  }
}
