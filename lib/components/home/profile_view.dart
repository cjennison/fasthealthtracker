import 'package:fasthealthcheck/models/user.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fasthealthcheck/services/user_service.dart';
import 'package:fasthealthcheck/services/wellness_service.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  bool isEditing = false;
  late int age;
  late double weight;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserService>(context, listen: false).currentUser;
    if (user != null) {
      age = user.age!;
      weight = user.weight!;
    } else {
      print("User is null");
    }
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
      userService.saveUser(
        User(
          username: currentUser.username,
          age: age,
          weight: weight,
          activityLevel: currentUser.activityLevel,
        ),
      );
    }

    setState(() {
      isEditing = false;
    });
  }

  void _handleLogout(BuildContext context) {
    Provider.of<UserService>(context, listen: false).logout();
    Provider.of<WellnessService>(context, listen: false).clearWellnessData();
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserService>(context).currentUser;

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
                  const Text('Weight (lbs):', style: TextStyle(fontSize: 18)),
                  Row(
                    children: [
                      Text('${weight.toStringAsFixed(1)} lbs',
                          style: const TextStyle(fontSize: 16)),
                      Expanded(
                        child: Slider(
                          value: weight,
                          min: 40,
                          max: 400,
                          divisions: 360,
                          label: weight.toStringAsFixed(1),
                          onChanged: (value) {
                            setState(() {
                              weight = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Age: ${user.age}',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Weight: ${user.weight} lbs',
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
          ],
        ),
      ),
    );
  }
}
