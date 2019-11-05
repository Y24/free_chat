import 'dart:math';

import 'package:flutter/material.dart';
import 'package:free_chat/entity/enums.dart';
import 'package:free_chat/provider/base_provider.dart';
import 'package:free_chat/provider/entity/history_entity.dart';
import 'package:free_chat/provider/entity/provider_code.dart';
import 'package:free_chat/provider/entity/provider_entity.dart';
import 'package:free_chat/provider/history_provider.dart';
import 'package:sqflite/sqflite.dart';

class HistoryTest extends StatefulWidget {
  final username;
  HistoryTest({this.username});
  @override
  _HistoryTestState createState() => _HistoryTestState();
}

class _HistoryTestState extends State<HistoryTest> {
  IProvider provider;
  bool inited = false;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  @override
  void initState() {
    super.initState();
    provider = HistoryProvider(username: widget.username)
      ..init().then((result) {
        print('provider init result: $result');
        if (result) {
          setState(() {
            inited = true;
          });
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(inited ? 'inited' : 'uninited'),
            RaisedButton(
              onPressed: () async {
                if (inited) {
                  provider.setEntity(ProviderEntity(
                      code: HistoryProviderCode.queryAllHistory));
                  final result = await provider.provide();
                  scaffoldKey.currentState.showSnackBar(SnackBar(
                    content: Text('query all historys : $result'),
                  ));
                } else {
                  scaffoldKey.currentState.showSnackBar(SnackBar(
                    content: Text('Please init before.'),
                  ));
                }
              },
              child: Text('show all historys'),
            ),
            RaisedButton(
              onPressed: () async {
                final username = 'yue';
                if (inited) {
                  provider.setEntity(ProviderEntity(
                      code: HistoryProviderCode.deleteHistory,
                      content: HistoryEntity(
                        historyId: 1,
                        username: username,
                      )));
                  final result = await provider.provide();
                  scaffoldKey.currentState.showSnackBar(SnackBar(
                    content: Text('delete history result : $result'),
                  ));
                } else {
                  scaffoldKey.currentState.showSnackBar(SnackBar(
                    content: Text('Please init before.'),
                  ));
                }
              },
              child: Text('delete history'),
            ),
            RaisedButton(
              onPressed: () async {
                final username = 'yue';
                if (inited) {
                  provider.setEntity(ProviderEntity(
                      code: HistoryProviderCode.updateHistory,
                      content: HistoryEntity(
                        historyId: 100,
                        username: username,
                        content: Random.secure().nextInt(5000).toString(),
                        isOthers: Random.secure().nextBool(),
                        timestamp: DateTime.now(),
                        status: MessageSendStatus.processing,
                      )));
                  final result = await provider.provide();
                  scaffoldKey.currentState.showSnackBar(SnackBar(
                    content: Text('update history result : $result'),
                  ));
                } else {
                  scaffoldKey.currentState.showSnackBar(SnackBar(
                    content: Text('Please init before.'),
                  ));
                }
              },
              child: Text('update history'),
            ),
            RaisedButton(
              onPressed: () async {
                final username = 'yue';
                if (inited) {
                  provider.setEntity(ProviderEntity(
                      code: HistoryProviderCode.queryHistory,
                      content: HistoryEntity(
                        username: username,
                      )));
                  final result = await provider.provide();
                  scaffoldKey.currentState.showSnackBar(SnackBar(
                    content: Text('query username: $username,result: $result'),
                  ));
                } else {
                  scaffoldKey.currentState.showSnackBar(SnackBar(
                    content: Text('Please init before.'),
                  ));
                }
              },
              child: Text('Query history'),
            ),
            RaisedButton(
              onPressed: () async {
                if (inited) {
                  provider.setEntity(ProviderEntity(
                      code: HistoryProviderCode.addHistory,
                      content: HistoryEntity(
                        historyId: Random.secure().nextInt(300),
                        username: 'yue',
                        content: Random.secure().nextInt(5000).toString(),
                        isOthers: Random.secure().nextBool(),
                        timestamp: DateTime.now(),
                        status: MessageSendStatus.processing,
                      )));
                  final result = await provider.provide();
                  scaffoldKey.currentState.showSnackBar(SnackBar(
                    content: Text('add result: $result'),
                  ));
                } else {
                  scaffoldKey.currentState.showSnackBar(SnackBar(
                    content: Text('Please init before.'),
                  ));
                }
              },
              child: Text('add history'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    provider.close();
    super.dispose();
  }
}
