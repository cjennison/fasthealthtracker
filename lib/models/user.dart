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
      if (photoUrl != null) 'photoUrl': photoUrl,
    };
  }

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      age: json['age'] as int,
      weight: (json['weight'] as num).toDouble(),
      username: json['username'] as String,
      activityLevel: json['activityLevel'] as String,
      photoUrl: json['photoUrl'] as String?, // Safely handle nullable photoUrl
    );
  }
}
