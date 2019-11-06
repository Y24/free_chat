import 'package:flutter/material.dart';
import 'package:free_chat/UI/account_page.dart';
import 'package:free_chat/UI/home_page.dart';
import 'package:free_chat/provider/account_provider.dart';
import 'package:free_chat/provider/base_provider.dart';
import 'package:free_chat/provider/entity/account_entity.dart';
import 'package:free_chat/provider/entity/provider_code.dart';
import 'package:free_chat/provider/entity/provider_entity.dart';
import 'package:free_chat/util/function_pool.dart';
import 'package:free_chat/util/ui/lifecycle_manager.dart';

import '../custom_will_pop_scope.dart';
import 'custom_style.dart';

class StartPage extends StatefulWidget {
  @override
  _StartPageState createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  bool fetched = false;
  IProvider provider;
  AccountEntity _accountEntity;
  @override
  void initState() {
    super.initState();
    fetched = false;
    provider = AccountProvider()
      ..init().then((result) async {
        print('provider init result: $result');
        if (result) {
          provider.setEntity(
              ProviderEntity(code: AccountProviderCode.queryLogined));
          _accountEntity = await provider.provide();
          setState(() {
            fetched = true;
          });
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    if (!fetched)
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    print('account entity: $_accountEntity');
    return MaterialApp(
      home: CustomStyle(
          child: _accountEntity != AccountEntity.emptyAccountEntity
              ? LifecycleManager(
                  child: CustomWillPopScope(
                    child: HomePage(
                      username: _accountEntity.username,
                    ),
                  ),
                )
              : AccountPage()),
    );
  }
}
