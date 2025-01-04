class UserProfile {
  String id;
  int age;
  double weight;
  String activityLevel;

  UserProfile({
    required this.id,
    required this.age,
    required this.weight,
    required this.activityLevel,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'age': age,
      'weight': weight,
      'activityLevel': activityLevel,
    };
  }

  UserProfile copyWith({
    String? id,
    int? age,
    double? weight,
    String? activityLevel,
  }) {
    return UserProfile(
      id: id ?? this.id,
      age: age ?? this.age,
      weight: weight ?? this.weight,
      activityLevel: activityLevel ?? this.activityLevel,
    );
  }
}

class User {
  String id;
  String email;
  String username;
  String? photoUrl;
  UserProfile? userProfile;

  User({
    required this.id,
    required this.email,
    required this.username,
    this.photoUrl,
    this.userProfile,
  });

  @override
  String toString() {
    return 'User{email: $email, username: $username, photoUrl: $photoUrl}';
  }

  Map<String, dynamic> toJson() {
    return {
      'age': userProfile?.age,
      'weight': userProfile?.weight,
      'username': username,
      'activityLevel': userProfile?.activityLevel,
      if (photoUrl != null) 'photoUrl': photoUrl,
    };
  }

  User copyWith({
    String? id,
    String? email,
    String? username,
    String? photoUrl,
    UserProfile? userProfile,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      photoUrl: photoUrl ?? this.photoUrl,
      userProfile: userProfile ?? this.userProfile,
    );
  }

  factory User.fromJson(Map<String, dynamic> json) {
    // json is guaranteed to have 'id', 'username', and 'email' keys as well as userProfile object
    return User(
      id: json['id'] as String,
      username: json['username'] as String,
      photoUrl: json['photoUrl'] as String?, // Safely handle nullable photoUrl
      email: json['email'] as String,
      userProfile: UserProfile(
        id: json['userProfile']['id'] as String,
        age: json['userProfile']['age'] as int,
        weight: (json['userProfile']['weight'] as num).toDouble(),
        activityLevel: json['userProfile']['activityLevel'] as String,
      ),
    );
  }
}
