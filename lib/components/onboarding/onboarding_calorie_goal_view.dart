import 'package:fasthealthcheck/models/user.dart';
import 'package:fasthealthcheck/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OnboardingCalorieGoalView extends StatefulWidget {
  const OnboardingCalorieGoalView({
    super.key,
  });

  @override
  State<OnboardingCalorieGoalView> createState() =>
      _OnboardingCalorieGoalView();
}

class _OnboardingCalorieGoalView extends State<OnboardingCalorieGoalView> {
  late UserService userService;
  late int _calorieTarget;
  late String _activityLevel;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    userService = Provider.of<UserService>(context, listen: false);
    initializeData();
  }

  void initializeData() {
    final user = userService.currentUser;

    setState(() {
      if (user != null) {
        _calorieTarget = 2000;
        _activityLevel = user.userProfile!.activityLevel;
        getCalorieTarget(user.id);
      }
    });
  }

  void onActivityLevelChanged(String value) {
    final user = userService.currentUser!;
    setState(() {
      _activityLevel = value;
    });

    getCalorieTarget(user.id);
  }

  void onCalorieTargetUpdated(int value) {
    setState(() {
      _calorieTarget = value;
    });
  }

  Future<void> getCalorieTarget(String userId) async {
    int value = await Provider.of<UserService>(context, listen: false)
        .getCalorieTarget(userId, _activityLevel);

    setState(() {
      isLoading = false;
      _calorieTarget = value;
    });
  }

  Future<void> onFinish() async {
    final user = userService.currentUser!;

    UserProfile userProfile = user.userProfile!.copyWith(
      calorieGoal: _calorieTarget,
      activityLevel: _activityLevel,
    );

    await userService.updateUserProfile(user.id, userProfile);
    Navigator.pushNamedAndRemoveUntil(context, '/app', (route) => false);
  }

  void _openSliderDialog() {
    showDialog(
      context: context,
      builder: (context) {
        int tempCalorieTarget = _calorieTarget;
        return AlertDialog(
          title: const Text('Set Calorie Goal'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              StatefulBuilder(
                builder: (context, setState) {
                  return Column(
                    children: [
                      Text(
                        '$tempCalorieTarget kcal/day',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      Slider(
                        value: tempCalorieTarget.toDouble(),
                        min: 1200,
                        max: 4000,
                        divisions: 28,
                        label: tempCalorieTarget.toString(),
                        onChanged: (value) {
                          setState(() => tempCalorieTarget = value.toInt());
                        },
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                onCalorieTargetUpdated(tempCalorieTarget);
                Navigator.pop(context);
              },
              child: const Text('Set'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 600,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              isLoading
                  ? const CircularProgressIndicator()
                  : Text(
                      '$_calorieTarget kcal/day',
                      style:
                          Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                    ),
              const SizedBox(height: 8),
              Text(
                'This is your recommended daily calorie intake.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _openSliderDialog,
                child: const Text('Set my calorie goal manually'),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        'You can edit your calorie intake by adjusting your activity level.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        value: _activityLevel,
                        items: const [
                          DropdownMenuItem(value: 'low', child: Text('Low')),
                          DropdownMenuItem(
                              value: 'moderate', child: Text('Moderate')),
                          DropdownMenuItem(
                              value: 'active', child: Text('Active')),
                        ],
                        onChanged: (value) {
                          onActivityLevelChanged(value!);
                        },
                        decoration: const InputDecoration(
                          labelText: 'Activity Level',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: onFinish,
                child: const Text('Finish'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
