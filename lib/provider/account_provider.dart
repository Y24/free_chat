import 'package:free_chat/provider/base_provider.dart';
import 'package:free_chat/provider/entity/account_entity.dart';
import 'package:free_chat/provider/entity/provider_code.dart';
import 'package:free_chat/provider/entity/provider_entity.dart';
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
    await db?.close();
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
        },
        onCreate: (db, version) async {
          print('onCreate: $ownerName/$dbName.db');
          tables.forEach((tableName, columnNames) async {
            String sql = '''
          create table $tableName (
            id integer primary key autoincrement,
          ''';
            columnNames.forEach((columnName) {
              sql += '$columnName text not null, ';
            });
            sql = sql.substring(0, sql.length - 2);
            sql += ' )';
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
      final result = await db.insert('history', entity.content.toMap());
      assert(result == 1, 'When add history,it should success');
      return true;
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
      if (await queryHistory() == AccountEntity.emptyAccountEntity)
        addHistory();
      else
        updateHistory();
      return true;
    }
  }

  @override
  Future<bool> logout() async {
    final result = await queryLogined();
    if (result == AccountEntity.emptyAccountEntity)
      return false;
    else {
      result.loginStatus = false;
      setEntity(ProviderEntity(code: AccountProviderCode.updateHistory,content: result));
      assert(await updateHistory() == true,
          'well logout should update successful,but not actually.');
      return true;
    }
  }

  @override
  Future<List<AccountEntity>> queryAllHistory() async {
    final result = await db.query(
      'history',
      columns: tables['history'],
    );
    if (result.isEmpty)
      return [];
    else
      return result.map((r) => AccountEntity.fromMap(r)).toList();
  }

  @override
  Future<AccountEntity> queryHistory() async {
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
  }

  @override
  Future<AccountEntity> queryLogined() async {
    final result = await db.query('history',
        columns: tables['history'], where: 'loginStatus = 1');
    assert(result.length <= 1,
        'Well, there should not exsit more than one logined account');
    if (result.isEmpty)
      return AccountEntity.emptyAccountEntity;
    else
      return AccountEntity.fromMap(result[0]);
  }

  @override
  Future<bool> updateHistory() async {
    final result = await db.update(
        'history', entity.content.toMap(),
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
