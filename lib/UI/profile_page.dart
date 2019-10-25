import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  final int userId;
  ProfilePage({@required this.userId});
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: Icon(Icons.message),
              onPressed: () {},
            ),
          ),
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {},
          ),
        ],
      ),
      body: Center(
        child: Text(widget.userId.toString()),
      ),
    );
  }
}
