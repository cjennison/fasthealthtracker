import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fasthealthcheck/services/user_service.dart';
import 'package:fasthealthcheck/services/wellness_service.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  void _onLogout(BuildContext context) {
    Provider.of<UserService>(context, listen: false).logout();
    Provider.of<WellnessService>(context, listen: false).clearWellnessData();
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserService>(context).currentUser;

    if (user == null) {
      return const SizedBox.shrink();
    }

    var photoUrl = null; // = user.photoUrl;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Row(
                children: [
                  photoUrl == null
                      ? const CircleAvatar(
                          radius: 24,
                          child: Icon(Icons.person),
                        )
                      : CircleAvatar(
                          backgroundImage: NetworkImage(photoUrl!),
                          radius: 24,
                        ),
                  const SizedBox(width: 10),
                  Text(
                    user.username,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Age: ${user.age}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Weight: ${user.weight} lbs',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => _onLogout(context),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
