import 'package:fasthealthcheck/services/user_service.dart';
import 'package:fasthealthcheck/services/wellness_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StartupView extends StatefulWidget {
  const StartupView({super.key});

  @override
  State<StartupView> createState() => _StartupViewState();
}

class _StartupViewState extends State<StartupView> {
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initalizeApp();
  }

  Future<void> initalizeApp() async {
    print('Initializing app...');
    final userService = Provider.of<UserService>(context, listen: false);
    await userService.initializeUser();

    final wellnessService =
        Provider.of<WellnessService>(context, listen: false);
    await wellnessService.initializeWellnessData();

    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      isLoading = false;
    });

    if (userService.currentUser != null) {
      Navigator.pushReplacementNamed(context, '/app');
    } else {
      Navigator.pushReplacementNamed(context, '/splash');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: isLoading ? CircularProgressIndicator() : const Text('Lets go!'),
      ),
    );
  }
}