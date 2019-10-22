import 'package:flutter/material.dart';

class AccountRecovery extends StatefulWidget {
  @override
  _AccountRecoveryState createState() => _AccountRecoveryState();
}

class _AccountRecoveryState extends State<AccountRecovery> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Text('Password Recovery'),
      ),
    );
  }
}
