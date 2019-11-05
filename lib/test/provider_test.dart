import 'package:flutter/material.dart';
import 'package:free_chat/entity/enums.dart';
import 'package:free_chat/provider/account_provider.dart';
import 'package:free_chat/provider/base_provider.dart';
import 'package:free_chat/provider/entity/account_entity.dart';
import 'package:free_chat/provider/entity/provider_code.dart';
import 'package:free_chat/provider/entity/provider_entity.dart';

class ProviderTest extends StatefulWidget {
  @override
  _ProviderTestState createState() => _ProviderTestState();
}

class _ProviderTestState extends State<ProviderTest> {
  IProvider provider;
  bool inited = false;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  @override
  void initState() {
    super.initState();
    provider = AccountProvider()
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
                  provider.setEntity(
                      ProviderEntity(code: AccountProviderCode.queryLogined));
                  final result = await provider.provide();
                  scaffoldKey.currentState.showSnackBar(SnackBar(
                    content: Text('logined : $result'),
                  ));
                } else {
                  scaffoldKey.currentState.showSnackBar(SnackBar(
                    content: Text('Please init before.'),
                  ));
                }
              },
              child: Text('show logined'),
            ),
            RaisedButton(
              onPressed: () async {
                final username = 'yue';
                if (inited) {
                  provider.setEntity(ProviderEntity(
                      code: AccountProviderCode.deleteHistory,
                      content: AccountEntity(
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
                if (inited) {
                  provider.setEntity(
                      ProviderEntity(code: AccountProviderCode.queryAllHistory));
                  final result = await provider.provide();
                  scaffoldKey.currentState.showSnackBar(SnackBar(
                    content: Text('all history : $result'),
                  ));
                } else {
                  scaffoldKey.currentState.showSnackBar(SnackBar(
                    content: Text('Please init before.'),
                  ));
                }
              },
              child: Text('show all history'),
            ),
            RaisedButton(
              onPressed: () async {
                final username = 'yue';
                if (inited) {
                  provider.setEntity(ProviderEntity(
                      code: AccountProviderCode.queryHistory,
                      content: AccountEntity(
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
                  provider.setEntity(
                      ProviderEntity(code: AccountProviderCode.logout));
                  final result = await provider.provide();
                  scaffoldKey.currentState.showSnackBar(SnackBar(
                    content: Text('logout result: $result'),
                  ));
                } else {
                  scaffoldKey.currentState.showSnackBar(SnackBar(
                    content: Text('Please init before.'),
                  ));
                }
              },
              child: Text('Logout'),
            ),
            RaisedButton(
              onPressed: () async {
                if (inited) {
                  provider.setEntity(ProviderEntity(
                      code: AccountProviderCode.login,
                      content: AccountEntity(
                        username: 'yue',
                        password: 'cui',
                        role: Role.user,
                        loginStatus: true,
                        lastLoginTimestamp: DateTime.now(),
                        lastLogoutTimestamp: DateTime.now(),
                      )));
                  final result = await provider.provide();
                  scaffoldKey.currentState.showSnackBar(SnackBar(
                    content: Text('login result: $result'),
                  ));
                } else {
                  scaffoldKey.currentState.showSnackBar(SnackBar(
                    content: Text('Please init before.'),
                  ));
                }
              },
              child: Text('login'),
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
