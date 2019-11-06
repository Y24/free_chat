import 'package:free_chat/provider/base_provider.dart';
import 'package:free_chat/provider/entity/history_entity.dart';
import 'package:free_chat/provider/entity/provider_code.dart';
import 'package:free_chat/provider/entity/provider_entity.dart';
import 'package:free_chat/util/function_pool.dart';
import 'package:free_chat/util/sql_util.dart';
import 'package:sqflite/sqflite.dart';

abstract class IHistoryProvider implements IProvider {
  Future addHistory();
  Future updateHistory();
  Future deleteHistory();
  Future queryHistory();
  Future queryAllHistory();
}

class HistoryProvider extends BaseProvider implements IHistoryProvider {
  final String username;
  ProviderEntity _providerEntity;
  HistoryProvider({this.username});

  @override
  Future close() async {
    if (db?.isOpen ?? false) await db?.close();
  }

  @override
  String get dbName => 'history';

  @override
  get entity => _providerEntity;

  @override
  Future<bool> init() async {
    try {
      db = await openDatabase(
        '$ownerName/$dbName.db',
        version: 1,
        onOpen: (db) async {
          print('onOpen: $ownerName/$dbName.db');
        },
        onCreate: (db, version) async {
          print('onCreate: $ownerName/$dbName.db');
          tables.forEach((tableName, columnNames) async {
            final sql = SqlUtil.getSql(tableName, columnNames);
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
  String get ownerName => username;

  @override
  Future provide() async {
    switch (entity.code as HistoryProviderCode) {
      case HistoryProviderCode.addHistory:
        return await addHistory();
      case HistoryProviderCode.updateHistory:
        return await updateHistory();
      case HistoryProviderCode.deleteHistory:
        return await deleteHistory();
      case HistoryProviderCode.queryHistory:
        return await queryHistory();
      case HistoryProviderCode.queryAllHistory:
        return await queryAllHistory();
      default:
        print('history provider provide error');
    }
  }

  @override
  void setEntity(entity) {
    _providerEntity = entity;
  }

  @override
  Map<String, List<String>> get tables => const <String, List<String>>{
        'history': [
          'historyId',
          'username',
          'content',
          'isOthers',
          'timestamp',
          'status',
        ],
      };
  @override
  Future queryAllHistory() async {
    final result = await db.query(
      'history',
      columns: tables['history'],
    );
    if (result.isEmpty)
      return [];
    else
      return result.map((r) => HistoryEntity.fromMap(r)).toList();
  }

  @override
  Future queryHistory() async {
    HistoryEntity historyEntity = entity.content;
    final result = await db.query('history',
        columns: tables['history'],
        where: 'username = ?',
        whereArgs: [historyEntity.username]);
    if (result.isEmpty)
      return [];
    else
      return result.map((r) => HistoryEntity.fromMap(r)).toList();
  }

  @override
  Future updateHistory() async {
    HistoryEntity historyEntity = entity.content;
    final timestamp = historyEntity.timestamp;
    final status = historyEntity.status;
    final username = historyEntity.username;
    try {
      var result = await db.query('history',
          columns: tables['history'],
          where: 'username =? AND timestamp = ?',
          whereArgs: [username, timestamp.toString()]);
      assert(result.length == 1,
          'Well, there should exist exact one history with username : ${historyEntity.username}, timestamp: ${historyEntity.timestamp}');
      final re = await db.update(
          'history',
          {
            'timestamp': DateTime.now().toString(),
            'status': FunctionPool.getStrByMessageSendStatus(status),
          },
          where: 'username =? AND timestamp = ?',
          whereArgs: [username, timestamp.toString()]);
      return re == 1;
    } catch (e) {
      print('error while update history: $e');
      return false;
    }
  }

  @override
  Future addHistory() async {
    if ((await queryHistory() as List)
        .any((r) => r.timestamp == entity.content.timestamp))
      return false;
    else {
      try {
        await db.insert('history', entity.content.toMap());
        return true;
      } catch (e) {
        print('error when add history: $e');
        return false;
      }
    }
  }

  @override
  Future deleteHistory() async {
    final result = await db.delete('history',
        where: 'historyId = ? AND username = ?',
        whereArgs: [entity.content.historyId, entity.content.username]);
    assert(result <= 1,
        'Well, there should not exsit more than one history with id: ${entity.content.historyId} username: ${entity.content.username}');
    return result == 1;
  }
}
