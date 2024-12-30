class User {
  int age;
  double weight;
  String username;
  String activityLevel;
  String? photoUrl;

  User({
    required this.age,
    required this.weight,
    required this.username,
    required this.activityLevel,
    this.photoUrl,
  });

  @override
  String toString() {
    return 'User{age: $age, weight: $weight, name: $username, activityLevel: $activityLevel, photoUrl: $photoUrl}';
  }

  Map<String, dynamic> toJson() {
    return {
      'age': age,
      'weight': weight,
      'username': username,
      'activityLevel': activityLevel,
    };
  }
}
