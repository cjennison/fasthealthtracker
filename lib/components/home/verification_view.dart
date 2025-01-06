import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fasthealthcheck/services/user_service.dart';

class VerificationView extends StatefulWidget {
  const VerificationView({Key? key}) : super(key: key);

  @override
  _VerificationViewState createState() => _VerificationViewState();
}

class _VerificationViewState extends State<VerificationView> {
  bool isCodeInputVisible = false;
  final TextEditingController _codeController = TextEditingController();
  bool isSubmitting = false;

  void _sendVerificationEmail(String email) async {
    final userService = Provider.of<UserService>(context, listen: false);
    try {
      userService.sendVerificationEmail(email); // Operation is async
      setState(() {
        isCodeInputVisible = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification email sent successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send verification email: $e')),
      );
    }
  }

  void _submitVerificationCode(String userId, String email) async {
    final userService = Provider.of<UserService>(context, listen: false);
    final code = _codeController.text.trim();
    if (code.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Code must be 6 characters long')),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      await userService.verifyUser(userId, email, code);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Email verified successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Verification failed: $e')),
      );
    } finally {
      setState(() {
        isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserService>(context, listen: false).currentUser!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
          onPressed: () => _sendVerificationEmail(user.email),
          child: const Text('Send Verification Email'),
        ),
        if (isCodeInputVisible)
          Column(
            children: [
              const SizedBox(height: 10),
              TextField(
                controller: _codeController,
                decoration: const InputDecoration(
                  labelText: 'Enter Verification Code',
                ),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: isSubmitting
                    ? null
                    : () => _submitVerificationCode(user.id, user.email),
                child: const Text('Submit Code'),
              ),
            ],
          ),
      ],
    );
  }
}
