import 'dart:math';

import 'package:flutter/material.dart';
import 'package:free_chat/provider/base_provider.dart';
import 'package:free_chat/provider/entity/profile_entity.dart';
import 'package:free_chat/provider/entity/provider_code.dart';
import 'package:free_chat/provider/entity/provider_entity.dart';
import 'package:free_chat/provider/profile_provider.dart';
import 'package:free_chat/util/ui/profile_body_list_title.dart';

class ProfileTest extends StatefulWidget {
  final username;
  ProfileTest({this.username});
  @override
  _ProfileTestState createState() => _ProfileTestState();
}

class _ProfileTestState extends State<ProfileTest> {
  IProvider provider;
  bool inited = false;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();
  @override
  void initState() {
    super.initState();
    provider = ProfileProvider(username: widget.username)
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
                      code: ProfileProviderCode.queryAllProfile));
                  final result = await provider.provide();
                  scaffoldKey.currentState.showSnackBar(SnackBar(
                    content: Text('query all profiles : $result'),
                  ));
                } else {
                  scaffoldKey.currentState.showSnackBar(SnackBar(
                    content: Text('Please init before.'),
                  ));
                }
              },
              child: Text('show all profiles'),
            ),
            RaisedButton(
              onPressed: () async {
                final username = 'y';
                if (inited) {
                  provider.setEntity(ProviderEntity(
                      code: ProfileProviderCode.deleteProfile,
                      content: ProfileEntity(
                        username: username,
                      )));
                  final result = await provider.provide();
                  scaffoldKey.currentState.showSnackBar(SnackBar(
                    content: Text('delete profile result : $result'),
                  ));
                } else {
                  scaffoldKey.currentState.showSnackBar(SnackBar(
                    content: Text('Please init before.'),
                  ));
                }
              },
              child: Text('delete profile'),
            ),
            RaisedButton(
              onPressed: () async {
                final username = 'y';
                if (inited) {
                  provider.setEntity(
                    ProviderEntity(
                      code: ProfileProviderCode.updateProfile,
                      content: ProfileEntity(
                        username: username,
                        labels: ['Design','Pattern','Refactor','Code'],
                        lsnCount: List.generate(
                            3, (index) => Random.secure().nextInt(300)),
                        infos: List.generate(
                            3, (index) => ProfileBodyListTitle.index(index)),
                      ),
                    ),
                  );
                  final result = await provider.provide();
                  scaffoldKey.currentState.showSnackBar(SnackBar(
                    content: Text('update profile result : $result'),
                  ));
                } else {
                  scaffoldKey.currentState.showSnackBar(SnackBar(
                    content: Text('Please init before.'),
                  ));
                }
              },
              child: Text('update profile'),
            ),
            RaisedButton(
              onPressed: () async {
                final username = 'y';
                if (inited) {
                  provider.setEntity(ProviderEntity(
                      code: ProfileProviderCode.queryProfile,
                      content: ProfileEntity(
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
              child: Text('Query profile'),
            ),
            RaisedButton(
              onPressed: () async {
                if (inited) {
                  provider.setEntity(
                    ProviderEntity(
                      code: ProfileProviderCode.addProfile,
                      content: ProfileEntity(
                        username: 'y',
                        labels: List.generate(
                            4,
                            (index) => Random.secure()
                                .nextDouble()
                                .toStringAsFixed(4)
                                .toString()),
                        lsnCount: List.generate(
                            3, (index) => Random.secure().nextInt(300)),
                        infos: List.generate(
                            3, (index) => ProfileBodyListTitle.index(index)),
                      ),
                    ),
                  );
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
              child: Text('add profile'),
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
