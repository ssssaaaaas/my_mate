import 'package:flutter/material.dart';

void showCustomSnackbar(BuildContext context, String message) {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  double snackbarHeight = message.contains('e') ? 62 : 25;
  final snackbar = SnackBar(
    content: Container(
      height: snackbarHeight,
      width: double.infinity,
      child: Center(
        child: Text(
          message,
          style: const TextStyle(color: Colors.white, fontSize: 15),
        ),
      ),
    ),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    elevation: 0,
    duration: const Duration(seconds: 1),
  );
  scaffoldMessenger.showSnackBar(snackbar);
}
