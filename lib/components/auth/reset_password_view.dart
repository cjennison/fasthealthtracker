import 'package:fasthealthcheck/services/api/api_user_service.dart';
import 'package:fasthealthcheck/services/service_locator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ResetPasswordView extends StatefulWidget {
  const ResetPasswordView({super.key});

  @override
  State<ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<ResetPasswordView> {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController tokenController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final String email = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(title: const Text('Reset Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              Text(
                'A reset code has been sent to $email. Please check your email and enter the code below.',
                style: const TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: tokenController,
                decoration: const InputDecoration(
                  labelText: 'Reset Token',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the token.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password.';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value != newPasswordController.text) {
                    return 'Passwords do not match.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isSubmitting
                    ? null
                    : () async {
                        if (formKey.currentState!.validate()) {
                          setState(() => isSubmitting = true);
                          try {
                            final ApiUserService apiUserService =
                                getIt<ApiUserService>();
                            await apiUserService.submitForgottenPasswordForm({
                              'email': email,
                              'token': tokenController.text,
                              'password': newPasswordController.text,
                              'confirmPassword': confirmPasswordController.text,
                            });
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/login',
                              (route) => false,
                              arguments: {
                                'banner':
                                    'Please log in with your new password',
                              },
                            );
                          } finally {
                            setState(() => isSubmitting = false);
                          }
                        }
                      },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
