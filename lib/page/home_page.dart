import 'package:flutter/material.dart';
import 'package:free_chat/page/home_account_page.dart';
import 'package:free_chat/page/home_messages_page.dart';
import 'package:free_chat/configuration/configuration.dart';
import 'package:free_chat/util/function_pool.dart';
import 'package:free_chat/util/ui/custom_style.dart';
import 'package:provider/provider.dart';

import 'home_contacts_page.dart';

class HomePage extends StatelessWidget {
  final username;
  HomePage({this.username});
  @override
  Widget build(BuildContext context) {
    final languageState = Provider.of<LanguageState>(context);
    final customThemeDataState = Provider.of<CustomThemeDataState>(context);
    String appTitle = Configuration.appName[languageState.language];
    return MaterialApp(
      title: appTitle,
      theme: customThemeDataState.themeData,
      home: Homepage(username: username),
    );
  }
}

class Homepage extends StatefulWidget {
  final GlobalKey<ScaffoldState> globalKey = GlobalKey();
  final username;
  Homepage({this.username});
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  int _currentTabIndex = 0;
  List list = new List();
  int x = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final languageState = Provider.of<LanguageState>(context);

    /// TODO: custom theme data
    // final customThemeDataState = Provider.of<CustomThemeDataState>(context);
    final _kTabPages = <Widget>[
      HomeMessagesPage(
        username: widget.username,
        scaffoldKey: widget.globalKey,
      ),
      HomeContactsPage(
        username: widget.username,
        scaffoldKey: widget.globalKey,
      ),
      HomeAccountPage(
        username: widget.username,
        scaffoldKey: widget.globalKey,
      ),
    ];
    final _kBottmonNavBarItems = <BottomNavigationBarItem>[
      BottomNavigationBarItem(
        icon: Icon(Icons.message),
        title: Text(FunctionPool.getStringRes(
            key: 'messageStr', language: languageState.language)),
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.group),
        title: Text(FunctionPool.getStringRes(
            key: 'contactsStr', language: languageState.language)),
      ),
      BottomNavigationBarItem(
        icon: Icon(Icons.account_box),
        title: Text(FunctionPool.getStringRes(
            key: 'accountStr', language: languageState.language)),
      ),
    ];
    assert(_kTabPages.length == _kBottmonNavBarItems.length);
    final bottomNavBar = BottomNavigationBar(
      items: _kBottmonNavBarItems,
      currentIndex: _currentTabIndex,
      type: BottomNavigationBarType.fixed,
      onTap: (int index) {
        setState(() {
          _currentTabIndex = index;
        });
      },
    );
    return Scaffold(
      key: widget.globalKey,
      appBar: _buildAppBar(),
      body: IndexedStack(
        index: _currentTabIndex,
        children: _kTabPages,
      ),
      bottomNavigationBar: bottomNavBar,
    );
  }

  AppBar _buildAppBar() {
    switch (_currentTabIndex) {
      case 0:
        return AppBar(
          title: Text(_currentTabIndex == 0 ? 'Messages' : 'Contacts'),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.search,
              ),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(
                Icons.person_add,
              ),
              onPressed: () {},
            ),
          ],
        );
      case 1:
        return AppBar(
          title: Text(_currentTabIndex == 0 ? 'Messages' : 'Contacts'),
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.search,
              ),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(
                Icons.person_add,
              ),
              onPressed: () {},
            ),
          ],
        );
      case 2:
        return null;
    }
    return null;
  }
}
