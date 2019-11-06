import 'dart:math';

import 'package:flutter/material.dart';
import 'package:free_chat/UI/chat_page.dart';
import 'package:free_chat/entity/enums.dart';
import 'package:free_chat/provider/base_provider.dart';
import 'package:free_chat/provider/entity/profile_entity.dart';
import 'package:free_chat/provider/entity/provider_code.dart';
import 'package:free_chat/provider/entity/provider_entity.dart';
import 'package:free_chat/provider/profile_provider.dart';
import 'package:free_chat/util/ui/custom_style.dart';
import 'package:free_chat/util/ui/page_tansitions/slide_route.dart';
import 'package:provider/provider.dart';

class ProfilePage extends StatelessWidget {
  final String username;
  final String hostUsername;
  ProfilePage({@required this.hostUsername, @required this.username});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                print('settings');
              },
            ),
          ),
        ],
      ),
      body: _ProfileUI(hostUsername: hostUsername, username: username),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.message),
        onPressed: () async {
          Navigator.of(context).push(SlideRightRoute(
              page: ChatPage(
            from: hostUsername,
            to: username,
          )));
        },
      ),
    );
  }
}

class _ProfileUI extends StatefulWidget {
  final String hostUsername;
  final String username;
  _ProfileUI({@required this.hostUsername, @required this.username});
  @override
  _ProfileUIState createState() => _ProfileUIState();
}

const _strPool = {
  'likes': {
    Language.en: 'Likes',
    Language.zh: '点赞',
  },
  'shares': {
    Language.en: 'Shares',
    Language.zh: '动态',
  },
  'notes': {
    Language.en: 'Notes',
    Language.zh: '留言',
  },
};

class _ProfileUIState extends State<_ProfileUI> {
  bool fetched = false;
  bool isFetching = false;
  IProvider provider;
  ProfileEntity _profileEntity;
  Map<String, bool> chips = {};
  @override
  void initState() {
    super.initState();
    fetched = false;
    isFetching = true;
    provider = ProfileProvider(username: widget.hostUsername)
      ..init().then((result) async {
        print('provider init result: $result');
        if (result) {
          provider.setEntity(ProviderEntity(
              code: ProfileProviderCode.queryProfile,
              content: ProfileEntity(username: widget.username)));
          _profileEntity = await provider.provide();
          setState(() {
            fetched = true;
            isFetching = false;
          });
        }
      });
  }

  @override
  void dispose() {
    provider?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Column(
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(14),
                    bottomRight: Radius.circular(14),
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 5,
              child: Container(
                color: Colors.grey[200],
              ),
            ),
          ],
        ),
        Column(
          children: <Widget>[
            _buildHeader(context),
            Expanded(child: _buildBody(context)),
          ],
        ),
      ],
    );
  }

  Container _buildBody(BuildContext context) {
    if (!fetched) return Container();
    return Container(
      child: Material(
        elevation: 5.0,
        color: Colors.white,
        child: ListView.separated(
          separatorBuilder: (context, index) => const Divider(
            indent: 20,
            endIndent: 20,
          ),
          itemCount: _profileEntity.infos.length,
          itemBuilder: (BuildContext context, int index) =>
              _profileEntity.infos[index].toListItem(context),
        ),
      ),
    );
  }

  Container _buildHeader(BuildContext context) {
    final language = Provider.of<LanguageState>(context).language;
    if (!fetched) return Container();
    print('_profileEntity.labels:${_profileEntity.labels}');
    _profileEntity.labels.forEach((s) {
      chips[s] = Random.secure().nextBool();
    });
    return Container(
      margin: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 2 / 7 - 170),
      height: 240.0,
      child: Stack(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.only(
                top: 40.0, left: 40.0, right: 40.0, bottom: 10.0),
            child: Material(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              elevation: 5.0,
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  const SizedBox(
                    height: 50.0,
                  ),
                  Text(
                    widget.username.toString(),
                    style: Theme.of(context).textTheme.title,
                  ),
                  const SizedBox(
                    height: 5.0,
                  ),
                  ChipTheme(
                    data: ChipThemeData(
                      backgroundColor: Colors.white10,
                      disabledColor: Colors.white10,
                      selectedColor: Colors.black,
                      secondarySelectedColor: Colors.blue,
                      labelPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      padding: EdgeInsets.all(0),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0)),
                      labelStyle: TextStyle(color: Colors.black),
                      secondaryLabelStyle: TextStyle(color: Colors.white),
                      brightness: Brightness.light,
                      elevation: 4,
                      shadowColor: Colors.blue,
                    ),
                    child: Wrap(
                      spacing: 8.0,
                      runSpacing: 10.0,
                      children: _profileEntity.labels
                          .map<Widget>((text) => ChoiceChip(
                                label: Text(text),
                                selected: chips[text],
                                onSelected: (selected) {
                                  setState(() {
                                    chips[text] = selected;
                                  });
                                },
                              ))
                          .toList(),
                    ),
                  ),
                  Container(
                    height: 40.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        for (int i = 0; i < _profileEntity.lsnCount.length; i++)
                          Expanded(
                            child: ListTile(
                              onTap: () {
                                print('302');
                              },
                              title: Text(
                                _strPool.values.toList()[i][language],
                                textAlign: TextAlign.center,
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                  _profileEntity.lsnCount[i].toString(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 12.0)),
                            ),
                          )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Material(
                  elevation: 5.0,
                  shape: CircleBorder(),
                  child: CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('res/images/logo.png'),
                  )),
            ],
          ),
        ],
      ),
    );
  }
}
