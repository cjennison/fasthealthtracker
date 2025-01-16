import 'package:flutter/material.dart';

void showSnackbar(
  BuildContext context,
  String message,
  SnackbarType type,
) {
  final snackbar = SnackBar(
    content: Text(message),
    backgroundColor: type == SnackbarType.error
        ? Colors.red
        : type == SnackbarType.success
            ? Colors.green
            : Colors.blue,
  );

  ScaffoldMessenger.of(context).showSnackBar(snackbar);
}

class SnackbarType {
  static const error = SnackbarType('error');
  static const success = SnackbarType('success');
  static const info = SnackbarType('info');

  final String value;

  const SnackbarType(this.value);
}
