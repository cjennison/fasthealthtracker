import 'package:fasthealthcheck/components/home/profile/account_settings.dart';
import 'package:fasthealthcheck/components/shared/calorie_goal_card.dart';
import 'package:fasthealthcheck/models/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fasthealthcheck/services/user_service.dart';
import 'package:fasthealthcheck/services/wellness_service.dart';
import 'package:fasthealthcheck/components/home/verification_view.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late UserService userService;
  bool isEditing = false;
  late int age;
  late double weight;
  late double height;
  late String units;
  double weightMax = 350.0;
  double weightMin = 70.0;
  double heightMax = 250.0;
  double heightMin = 100.0;

  @override
  void initState() {
    super.initState();
    userService = Provider.of<UserService>(context, listen: false);

    final user = Provider.of<UserService>(context, listen: false).currentUser;
    if (user != null) {
      setProfileValues(user);
    } else {
      print("User is null");
    }
  }

  void setProfileValues(User user) {
    // Set base values from the stored data
    age = user.userProfile!.age;

    units = user.userPreferences!.weightHeightUnits;

    double storedWeight = user.userProfile!.weight; // Metric
    double storedHeight = user.userProfile!.height; // Metric

    // Convert for visual display if the user preference is imperial
    if (units == 'imperial') {
      weight = UserProfile.convertWeightToImperialUnits(storedWeight);
      height = UserProfile.convertHeightToImperialUnits(storedHeight);
      _setImperialRanges();
    } else {
      weight = storedWeight;
      height = storedHeight;
      _setMetricRanges();
    }
  }

  void _setMetricRanges() {
    setState(() {
      weightMin = 70.0;
      weightMax = 350.0;
      heightMin = 100.0;
      heightMax = 250.0;
    });
  }

  void _setImperialRanges() {
    setState(() {
      weightMin = 150.0;
      weightMax = 500.0;
      heightMin = 35.0;
      heightMax = 100.0;
    });
  }

  void _toggleEditMode() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  void _saveProfile() {
    final userService = Provider.of<UserService>(context, listen: false);
    final currentUser = userService.currentUser;

    if (currentUser != null) {
      // Get the metric version of height and weight if units are not metric
      double metricWeight = units == 'imperial'
          ? UserProfile.convertWeightToMetricUnits(weight)
          : weight;
      double metricHeight = units == 'imperial'
          ? UserProfile.convertHeightToMetricUnits(height)
          : height;

      UserProfile updatedProfile = currentUser.userProfile!.copyWith(
        age: age,
        weight: metricWeight,
        height: metricHeight,
      );
      userService.updateUserProfile(currentUser.id, updatedProfile);

      UserPreferences updatedPreferences =
          currentUser.userPreferences!.copyWith(
        weightHeightUnits: units,
      );
      userService.updateUserPreferences(currentUser.id, updatedPreferences);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    }

    setState(() {
      isEditing = false;
    });
  }

  void _changeUnits(String newUnits) {
    setState(() {
      units = newUnits;

      if (units == 'imperial') {
        _setImperialRanges();

        weight = UserProfile.convertWeightToImperialUnits(weight);
        height = UserProfile.convertHeightToImperialUnits(height);
      } else {
        _setMetricRanges();
        weight = UserProfile.convertWeightToMetricUnits(weight);
        height = UserProfile.convertHeightToMetricUnits(height);
      }

      weight = weight.clamp(weightMin, weightMax);
      height = height.clamp(heightMin, heightMax);
    });
  }

  void _handleLogout(BuildContext context) {
    Provider.of<UserService>(context, listen: false).logout();
    Provider.of<WellnessService>(context, listen: false).clearWellnessData();
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    final userService = Provider.of<UserService>(context);
    final user = userService.currentUser;

    String weightUnits = units == 'metric' ? 'kgs' : 'lbs';
    String heightUnits = units == 'metric' ? 'cm' : 'inches';

    if (user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/onboarding');
      });
      return const SizedBox.shrink(); // Prevent rendering if user is null.
    }

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: user.photoUrl == null
                      ? const CircleAvatar(
                          radius: 24,
                          child: Icon(Icons.person),
                        )
                      : CircleAvatar(
                          backgroundImage: NetworkImage(user.photoUrl!),
                          radius: 24,
                        ),
                ),
                const SizedBox(width: 10),
                Text(
                  user.username,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 20),
            Flexible(
              child: SingleChildScrollView(
                  child: (Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  userService.isUserVerified
                      ? Row(
                          children: const [
                            Icon(Icons.check, color: Colors.green),
                            SizedBox(width: 8),
                            Text('Email verified'),
                          ],
                        )
                      : const VerificationView(),
                  if (isEditing)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Age:', style: TextStyle(fontSize: 18)),
                        TextFormField(
                          initialValue: age.toString(),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            age = int.tryParse(value) ?? age;
                          },
                        ),
                        const SizedBox(height: 20),
                        // Height Slider
                        Row(
                          children: [
                            Text(
                                'Weight ($weightUnits): ${weight.toStringAsFixed(0)}'),
                            Expanded(
                              child: Slider(
                                value: weight,
                                min: weightMin,
                                max: weightMax,
                                divisions: (weightMax - weightMin).toInt(),
                                label: weight.toStringAsFixed(0),
                                onChanged: (value) {
                                  setState(() {
                                    // Round to nearest integer
                                    weight = value.roundToDouble();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // Height Slider
                        Row(
                          children: [
                            Text(
                                'Height ($heightUnits): ${height.toStringAsFixed(0)}'),
                            Expanded(
                              child: Slider(
                                value: height,
                                min: heightMin,
                                max: heightMax,
                                divisions: (heightMax - heightMin).toInt(),
                                label: height.toStringAsFixed(0),
                                onChanged: (value) {
                                  setState(() {
                                    height = value.roundToDouble();
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        Divider(),
                        // Units Dropdown
                        DropdownButtonFormField<String>(
                          value: units,
                          items: const [
                            DropdownMenuItem(
                                value: 'metric', child: Text('Metric')),
                            DropdownMenuItem(
                                value: 'imperial', child: Text('Imperial')),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _changeUnits(value!);
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'Units',
                          ),
                        ),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Age: ${user.userProfile!.age}',
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Weight: $weight $weightUnits',
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Height: $height $heightUnits',
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Units: ${user.userPreferences!.weightHeightUnits}',
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  //  const Spacer(),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: isEditing
                        ? [
                            ElevatedButton(
                              onPressed: _saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                              child: const Text(
                                'Save',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: _toggleEditMode,
                              child: const Text('Cancel'),
                            ),
                          ]
                        : [
                            ElevatedButton(
                              onPressed: _toggleEditMode,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                              ),
                              child: const Text(
                                'Edit',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () => _handleLogout(context),
                              child: const Text(
                                'Logout',
                              ),
                            ),
                          ],
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: 600,
                        ),
                        child: const CalorieGoalCard()),
                  ),
                  SizedBox(height: 20),

                  Center(
                    child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: 600,
                        ),
                        child: const AccountSettings()),
                  ),
                  SizedBox(height: 20),
                ],
              ))),
            )
          ],
        ),
      ),
    );
  }
}
