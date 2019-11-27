import 'dart:math';

import 'package:flutter/material.dart';
import 'package:free_chat/provider/base_provider.dart';
import 'package:free_chat/provider/entity/request_entity.dart';
import 'package:free_chat/provider/entity/provider_code.dart';
import 'package:free_chat/provider/entity/provider_entity.dart';
import 'package:free_chat/provider/request_provider.dart';

class RequestTest extends StatefulWidget {
  final username;
  RequestTest({this.username});
  @override
  _RequestTestState createState() => _RequestTestState();
}

class _RequestTestState extends State<RequestTest> {
  IProvider provider;
  bool inited = false;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  @override
  void initState() {
    super.initState();
    provider = RequestProvier(username: widget.username)
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
                      code: RequestProviderCode.queryAllRequest));
                  final result = await provider.provide();
                  scaffoldKey.currentState.showSnackBar(SnackBar(
                    content: Text('query all requests : $result'),
                  ));
                } else {
                  scaffoldKey.currentState.showSnackBar(SnackBar(
                    content: Text('Please init before.'),
                  ));
                }
              },
              child: Text('show all requests'),
            ),
            RaisedButton(
              onPressed: () async {
                final username = 'yue';
                if (inited) {
                  provider.setEntity(ProviderEntity(
                      code: RequestProviderCode.deleteRequest,
                      content: RequestEntity(
                        username: username,
                      )));
                  final result = await provider.provide();
                  scaffoldKey.currentState.showSnackBar(SnackBar(
                    content: Text('delete request result : $result'),
                  ));
                } else {
                  scaffoldKey.currentState.showSnackBar(SnackBar(
                    content: Text('Please init before.'),
                  ));
                }
              },
              child: Text('delete request'),
            ),
            RaisedButton(
              onPressed: () async {
                final username = 'yue';
                if (inited) {
                  provider.setEntity(ProviderEntity(
                      code: RequestProviderCode.updateRequest,
                      content: RequestEntity(
                        username: username,
                        overview:
                            Random.secure().nextDouble().toStringAsFixed(8),
                        timestamp: DateTime.now(),
                      )));
                  final result = await provider.provide();
                  scaffoldKey.currentState.showSnackBar(SnackBar(
                    content: Text('update request result : $result'),
                  ));
                } else {
                  scaffoldKey.currentState.showSnackBar(SnackBar(
                    content: Text('Please init before.'),
                  ));
                }
              },
              child: Text('update request'),
            ),
            RaisedButton(
              onPressed: () async {
                final username = 'yue';
                if (inited) {
                  provider.setEntity(ProviderEntity(
                      code: RequestProviderCode.queryRequest,
                      content: RequestEntity(
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
              child: Text('Query request'),
            ),
            RaisedButton(
              onPressed: () async {
                if (inited) {
                  provider.setEntity(ProviderEntity(
                      code: RequestProviderCode.addRequest,
                      content: RequestEntity(
                        username: 
                        Random.secure().nextDouble().toStringAsFixed(8),
                        timestamp: DateTime.now(),
                        overview: 'my love',
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
              child: Text('add request'),
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
