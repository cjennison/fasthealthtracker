import 'package:fasthealthcheck/services/api/api_user_service.dart';
import 'package:fasthealthcheck/services/service_locator.dart';
import 'package:flutter/material.dart';

class ForgottenPasswordView extends StatelessWidget {
  const ForgottenPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController emailController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Forgot Password')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Enter your email to reset your password.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an email.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    final ApiUserService apiUserService =
                        getIt<ApiUserService>();

                    await apiUserService.sendForgottenPasswordRequest(
                      emailController.text,
                    );

                    Navigator.pushNamed(context, '/reset-password',
                        arguments: emailController.text);
                  }
                },
                child: const Text('Reset Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
