import 'package:fasthealthcheck/models/user.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fasthealthcheck/services/user_service.dart';

class CalorieGoalCard extends StatefulWidget {
  final Function? onCalorieUpdated; // Optional callback for parent views

  const CalorieGoalCard({super.key, this.onCalorieUpdated});

  @override
  State<CalorieGoalCard> createState() => _CalorieGoalCardState();
}

class _CalorieGoalCardState extends State<CalorieGoalCard> {
  late int _calorieTarget;
  late int _storedCalorieGoal; // Used to see the calorie goal before saving
  late String _activityLevel;
  late String
      _previewActivityLevel; // Used to see the calorie goal before saving
  bool isLoading = true;
  bool isSaving = false;
  User? user;
  UserService get userService =>
      Provider.of<UserService>(context, listen: false);
  Timer? debounce;

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  void initializeData() {
    user = userService.currentUser;

    if (user != null) {
      _calorieTarget = user!.userProfile?.calorieGoal ?? 2000;
      _activityLevel = user!.userProfile?.activityLevel ?? 'moderate';
      _previewActivityLevel = _activityLevel;
      _storedCalorieGoal = _calorieTarget;
      setState(() => isLoading = false);
    }
  }

  Future<void> getCalorieTarget() async {
    int value = await Provider.of<UserService>(context, listen: false)
        .getCalorieTarget(user!.id, _previewActivityLevel);

    setState(() {
      _calorieTarget = value;
    });
  }

  void onActivityLevelChanged(String value) {
    setState(() {
      _previewActivityLevel = value;
    });

    getCalorieTarget();
  }

  void onCalorieTargetUpdated(int value) {
    setState(() {
      _calorieTarget = value;
    });

    widget.onCalorieUpdated?.call(value);
  }

  Future<void> updateCalorieGoal() async {
    setState(() => isSaving = true);

    if (user != null) {
      UserProfile newUserProfile = user!.userProfile!.copyWith(
        calorieGoal: _calorieTarget,
        activityLevel: _previewActivityLevel,
      );

      await userService.updateUserProfile(user!.id, newUserProfile);

      setState(() {
        _activityLevel = _previewActivityLevel;
        _storedCalorieGoal = _calorieTarget;
        isSaving = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('Calorie Goal updated successfully to $_calorieTarget!')),
      );
    }
  }

  void resetValues() {
    setState(() {
      _calorieTarget = _storedCalorieGoal;
      _previewActivityLevel = _activityLevel;
    });
  }

  void _openSliderDialog() {
    showDialog(
      context: context,
      builder: (context) {
        int tempCalorieTarget = _calorieTarget;
        return AlertDialog(
          title: const Text('Set Calorie Goal'),
          content: StatefulBuilder(builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
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
                  divisions: 56,
                  label: tempCalorieTarget.toString(),
                  onChanged: (value) {
                    setState(() => tempCalorieTarget = value.toInt());
                  },
                ),
              ],
            );
          }),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                onCalorieTargetUpdated(tempCalorieTarget);
                updateCalorieGoal();
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
    return isLoading
        ? const CircularProgressIndicator()
        : Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    "Calorie Goal",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  Text(
                    'Calorie Goal: $_calorieTarget kcal/day',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  ElevatedButton(
                    onPressed: _openSliderDialog,
                    child: const Text('Adjust Calorie Goal Manually'),
                  ),
                  DropdownButtonFormField<String>(
                    value: _previewActivityLevel,
                    items: const [
                      DropdownMenuItem(value: 'low', child: Text('Low')),
                      DropdownMenuItem(
                          value: 'moderate', child: Text('Moderate')),
                      DropdownMenuItem(value: 'active', child: Text('Active')),
                    ],
                    onChanged: (value) {
                      onActivityLevelChanged(value!);
                    },
                    decoration: const InputDecoration(
                      labelText: 'Activity Level',
                    ),
                  ),
                  if (_previewActivityLevel != _activityLevel ||
                      _calorieTarget != _storedCalorieGoal)
                    Column(children: [
                      Text(
                        'New Calorie Goal: $_calorieTarget kcal/day',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      Row(
                        children: [
                          ElevatedButton(
                              onPressed: () {
                                updateCalorieGoal();
                              },
                              child: isSaving
                                  ? CircularProgressIndicator()
                                  : Text('Save Changes')),
                          ElevatedButton(
                              onPressed: () {
                                resetValues();
                              },
                              child: const Text('Cancel')),
                        ],
                      ),
                    ]),
                ],
              ),
            ),
          );
  }
}
