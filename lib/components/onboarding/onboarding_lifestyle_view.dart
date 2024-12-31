// onboarding_lifestyle_view.dart
import 'package:fasthealthcheck/models/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fasthealthcheck/services/user_service.dart';

class OnboardingLifestyleView extends StatefulWidget {
  const OnboardingLifestyleView({super.key, required this.newUser});
  final User newUser;

  @override
  State<OnboardingLifestyleView> createState() =>
      _OnboardingLifestyleViewState();
}

class _OnboardingLifestyleViewState extends State<OnboardingLifestyleView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int _age = 25;
  double _weight = 150.0;
  String _activityLevel = 'low';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tell us about yourself'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _age.toString(),
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _age = int.tryParse(value) ?? _age;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _weight.toString(),
                decoration: const InputDecoration(labelText: 'Weight (lbs)'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _weight = double.tryParse(value) ?? _weight;
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _activityLevel,
                items: const [
                  DropdownMenuItem(value: 'low', child: Text('Low')),
                  DropdownMenuItem(value: 'moderate', child: Text('Moderate')),
                  DropdownMenuItem(value: 'active', child: Text('Active')),
                ],
                onChanged: (value) {
                  setState(() {
                    _activityLevel = value!;
                  });
                },
                decoration: const InputDecoration(labelText: 'Activity Level'),
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
    );
  }

  void _submitDetails() {
    final userService = Provider.of<UserService>(context, listen: false);
    userService.saveUser(
      User(
        age: _age,
        weight: _weight,
        activityLevel: _activityLevel,
        username: widget.newUser.username,
      ),
    );
    Navigator.pushNamedAndRemoveUntil(context, '/app', (route) => false);
  }
}
