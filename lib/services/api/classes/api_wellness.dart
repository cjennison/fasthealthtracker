class FoodEntryPayload {
  final String name;
  final String quantity;
  final int? calories;

  FoodEntryPayload({
    required this.name,
    required this.quantity,
    this.calories,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "quantity": quantity,
      "calories": calories,
    };
  }
}

class ExerciseEntryPayload {
  final String name;
  final String type;
  final String intensity;
  final int duration;
  int? caloriesBurned;

  ExerciseEntryPayload({
    required this.name,
    required this.type,
    required this.intensity,
    required this.duration,
    this.caloriesBurned,
  });

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "type": type,
      "intensity": intensity,
      "duration": duration,
      "caloriesBurned": caloriesBurned,
    };
  }
}
