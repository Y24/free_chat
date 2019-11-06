import 'package:free_chat/provider/base_provider.dart';
import 'package:free_chat/provider/entity/account_entity.dart';
import 'package:free_chat/provider/entity/provider_code.dart';
import 'package:free_chat/provider/entity/provider_entity.dart';
import 'package:free_chat/util/sql_util.dart';
import 'package:sqflite/sqflite.dart';

abstract class IAccountProvider implements IProvider {
  Future<AccountEntity> queryLogined();
  Future<List<AccountEntity>> queryAllHistory();
  Future<AccountEntity> queryHistory();
  Future<bool> addHistory();
  Future<bool> deleteHistory();
  Future<bool> updateHistory();
  Future<bool> login();
  Future<bool> logout();
}

/// Provide the account info.
class AccountProvider extends BaseProvider implements IAccountProvider {
  ProviderEntity _providerEntity;
  @override
  Future close() async {
     if (db?.isOpen ?? false) await db?.close();
  }

  @override
  String get dbName => 'account';

  @override
  Future<bool> init() async {
    try {
      db = await openDatabase(
        '$ownerName/$dbName.db',
        version: 1,
        onOpen: (db) {
          print('onOpen: $ownerName/$dbName.db');
          tables.forEach((tableName, columnNames) async {
            final sql = SqlUtil.getSql(tableName, columnNames);
            print('sql : $sql');
          });
        },
        onCreate: (db, version) async {
          print('onCreate: $ownerName/$dbName.db');
          tables.forEach((tableName, columnNames) async {
            final sql = SqlUtil.getSql(tableName, columnNames);
            print('sql : $sql');
            await db.execute(sql);
          });
        },
      );
      return true;
    } catch (e) {
      print('when init db ,catch e: $e');
      return false;
    }
  }

  @override
  String get ownerName => 'admin';

  @override
  Map<String, List<String>> get tables => const {
        'history': [
          'username',
          'role',
          'password',
          'loginStatus',
          'lastLoginTimestamp',
          'lastLogoutTimestamp'
        ],
      };

  @override
  Future<bool> addHistory() async {
    if (await queryHistory() != AccountEntity.emptyAccountEntity)
      return false;
    else {
      try {
        await db.insert('history', entity.content.toMap());
        return true;
      } catch (e) {
        print('error while add account history: $e');
        return false;
      }
    }
  }

  @override
  Future<bool> deleteHistory() async {
    final result = await db.delete('history',
        where: 'username = ?', whereArgs: [entity.content.username]);
    assert(result <= 1,
        'Well, there should not exsit more than one account with username: ${entity.content.username}');
    return result == 1;
  }

  @override
  Future<bool> login() async {
    final result = await queryLogined();
    if (result != AccountEntity.emptyAccountEntity)
      return false;
    else {
      if (await queryHistory() == AccountEntity.emptyAccountEntity) {
        print('add');
        addHistory();
      } else {
        print('update');
        updateHistory();
      }
      return true;
    }
  }

  @override
  Future<bool> logout() async {
    final result = await queryLogined();
    print(result.toMap().toString());
    if (result == AccountEntity.emptyAccountEntity)
      return false;
    else {
      result.loginStatus = false;
      setEntity(ProviderEntity(
          code: AccountProviderCode.updateHistory, content: result));
      assert(await updateHistory() == true,
          'well logout should update successful,but not actually.');
      return true;
    }
  }

  @override
  Future<List<AccountEntity>> queryAllHistory() async {
    try {
      final result = await db.query(
        'history',
        columns: tables['history'],
      );
      if (result.isEmpty)
        return [];
      else
        return result.map((r) => AccountEntity.fromMap(r)).toList();
    } catch (e) {
      print('error while querying all history: $e');
      return [];
    }
  }

  @override
  Future<AccountEntity> queryHistory() async {
    try {
      final result = await db.query('history',
          columns: tables['history'],
          where: 'username = ?',
          whereArgs: [entity.content.username]);
      assert(result.length <= 1,
          'Well, there should not exsit more than one account with username: ${entity.content.username}');
      if (result.isEmpty)
        return AccountEntity.emptyAccountEntity;
      else
        return AccountEntity.fromMap(result[0]);
    } catch (e) {
      print('error while querying hitory: $e');
      return AccountEntity.emptyAccountEntity;
    }
  }

  @override
  Future<AccountEntity> queryLogined() async {
    try {
      final result = await db.query('history',
          columns: tables['history'],
          where: 'loginStatus = ?',
          whereArgs: ['1']);
      assert(result.length <= 1,
          'Well, there should not exsit more than one logined account');
      if (result.isEmpty)
        return AccountEntity.emptyAccountEntity;
      else
        return AccountEntity.fromMap(result[0]);
    } catch (e) {
      print('error while query logined:$e');
      return AccountEntity.emptyAccountEntity;
    }
  }

  @override
  Future<bool> updateHistory() async {
    final result = await db.update('history', entity.content.toMap(),
        where: 'username = ?', whereArgs: [entity.content.username]);
    assert(result <= 1,
        'Well, there should not exsit more than one account with username: ${entity.content.username}');
    return result == 1;
  }

  @override
  get entity => _providerEntity;

  @override
  void setEntity(entity) {
    _providerEntity = entity;
  }

  @override
  Future provide() async {
    switch (entity.code as AccountProviderCode) {
      case AccountProviderCode.login:
        return await login();
      case AccountProviderCode.logout:
        return await logout();
      case AccountProviderCode.addHistory:
        return await addHistory();
      case AccountProviderCode.deleteHistory:
        return await deleteHistory();
      case AccountProviderCode.queryAllHistory:
        return await queryAllHistory();
      case AccountProviderCode.queryHistory:
        return await queryHistory();
      case AccountProviderCode.queryLogined:
        return await queryLogined();
      case AccountProviderCode.updateHistory:
        return updateHistory();
      default:
        print('account provider provide error');
    }
  }
}
