import 'package:fasthealthcheck/components/utils/show_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fasthealthcheck/services/user_service.dart';

class VerificationView extends StatefulWidget {
  const VerificationView({super.key});

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
      showSnackbar(context, 'Verification email sent successfully!',
          SnackbarType.success);
    } catch (e) {
      showSnackbar(
          context, 'Failed to send verification email: $e', SnackbarType.error);
    }
  }

  void _submitVerificationCode(String userId, String email) async {
    final userService = Provider.of<UserService>(context, listen: false);
    final code = _codeController.text.trim();
    if (code.length != 6) {
      showSnackbar(
          context, 'Code must be 6 characters long', SnackbarType.info);

      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      await userService.verifyUser(userId, email, code);
      showSnackbar(context, 'Email verified successfully!', SnackbarType.info);

      Navigator.pop(context);
    } catch (e) {
      showSnackbar(context, 'Verification failed: $e', SnackbarType.error);
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
