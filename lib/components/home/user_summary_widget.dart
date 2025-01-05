import 'package:fasthealthcheck/models/user.dart';
import 'package:fasthealthcheck/services/wellness_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class UserSummaryWidget extends StatelessWidget {
  final User user;

  const UserSummaryWidget({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    final wellnessService = Provider.of<WellnessService>(context);

    String formattedDate =
        DateFormat.yMMMMd().format(wellnessService.selectedDate);
    User currentUser = user;
    int streak = wellnessService.currentStreak;
    DateTime today = wellnessService.today;

    bool isToday = wellnessService.selectedDate.isAtSameMomentAs(today);

    void onSwitchDate(bool isNextDay) {
      wellnessService.selectedDate = isNextDay
          ? wellnessService.selectedDate.add(const Duration(days: 1))
          : wellnessService.selectedDate.subtract(const Duration(days: 1));
      wellnessService.refreshWellnessData();
    }

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
                    Text('$streak day${streak > 1 ? 's' : ''}'),
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
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                onSwitchDate(false);
              },
            ),
            Text(isToday ? "Today, $formattedDate" : formattedDate),
            IconButton(
              icon: Icon(Icons.arrow_forward,
                  color: isToday ? Colors.grey : null),
              onPressed: () {
                if (isToday) return;
                onSwitchDate(true);
              },
            ),
          ],
        ),
      ],
    );
  }
}
