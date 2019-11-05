import 'package:flutter/material.dart';
import 'package:free_chat/entity/enums.dart';

class ProfilePage extends StatelessWidget {
  final String username;
  ProfilePage({this.username});
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
      body: _ProfileUI(username: username),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.message),
        onPressed: () {},
      ),
    );
  }
}

class _ProfileUI extends StatefulWidget {
  final String username;
  _ProfileUI({this.username});
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
  List<String> labels;
  Map<String, String> lsnCount;
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
    return Container(
      child: Material(
        elevation: 5.0,
        color: Colors.white,
        child: ListView.separated(
          separatorBuilder: (context, index) => const Divider(
            indent: 20,
            endIndent: 20,
          ),
          itemCount: 10,
          itemBuilder: (BuildContext context, int index) => ListTile(
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Icon(
                Icons.email,
                color: Colors.blue,
              ),
            ),
            title: Padding(
              padding: const EdgeInsets.only(
                top: 8.0,
                left: 8.0,
              ),
              child: Text('Email'),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(
                top: 8.0,
                left: 8.0,
              ),
              child: Text('githuby24@gmail.com'),
            ),
          ),
        ),
      ),
    );
  }

  Container _buildHeader(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
          top: MediaQuery.of(context).size.height * 2 / 7 - 170),
      height: 240.0,
      child: Stack(
        children: <Widget>[
          Container(
            padding: EdgeInsets.only(
                top: 40.0, left: 40.0, right: 40.0, bottom: 10.0),
            child: Material(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0)),
              elevation: 5.0,
              color: Colors.white,
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 50.0,
                  ),
                  Text(
                    widget.username.toString(),
                    style: Theme.of(context).textTheme.title,
                  ),
                  SizedBox(
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
                      children: <Widget>[
                        ChoiceChip(
                          label: Text('Java'),
                          selected: false,
                          onSelected: (selected) {},
                        ),
                        ChoiceChip(
                          label: Text('C++'),
                          selected: false,
                          onSelected: (selected) {},
                        ),
                        ChoiceChip(
                          label: Text('Flutter'),
                          selected: true,
                          onSelected: (selected) {},
                        ),
                        ChoiceChip(
                          label: Text('JS'),
                          selected: false,
                          onSelected: (selected) {},
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 40.0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: ListTile(
                            onTap: () {
                              print('302');
                            },
                            title: Text(
                              "Likes",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text("302".toUpperCase(),
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12.0)),
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            onTap: () {},
                            title: Text(
                              "Shares",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text("10.3K".toUpperCase(),
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12.0)),
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            onTap: () {},
                            title: Text(
                              "Notes",
                              textAlign: TextAlign.center,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text("120".toUpperCase(),
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 12.0)),
                          ),
                        ),
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
