
import 'package:flutter/material.dart';
import 'package:free_chat/provider/base_provider.dart';
import 'package:free_chat/provider/entity/friend_entity.dart';
import 'package:free_chat/provider/entity/provider_code.dart';
import 'package:free_chat/provider/entity/provider_entity.dart';
import 'package:free_chat/provider/friend_provider.dart';

class FriendTest extends StatefulWidget {
  final username;
  FriendTest({this.username});
  @override
  _FriendTestState createState() => _FriendTestState();
}

class _FriendTestState extends State<FriendTest> {
  IProvider provider;
  bool inited = false;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  @override
  void initState() {
    super.initState();
    provider = FriendProvier(username: widget.username)
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
                      ProviderEntity(code: FriendProviderCode.queryAllFriend));
                  final result = await provider.provide();
                  scaffoldKey.currentState.showSnackBar(SnackBar(
                    content: Text('query all friends : $result'),
                  ));
                } else {
                  scaffoldKey.currentState.showSnackBar(SnackBar(
                    content: Text('Please init before.'),
                  ));
                }
              },
              child: Text('show all friends'),
            ),
            RaisedButton(
              onPressed: () async {
                final username = 'yue';
                if (inited) {
                  provider.setEntity(ProviderEntity(
                      code: FriendProviderCode.deleteFriend,
                      content: FriendEntity(
                        username: username,
                      )));
                  final result = await provider.provide();
                  scaffoldKey.currentState.showSnackBar(SnackBar(
                    content: Text('delete friend result : $result'),
                  ));
                } else {
                  scaffoldKey.currentState.showSnackBar(SnackBar(
                    content: Text('Please init before.'),
                  ));
                }
              },
              child: Text('delete friend'),
            ),
            RaisedButton(
              onPressed: () async {
                final username = 'yue';
                if (inited) {
                  provider.setEntity(ProviderEntity(
                      code: FriendProviderCode.updateFriend,
                      content: FriendEntity(
                        username: username,
                        overview:
                            'Life is simple.',
                        alias: 'Y_Y',
                      )));
                  final result = await provider.provide();
                  scaffoldKey.currentState.showSnackBar(SnackBar(
                    content: Text('update friend result : $result'),
                  ));
                } else {
                  scaffoldKey.currentState.showSnackBar(SnackBar(
                    content: Text('Please init before.'),
                  ));
                }
              },
              child: Text('update friend'),
            ),
            RaisedButton(
              onPressed: () async {
                final username = 'y';
                if (inited) {
                  provider.setEntity(ProviderEntity(
                      code: FriendProviderCode.queryFriend,
                      content: FriendEntity(
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
              child: Text('Query friend'),
            ),
            RaisedButton(
              onPressed: () async {
                if (inited) {
                  provider.setEntity(ProviderEntity(
                      code: FriendProviderCode.addFriend,
                      content: FriendEntity(
                        username:'yue',
                        alias: 'Intresting',
                        overview: 'Nothing special.',
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
              child: Text('add friend'),
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
