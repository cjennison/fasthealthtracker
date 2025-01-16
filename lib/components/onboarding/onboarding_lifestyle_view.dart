// onboarding_lifestyle_view.dart
import 'package:fasthealthcheck/components/onboarding/onboarding_calorie_goal_view.dart';
import 'package:fasthealthcheck/components/utils/show_snackbar.dart';
import 'package:fasthealthcheck/models/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fasthealthcheck/services/user_service.dart';

class OnboardingLifestyleView extends StatefulWidget {
  const OnboardingLifestyleView({super.key});

  @override
  State<OnboardingLifestyleView> createState() =>
      _OnboardingLifestyleViewState();
}

class _OnboardingLifestyleViewState extends State<OnboardingLifestyleView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  late UserService userService;

  // Default values
  int age = 25; // Default to 25
  double weight = 70.0; // Default weight in metric (kg)
  double height = 170.0; // Default height in metric (cm)
  String activityLevel = 'moderate'; // Default activity level
  String units = 'metric'; // Default to metric
  double weightMax = 350.0;
  double weightMin = 70.0;
  double heightMax = 250.0;
  double heightMin = 100.0;

  @override
  void initState() {
    super.initState();
    userService = Provider.of<UserService>(context, listen: false);

    final user = userService.currentUser;
    if (user != null) {
      setProfileValues(user);
    } else {
      print("User is null");
    }
  }

  @override
  void dispose() {
    // Dispose controllers
    weightController.dispose();
    heightController.dispose();
    super.dispose();
  }

  void setProfileValues(User user) {
    // Initialize values from the user object
    age = user.userProfile?.age ?? age; // Default to 25 if null
    activityLevel = user.userProfile?.activityLevel ?? activityLevel;
    units = user.userPreferences?.weightHeightUnits ?? units;

    double storedWeight = user.userProfile?.weight ?? weight;
    double storedHeight = user.userProfile?.height ?? height;

    // Convert for display if units are imperial
    if (units == 'imperial') {
      weight = UserProfile.convertWeightToImperialUnits(storedWeight);
      height = UserProfile.convertHeightToImperialUnits(storedHeight);
      _setImperialRanges();
    } else {
      weight = storedWeight;
      height = storedHeight;
      _setMetricRanges();
    }

    weightController.text = weight.toStringAsFixed(1);
    heightController.text = height.toStringAsFixed(1);
  }

  void _setMetricRanges() {
    weightMin = 70.0;
    weightMax = 350.0;
    heightMin = 100.0;
    heightMax = 250.0;
  }

  void _setImperialRanges() {
    weightMin = 150.0;
    weightMax = 500.0;
    heightMin = 35.0;
    heightMax = 100.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tell us about yourself'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                children: [
                  const SizedBox(height: 60),
                  TextFormField(
                    initialValue: age.toString(),
                    decoration: const InputDecoration(labelText: 'Age'),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        age = int.tryParse(value) ?? age;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: units,
                    items: const [
                      DropdownMenuItem(value: 'metric', child: Text('Metric')),
                      DropdownMenuItem(
                          value: 'imperial', child: Text('Imperial')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        units = value!;
                        if (units == 'imperial') {
                          _setImperialRanges();
                          weight =
                              UserProfile.convertWeightToImperialUnits(weight);
                          height =
                              UserProfile.convertHeightToImperialUnits(height);
                        } else {
                          _setMetricRanges();
                          weight =
                              UserProfile.convertWeightToMetricUnits(weight);
                          height =
                              UserProfile.convertHeightToMetricUnits(height);
                        }

                        weightController.text = weight.toStringAsFixed(1);
                        heightController.text = height.toStringAsFixed(1);
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Units'),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: weightController,
                    decoration: InputDecoration(
                      labelText:
                          'Weight (${units == 'metric' ? 'kgs' : 'lbs'})',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: heightController,
                    decoration: InputDecoration(
                      labelText:
                          'Height (${units == 'metric' ? 'cm' : 'inches'})',
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: activityLevel,
                    items: const [
                      DropdownMenuItem(value: 'low', child: Text('Low')),
                      DropdownMenuItem(
                          value: 'moderate', child: Text('Moderate')),
                      DropdownMenuItem(value: 'active', child: Text('Active')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        activityLevel = value!;
                      });
                    },
                    decoration:
                        const InputDecoration(labelText: 'Activity Level'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _submitDetails,
                    child: const Text('Continue'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitDetails() async {
    final userService = Provider.of<UserService>(context, listen: false);

    double metricWeight = units == 'imperial'
        ? UserProfile.convertWeightToMetricUnits(
            double.tryParse(weightController.text) ?? 70.0)
        : double.tryParse(weightController.text) ?? 70.0;

    double metricHeight = units == 'imperial'
        ? UserProfile.convertHeightToMetricUnits(
            double.tryParse(heightController.text) ?? 170.0)
        : double.tryParse(heightController.text) ?? 170.0;

    await userService.updateUserProfile(
      userService.currentUser!.id,
      UserProfile(
        id: userService.currentUser!.userProfile!.id,
        age: age,
        weight: metricWeight,
        height: metricHeight,
        activityLevel: activityLevel,
        calorieGoal: userService.currentUser!.userProfile!.calorieGoal,
      ),
    );

    UserPreferences updatedPreferences =
        userService.currentUser!.userPreferences!.copyWith(
      weightHeightUnits: units,
    );

    try {
      await userService.updateUserPreferences(
          userService.currentUser!.id, updatedPreferences);

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => const OnboardingCalorieGoalView()),
      );
    } catch (e) {
      print(e);
      showSnackbar(context, "Something went wrong updating your profile",
          SnackbarType.error);
    }
  }
}
