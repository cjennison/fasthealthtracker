class User {
  int age;
  double weight;
  String username;
  String activityLevel;

  User({
    required this.age,
    required this.weight,
    required this.username,
    required this.activityLevel,
  });

  @override
  String toString() {
    return 'User{age: $age, weight: $weight, name: $username, activityLevel: $activityLevel}';
  }
}
