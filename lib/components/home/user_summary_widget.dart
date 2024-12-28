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
    var photoUrl = null;
    String formattedDate = DateFormat.yMMMMd().format(DateTime.now());

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                photoUrl == null
                    ? const CircleAvatar(
                        radius: 24,
                        child: Icon(Icons.person),
                      )
                    : CircleAvatar(
                        backgroundImage: NetworkImage(photoUrl),
                        radius: 24,
                      ),
                const SizedBox(width: 10),
                Text(
                  user.username,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
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
