import 'package:flutter/material.dart';
import 'package:free_chat/UI/account_page.dart';
import 'package:free_chat/configuration/configuration.dart';
import 'package:free_chat/services/accout_service.dart';
import 'package:free_chat/util/function_pool.dart';
import 'package:free_chat/util/ui/custom_style.dart';
import 'package:free_chat/util/ui/page_tansitions/scale_route.dart';
import 'package:provider/provider.dart';

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
      home: HomeUI(username: username),
    );
  }
}

class HomeUI extends StatefulWidget {
  GlobalKey<ScaffoldState> globalKey = GlobalKey();
  final username;
  HomeUI({this.username});
  @override
  _HomeUIState createState() => _HomeUIState();
}

class _HomeUIState extends State<HomeUI> {
  int _currentTabIndex = 2;

  @override
  Widget build(BuildContext context) {
    final languageState = Provider.of<LanguageState>(context);
    final customThemeDataState = Provider.of<CustomThemeDataState>(context);
    final _kTabPages = <Widget>[
      buildMessagePage(context),
      buildContactsPage(context),
      buildAccountPage(context),
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
      appBar: _currentTabIndex == 0 ? AppBar() : null,
      body: _kTabPages[_currentTabIndex],
      bottomNavigationBar: bottomNavBar,
    );
  }

  Widget buildMessagePage(BuildContext context) {
    return Center(child: Icon(Icons.cloud, size: 64.0, color: Colors.teal));
  }

  Widget buildContactsPage(BuildContext context) {
    return Center(child: Icon(Icons.cloud, size: 64.0, color: Colors.teal));
  }

  Widget buildAccountPage(BuildContext context) {
    final languageState = Provider.of<LanguageState>(context);
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          shape: RoundedRectangleBorder(
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(14),
                  bottomRight: Radius.circular(14))),
          backgroundColor: Colors.blue,
          floating: false,
          pinned: true,
          expandedHeight: 180.0,
          flexibleSpace: FlexibleSpaceBar(
            title: Padding(
              padding: const EdgeInsets.only(top: 18),
              child: ListTile(
                leading: ClipOval(
                    child: Image.asset(
                  'res/images/logo.png',
                  width: 30,
                  height: 30,
                )),
                title: Text(
                  widget.username,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    shadows: [
                      Shadow(
                        color: Colors.blue[300],
                        offset: const Offset(2, 2),
                        blurRadius: 0.5,
                      ),
                    ],
                  ),
                ),
                subtitle: Text(
                  FunctionPool.getStringRes(
                      key: 'onlineStr', language: languageState.language),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    shadows: [
                      Shadow(
                        color: Colors.blue[300],
                        offset: const Offset(2, 2),
                        blurRadius: 0.5,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            background: Image.asset(
              'res/images/enjoyLife.jpg',
              fit: BoxFit.cover,
            ),
          ),
          actions: <Widget>[
            PopupMenuButton<int>(
              offset: Offset(12, 20),
              onSelected: (reslut) {
                switch (reslut) {
                  case 0:
                    showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: Text('Are you ready to logout?'),
                              content: Text(
                                  'After logouting, you won\'t recieve any message!'),
                              actions: <Widget>[
                                FlatButton(
                                  child: Text('Cancel'),
                                  onPressed: () {
                                    Navigator.of(context).pop(false);
                                  },
                                ),
                                FlatButton(
                                  child: Text('Ok'),
                                  onPressed: () {
                                    Navigator.of(context).pop(true);
                                  },
                                ),
                              ],
                            )).then((result) {
                      if (result) {
                        AccountService.logout().then((_) {
                          Navigator.pushAndRemoveUntil(
                              context,
                              ScaleRoute(page: AccountPage()),
                              (route) => false);
                        });
                      }
                    });
                    break;
                  case 1:
                    FunctionPool.showCustomAboutDialog(context: context);
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 0,
                  child: Text(
                    FunctionPool.getStringRes(
                        key: 'logoutStr', language: languageState.language),
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
                PopupMenuItem(
                  value: 1,
                  child: Text(
                    FunctionPool.getStringRes(
                        key: 'aboutStr', language: languageState.language),
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ],
            ),
          ],
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            ..._buildAccountListView(languageState: languageState),
            ..._buildSettingListView(languageState: languageState),
            buildAboutButtomContainer(languageState: languageState),
          ]),
        )
      ],
    );
  }

  Container buildAboutButtomContainer({LanguageState languageState}) {
    return Container(
        color: Colors.grey[100],
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Text(
            FunctionPool.getStringRes(
                key: 'ButtomContainerAboutStr',
                language: languageState.language),
          ),
        ));
  }

  List<Widget> _buildAccountListView({LanguageState languageState}) {
    const divider = const Divider(
      color: Colors.blueGrey,
      indent: 24,
      endIndent: 14,
    );
    return [
      Padding(
        padding: const EdgeInsets.only(
          top: 20,
          left: 10,
          bottom: 20,
        ),
        child: Text(
          FunctionPool.getStringRes(
              key: 'accountStr', language: languageState.language),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ),
      ListTile(
        leading: Icon(
          Icons.info,
          color: Colors.blue,
        ),
        title: Text(
          FunctionPool.getStringRes(
              key: 'informationStr', language: languageState.language),
        ),
        onTap: () {
          widget.globalKey.currentState.showSnackBar(SnackBar(
            content: Text('Sorry, but username is unchangeable now.'),
            backgroundColor: Colors.blue,
          ));
        },
      ),
      divider,
      ListTile(
        leading: Icon(
          Icons.mode_edit,
          color: Colors.blue,
        ),
        title: Text(
          FunctionPool.getStringRes(
              key: 'editStr', language: languageState.language),
        ),
        onTap: () {
          /// TODO: Password change page.
          widget.globalKey.currentState.showSnackBar(SnackBar(
            content: Text('Change password'),
            backgroundColor: Colors.blue,
          ));
        },
      ),
    ];
  }

  List<Widget> _buildSettingListView({LanguageState languageState}) {
    const divider = const Divider(
      color: Colors.blueGrey,
      indent: 24,
      endIndent: 14,
    );
    return [
      Padding(
        padding: const EdgeInsets.only(
          top: 20,
          left: 10,
          bottom: 20,
        ),
        child: Text(
          FunctionPool.getStringRes(
              key: 'settingsStr', language: languageState.language),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
      ),
      ListTile(
        leading: Icon(
          Icons.label,
          color: Colors.blue,
        ),
        title: Text(FunctionPool.getStringRes(
            key: 'appearenceStr', language: languageState.language)),
        onTap: () {
          widget.globalKey.currentState.showSnackBar(SnackBar(
            content: Text('Sorry, but username is unchangeable now.'),
            backgroundColor: Colors.blue,
          ));
        },
      ),
      divider,
      ListTile(
        leading: Icon(
          Icons.notifications,
          color: Colors.blue,
        ),
        title: Text(FunctionPool.getStringRes(
            key: 'notificationsStr', language: languageState.language)),
        onTap: () {
          widget.globalKey.currentState.showSnackBar(SnackBar(
            content: Text('Sorry, but username is unchangeable now.'),
            backgroundColor: Colors.blue,
          ));
        },
      ),
      divider,
      ListTile(
        leading: Icon(
          Icons.security,
          color: Colors.blue,
        ),
        title: Text(FunctionPool.getStringRes(
            key: 'securityStr', language: languageState.language)),
        onTap: () {
          widget.globalKey.currentState.showSnackBar(SnackBar(
            content: Text('Sorry, but username is unchangeable now.'),
            backgroundColor: Colors.blue,
          ));
        },
      ),
      divider,
      ListTile(
        leading: Icon(
          Icons.chat,
          color: Colors.blue,
        ),
        title: Text(FunctionPool.getStringRes(
            key: 'chatStr', language: languageState.language)),
        onTap: () {
          widget.globalKey.currentState.showSnackBar(SnackBar(
            content: Text('Sorry, but username is unchangeable now.'),
            backgroundColor: Colors.blue,
          ));
        },
      ),
      divider,
      ListTile(
        leading: Icon(
          Icons.history,
          color: Colors.blue,
        ),
        title: Text(FunctionPool.getStringRes(
            key: 'historyStr', language: languageState.language)),
        onTap: () {
          widget.globalKey.currentState.showSnackBar(SnackBar(
            content: Text('Sorry, but username is unchangeable now.'),
            backgroundColor: Colors.blue,
          ));
        },
      ),
      divider,
      ListTile(
        leading: Icon(
          Icons.help,
          color: Colors.blue,
        ),
        title: Text(FunctionPool.getStringRes(
            key: 'helpStr', language: languageState.language)),
        onTap: () {
          widget.globalKey.currentState.showSnackBar(SnackBar(
            content: Text('Sorry, but username is unchangeable now.'),
            backgroundColor: Colors.blue,
          ));
        },
      ),
    ];
  }
}
