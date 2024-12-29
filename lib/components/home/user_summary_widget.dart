import 'package:fasthealthcheck/models/user.dart';
import 'package:fasthealthcheck/services/user_service.dart';
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

  final int streak = 7;

  void _showUserOverlay(BuildContext context, User user, Offset position) {
    var photoUrl = null; // = user.photoUrl;
    OverlayState overlayState = Overlay.of(context);
    late OverlayEntry overlayEntry;

    void onLogout() {
      UserService().logout();
      Provider.of<WellnessService>(context, listen: false).clearWellnessData();
      Navigator.pushReplacementNamed(context, '/onboarding');
      overlayEntry.remove();
    }

    overlayEntry = OverlayEntry(
      builder: (context) {
        return Material(
          child: Positioned(
            left: position.dx - 40,
            top: position.dy - 40,
            child: GestureDetector(
              onTap: () {},
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height - 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(32),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 16,
                      color: Colors.black,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              overlayEntry.remove();
                            },
                            child: photoUrl == null
                                ? const CircleAvatar(
                                    radius: 24,
                                    child: Icon(Icons.person),
                                  )
                                : CircleAvatar(
                                    backgroundImage: NetworkImage(photoUrl),
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
                      const SizedBox(height: 10),
                      Text(
                        'Age: ${user.age}',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Weight: ${user.weight}lbs',
                        style: const TextStyle(fontSize: 18),
                      ),
                      const SizedBox(height: 30),
                      Center(
                        child: Row(
                          children: [
                            ElevatedButton(
                              onPressed: onLogout,
                              child: const Text('Logout'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                overlayEntry.remove();
                              },
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    overlayState.insert(overlayEntry);
  }

  @override
  Widget build(BuildContext context) {
    var photoUrl = null;
    String formattedDate = DateFormat.yMMMMd().format(DateTime.now());

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                final RenderBox renderBox =
                    context.findRenderObject() as RenderBox;
                final position = renderBox.localToGlobal(Offset.zero);
                _showUserOverlay(context, user, position);
              },
              child: Row(
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
