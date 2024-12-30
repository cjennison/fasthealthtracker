import 'package:fasthealthcheck/models/user.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserSummaryWidget extends StatelessWidget {
  final User user;

  const UserSummaryWidget({
    super.key,
    required this.user,
  });

  final int streak = 7;

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat.yMMMMd().format(DateTime.now());
    User currentUser = user;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/profile');
              },
              child: Row(
                children: [
                  currentUser.photoUrl == null
                      ? const CircleAvatar(
                          radius: 24,
                          child: Icon(Icons.person),
                        )
                      : CircleAvatar(
                          backgroundImage:
                              NetworkImage(currentUser.photoUrl ?? ''),
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
            Row(
              children: [
                Column(
                  children: [
                    const Text('Streak',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('$streak days'),
                  ],
                ),
                SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.list),
                  onPressed: () {
                    Navigator.pushNamed(context, '/log');
                  },
                ),
              ],
            ),
          ],
        ),
        Text(
          formattedDate,
        ),
      ],
    );
  }
}
