import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:free_chat/entity/backend/sql_connection_settings.dart';
import 'package:mysql1/mysql1.dart';

class SQLTestPage extends StatefulWidget {
  @override
  _SQLTestPageState createState() => _SQLTestPageState();
}

class _SQLTestPageState extends State<SQLTestPage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              child: Text('Create table'),
              onPressed: () async {
                print('start ');
                var settings = SqlConnectionSettings.instance();
                MySqlConnection conn;
                try {
                  conn = await MySqlConnection.connect(settings);
                } on SocketException {} on TimeoutException {} catch (e) {}
                print(conn.toString());
               // await Account.createUserTable(connection: conn);
              },
            )
          ],
        ),
      ),
    );
  }
}
