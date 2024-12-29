import 'package:fasthealthcheck/services/user_service.dart';
import 'package:flutter/material.dart';
import 'package:numberpicker/numberpicker.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:fasthealthcheck/components/onboarding/onboarding_controller.dart';
import 'package:fasthealthcheck/components/onboarding/username_view.dart';

bool isMobile() {
  if (kIsWeb) return false; // Web is not mobile
  try {
    return Platform.isAndroid || Platform.isIOS;
  } catch (e) {
    return false; // If Platform is not available (e.g., Web), return false
  }
}

class OnboardingView extends StatelessWidget {
  const OnboardingView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserService>(context, listen: false).currentUser;

    // Redirect to /app if user data already exists
    if (user != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/app');
      });
    }

    // Listen to changes from the controller
    final onboardingController = Provider.of<OnboardingController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a profile'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: onboardingController.step1FormKey,
              child: ListView(
                children: [
                  Text('Age',
                      style: Theme.of(context).textTheme.headlineMedium),
                  isMobile()
                      ? NumberPicker(
                          value: onboardingController.age,
                          onChanged: (value) {
                            onboardingController.setAge(value);
                          },
                          axis: Axis.horizontal,
                          minValue: 8,
                          maxValue: 99,
                        )
                      :
                      // On desktop, use a vertical number picker
                      TextFormField(
                          initialValue: onboardingController.age.toString(),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            final int? age = int.tryParse(value);
                            if (age != null && age >= 8 && age <= 99) {
                              onboardingController.setAge(age);
                            }
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your age';
                            }
                            final int? age = int.tryParse(value);
                            if (age == null || age < 8 || age > 99) {
                              return 'Age must be between 8 and 99';
                            }
                            return null;
                          },
                        ),
                  Text('Weight (lbs)',
                      style: Theme.of(context).textTheme.headlineMedium),
                  isMobile()
                      ? NumberPicker(
                          value: onboardingController.weight.toInt(),
                          onChanged: (value) {
                            onboardingController.setAge(value);
                          },
                          axis: Axis.horizontal,
                          minValue: 40,
                          maxValue: 999,
                        )
                      : Row(
                          children: [
                            Text(
                                "${onboardingController.weight.toStringAsFixed(0)} lbs",
                                style: Theme.of(context).textTheme.bodyLarge),
                            Expanded(
                              child: Slider(
                                value: onboardingController.weight,
                                onChanged: (value) {
                                  onboardingController.setWeight(value);
                                },
                                min: 40,
                                max: 500,
                                divisions: 460,
                                label: onboardingController.weight
                                    .toStringAsFixed(0),
                              ),
                            ),
                          ],
                        ),
                  Text('Activity Level',
                      style: Theme.of(context).textTheme.headlineMedium),
                  DropdownButtonFormField<String>(
                    value: onboardingController.activityLevel,
                    items: [
                      const DropdownMenuItem(
                        value: 'low',
                        child: Text('Low'),
                      ),
                      const DropdownMenuItem(
                        value: 'moderate',
                        child: Text('Moderate'),
                      ),
                      const DropdownMenuItem(
                        value: 'active',
                        child: Text('Active'),
                      ),
                    ],
                    onChanged: (value) {
                      onboardingController.setActivityLevel(value!);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select your activity level';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      if (onboardingController.step1FormKey.currentState!
                          .validate()) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const UsernameView(),
                          ),
                        );
                      }
                    },
                    child: const Text('Next'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
