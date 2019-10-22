import 'package:flutter/material.dart';
import 'package:free_chat/UI/account_page.dart';
import 'package:free_chat/configuration/configuration.dart';
import 'package:free_chat/services/accout_service.dart';
import 'package:free_chat/util/ui/custom_style.dart';
import 'package:free_chat/util/ui/page_tansitions/scale_route.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  final username;
  HomePage({this.username});
  @override
  Widget build(BuildContext context) {
    final appTitle =
        Configuration.appName[Provider.of<LanguageState>(context).language];

    return MaterialApp(
      title: appTitle,
      theme: Provider.of<CustomThemeDataState>(context).themeData,
      home: Scaffold(
        appBar: AppBar(
          title: Text(username),
        ),
        body: HomeUI(username: username),
      ),
    );
  }
}

class HomeUI extends StatefulWidget {
  final username;
  HomeUI({this.username});
  @override
  _HomeUIState createState() => _HomeUIState();
}

class _HomeUIState extends State<HomeUI> {
  _HomeUIState();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        Center(
          child: Text(widget.username),
        ),
        RaisedButton(
          child: Text('logout'),
          onPressed: () {
            AccountService.logout().then((_) {
              Navigator.pushAndRemoveUntil(
                  context,
                  ScaleRoute(page: AccountPage()),
                  (route) => false);
            });
          },
        )
      ],
    );
  }
}
