import 'package:flutter/material.dart';

class SuccessSnackBar {
  static newInstance({final String message}) {
    return SnackBar(
      content: Text(
        message,
        style: TextStyle(color: Colors.green),
      ),
      backgroundColor: Colors.grey[100],
    );
  }

}
