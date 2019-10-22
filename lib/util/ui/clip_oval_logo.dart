import 'package:flutter/material.dart';

class ClipOvalLogo extends StatelessWidget {
  const ClipOvalLogo({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: ClipOval(
        child: Material(
          child: Image.asset('res/images/logo.png'),
          elevation: 24.0,
        ),
      ),
    );
  }
}
