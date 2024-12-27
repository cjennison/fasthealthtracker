import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:fasthealthcheck/components/onboarding/onboarding_controller.dart';

class UsernameView extends StatelessWidget {
  const UsernameView({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to changes from the controller
    final onboardingController = Provider.of<OnboardingController>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose a username'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: onboardingController.step2FormKey,
              child: ListView(
                children: [
                  Text('Username',
                      style: Theme.of(context).textTheme.headlineMedium),
                  TextFormField(
                      initialValue: onboardingController.username,
                      decoration: InputDecoration(
                        hintText: 'This can be changed at any time',
                      ),
                      onChanged: (value) {
                        onboardingController.setUsername(value);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a username';
                        }
                        return null;
                      }),
                  ElevatedButton(
                    onPressed: () {
                      onboardingController.submitForm(context);
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
