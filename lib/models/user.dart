class UserPreferences {
  String id;
  String weightHeightUnits;

  UserPreferences({
    required this.id,
    required this.weightHeightUnits,
  });

  @override
  String toString() {
    return 'UserPreferences{id: $id, weightHeightUnits: $weightHeightUnits}';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'weightHeightUnits': weightHeightUnits,
    };
  }

  UserPreferences copyWith({
    String? id,
    String? weightHeightUnits,
  }) {
    return UserPreferences(
      id: id ?? this.id,
      weightHeightUnits: weightHeightUnits ?? this.weightHeightUnits,
    );
  }

  static UserPreferences getUserPreferencesFromJson(Map<String, dynamic> json) {
    return UserPreferences(
      id: json['_id'] as String,
      weightHeightUnits: json['weightHeightUnits'] as String,
    );
  }
}

class UserProfile {
  String id;
  int age;
  double weight;
  double height;
  String activityLevel;
  int calorieGoal;

  UserProfile({
    required this.id,
    required this.age,
    required this.weight,
    required this.height,
    required this.activityLevel,
    required this.calorieGoal,
  });

  @override
  String toString() {
    return 'UserProfile{id: $id, age: $age, weight: $weight, height: $height, activityLevel: $activityLevel, calorieGoal: $calorieGoal}';
  }

  static double convertWeightToImperialUnits(double weight) {
    return (weight * 2.20462).roundToDouble();
  }

  static double convertWeightToMetricUnits(double weight) {
    return (weight / 2.20462).roundToDouble();
  }

  static double convertHeightToImperialUnits(double height) {
    return (height * 0.393701).roundToDouble();
  }

  static double convertHeightToMetricUnits(double height) {
    return (height / 0.393701).roundToDouble();
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'age': age,
      'weight': weight,
      'height': height,
      'activityLevel': activityLevel,
      'calorieGoal': calorieGoal,
    };
  }

  UserProfile copyWith({
    String? id,
    int? age,
    double? weight,
    double? height,
    String? activityLevel,
    int? calorieGoal,
  }) {
    return UserProfile(
      id: id ?? this.id,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      activityLevel: activityLevel ?? this.activityLevel,
      calorieGoal: calorieGoal ?? this.calorieGoal,
    );
  }

  static UserProfile getUserProfileFromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['_id'] as String,
      age: json['age'] as int,
      weight: (json['weight'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      activityLevel: json['activityLevel'] as String,
      calorieGoal: json['calorieGoal'] as int,
    );
  }
}

class User {
  String id;
  String email;
  String username;
  String? photoUrl;
  UserProfile? userProfile;
  UserPreferences? userPreferences;

  User(
      {required this.id,
      required this.email,
      required this.username,
      this.photoUrl,
      this.userProfile,
      this.userPreferences});

  @override
  String toString() {
    return 'User{email: $email, username: $username, photoUrl: $photoUrl, userProfile: $userProfile, userPreferences: $userPreferences}';
  }

  User copyWith({
    String? id,
    String? email,
    String? username,
    String? photoUrl,
    UserProfile? userProfile,
    UserPreferences? userPreferences,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      photoUrl: photoUrl ?? this.photoUrl,
      userProfile: userProfile ?? this.userProfile,
      userPreferences: userPreferences ?? this.userPreferences,
    );
  }

  static User getUserFromJson(Map<String, dynamic> json) {
    // json is guaranteed to have 'id', 'username', and 'email' keys as well as userProfile object
    return User(
      id: json['_id'] as String,
      username: json['username'] as String,
      photoUrl: json['photoUrl'] as String?, // Safely handle nullable photoUrl
      email: json['email'] as String,
      userProfile: json['userProfile'] != null
          ? UserProfile.getUserProfileFromJson(json['userProfile'])
          : null,
      userPreferences: json['userPreferences'] != null
          ? UserPreferences.getUserPreferencesFromJson(json['userPreferences'])
          : null,
    );
  }
}
