import 'package:flutter/material.dart';
import 'package:free_chat/UI/account_page.dart';
import 'package:free_chat/UI/home_page.dart';
import 'package:free_chat/util/function_pool.dart';
import 'package:free_chat/util/ui/lifecycle_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../custom_will_pop_scope.dart';
import 'custom_style.dart';

class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  bool _isLogin = false;
  String _username = '';
  @override
  void initState() {
    super.initState();
  }

  Future<bool> fetchLoginStatus() async {
    var prefs = await SharedPreferences.getInstance();
    _isLogin =
        await FunctionPool.getAccountInfo(prefs, target: 'loginStatus') ??
            false;
    if (_isLogin)
      _username = await FunctionPool.getAccountInfo(prefs,
          target: 'loginAccountUsername');
    return _isLogin;
  }

  @override
  Widget build(BuildContext context) {
    // fetchLoginStatus();
    return FutureBuilder(
        future: fetchLoginStatus(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          switch (snapshot.connectionState) {
            case (ConnectionState.done):
              return MaterialApp(
                home: CustomStyle(
                    child: snapshot.data
                        ? LifecycleManager(
                            child: CustomWillPopScope(
                              child: HomePage(
                                username: _username,
                              ),
                            ),
                          )
                        : AccountPage()),
              );
            default:
              return MaterialApp(
                home: Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
          }
        });
  }
}
