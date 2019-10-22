import 'package:flutter/material.dart';

class FailtureSnackBar {
  static newInstance({final String message}) {
    return SnackBar(
      content: Text(
        message,
        style: TextStyle(color: Colors.red),
      ),
      backgroundColor: Colors.grey[100],
    );
  }
}
