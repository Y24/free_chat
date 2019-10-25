import 'package:flutter/material.dart';

class DefaultPadding extends StatelessWidget {
  final Widget child;
  DefaultPadding({this.child});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: child,
    );
  }
}
