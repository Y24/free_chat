import 'package:flutter/material.dart';
import 'package:free_chat/entity/enums.dart';
import 'package:free_chat/protocol/entity/account_protocol_entity.dart';
import 'package:free_chat/protocol/sender/account_protocol_sender.dart';
import 'package:free_chat/protocol/sender/base_protocol_sender.dart';
import 'package:free_chat/util/function_pool.dart';
import 'package:free_chat/util/ui/custom_style.dart';
import 'package:free_chat/util/ui/page_tansitions/scale_route.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'account_page.dart';

class HomeAccountPage extends StatelessWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final String username;
  HomeAccountPage({this.scaffoldKey, this.username});
  Widget build(BuildContext context) {
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
                  username,
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
              onSelected: (reslut) async {
                switch (reslut) {
                  case 0:
                    final result = await showDialog<bool>(
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
                            ));
                    if (result) {
                      final prefs = await SharedPreferences.getInstance();
                      final accountStatus = FunctionPool.getAccountInfo(prefs,
                          target: 'loginStatus');
                      final loginAccountUsername = FunctionPool.getAccountInfo(
                          prefs,
                          target: 'loginAccountUsername');
                      final loginAccountPassword = FunctionPool.getAccountInfo(
                          prefs,
                          target: 'loginAccountPassword');
                      assert(accountStatus == true);
                      IProtocolSender protocol = AccountProtocol(
                          username: loginAccountUsername,
                          password: loginAccountPassword);
                      await protocol.init();
                      AccountProtocolEntity protocolEntity =
                          AccountProtocolEntity(
                              head: AccountHeadEntity(
                                code: AccountProtocolCode.logout,
                                id: loginAccountUsername,
                                timestamp: DateTime.now(),
                              ),
                              body: AccountBodyEntity(
                                content: loginAccountPassword,
                              ));
                      protocol.setEntity(protocolEntity);
                      await protocol.send();
                      FunctionPool.addAccountInfo(prefs,
                          target: 'loginStatus', value: false);
                      FunctionPool.addAccountInfo(prefs,
                          target: 'loginAccountUsername', value: '');
                      Navigator.pushAndRemoveUntil(context,
                          ScaleRoute(page: AccountPage()), (route) => false);
                    }

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
        onTap: () {},
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
          scaffoldKey.currentState.showSnackBar(SnackBar(
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
        onTap: () {},
      ),
      divider,
      ListTile(
        leading: Icon(
          Icons.notifications,
          color: Colors.blue,
        ),
        title: Text(FunctionPool.getStringRes(
            key: 'notificationsStr', language: languageState.language)),
        onTap: () {},
      ),
      divider,
      ListTile(
        leading: Icon(
          Icons.security,
          color: Colors.blue,
        ),
        title: Text(FunctionPool.getStringRes(
            key: 'securityStr', language: languageState.language)),
        onTap: () {},
      ),
      divider,
      ListTile(
        leading: Icon(
          Icons.chat,
          color: Colors.blue,
        ),
        title: Text(FunctionPool.getStringRes(
            key: 'chatStr', language: languageState.language)),
        onTap: () {},
      ),
      divider,
      ListTile(
        leading: Icon(
          Icons.history,
          color: Colors.blue,
        ),
        title: Text(FunctionPool.getStringRes(
            key: 'historyStr', language: languageState.language)),
        onTap: () {},
      ),
      divider,
      ListTile(
        leading: Icon(
          Icons.help,
          color: Colors.blue,
        ),
        title: Text(FunctionPool.getStringRes(
            key: 'helpStr', language: languageState.language)),
        onTap: () {},
      ),
    ];
  }
}
