import 'dart:async';

import 'package:free_chat/entity/backend/account.dart';
import 'package:free_chat/entity/enums.dart';
import 'package:free_chat/services/mysql_service.dart';
import 'package:free_chat/util/function_pool.dart';
import 'package:mysql1/mysql1.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountService {
  final MysqlService mysqlService;
  AccountService({this.mysqlService});
  Future<LoginStatus> login({final username, final password}) async {
    // requestPermiss();
    // print('username: $username password: $password');
    if (!mysqlService.connected) {
      try {
        await mysqlService.connect();
      } catch (e) {
        return LoginStatus.serverError;
      }
    }
    // print(mysqlService.connection.toString());
    Results results = await Account.selectUserByName(
      connection: mysqlService.connection,
      name: username,
    );
    mysqlService.close();
    if (results.isEmpty || results.toList()[0][1] != password)
      return LoginStatus.authenticationFailture;
    else
      return LoginStatus.authenticationsuccess;
  }

  Future<RegisterStatus> register(
      {final username, final password, final Role role}) async {
    // requestPermiss();
    if (!mysqlService.connected) {
      try {
        await mysqlService.connect();
      } catch (e) {
        print(e.toString());
        return RegisterStatus.serverError;
      }
    }
    Results results = await Account.selectUserByName(
      connection: mysqlService.connection,
      name: username,
    );

    if (results.isNotEmpty) {
      mysqlService.close();
      return RegisterStatus.InvalidUsername;
    } else
      await Account.insertUser(
        connection: mysqlService.connection,
        username: username,
        password: password,
        role: role,
      );
    mysqlService.close();
    return RegisterStatus.success;
  }

  static Future<void> logout() async {
    var prefs = await SharedPreferences.getInstance();
    var accountStatus =
        FunctionPool.getAccountInfo(prefs, target: 'loginStatus');
    assert(accountStatus == true);
    FunctionPool.addAccountInfo(prefs, target: 'loginStatus', value: false);
    FunctionPool.addAccountInfo(prefs,
        target: 'loginAccountUsername', value: '');
  }
}
