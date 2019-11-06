/// Provide the request data.
import 'package:free_chat/provider/base_provider.dart';
import 'package:free_chat/provider/entity/request_entity.dart';
import 'package:free_chat/provider/entity/provider_code.dart';
import 'package:free_chat/provider/entity/provider_entity.dart';
import 'package:free_chat/util/sql_util.dart';
import 'package:sqflite/sqflite.dart';

abstract class IRequestProvider implements IProvider {
  Future addRequest();
  Future updateRequest();
  Future deleteRequest();
  Future queryRequest();
  Future queryAllRequest();
}

class RequestProvier extends BaseProvider implements IRequestProvider {
  final String username;
  ProviderEntity _providerEntity;
  RequestProvier({this.username});
  @override
  Future close() async {
    if (db?.isOpen ?? false) await db?.close();
  }

  @override
  String get dbName => 'request';

  @override
  get entity => _providerEntity;

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
    switch (entity.code as RequestProviderCode) {
      case RequestProviderCode.addRequest:
        return await addRequest();
      case RequestProviderCode.updateRequest:
        return await updateRequest();
      case RequestProviderCode.deleteRequest:
        return await deleteRequest();
      case RequestProviderCode.queryRequest:
        return await queryRequest();
      case RequestProviderCode.queryAllRequest:
        return await queryAllRequest();
      default:
        print('request provider provide error');
    }
  }

  @override
  void setEntity(entity) {
    _providerEntity = entity;
  }

  @override
  Map<String, List<String>> get tables => const <String, List<String>>{
        'request': ['username', 'overview', 'timestamp'],
      };

  @override
  Future addRequest() async {
    if (await queryRequest() != RequestEntity.emptyRequestEntity)
      return false;
    else {
      try {
        await db.insert('request', entity.content.toMap());
        return true;
      } catch (e) {
        return false;
      }
    }
  }

  @override
  Future deleteRequest() async {
    final result = await db.delete('request',
        where: 'username = ?', whereArgs: [entity.content.username]);
    assert(result <= 1,
        'Well, there should not exsit more than one request with username: ${entity.content.username}');
    return result == 1;
  }

  @override
  Future queryAllRequest() async {
    final result = await db.query(
      'request',
      columns: tables['request'],
    );
    if (result.isEmpty)
      return [];
    else
      return result.map((r) => RequestEntity.fromMap(r)).toList();
  }

  @override
  Future queryRequest() async {
    RequestEntity requestEntity = entity.content;
    final result = await db.query('request',
        columns: tables['request'],
        where: 'username = ?',
        whereArgs: [requestEntity.username]);
    assert(result.length <= 1,
        'Well, there should not exsit more than one request with username: ${entity.content.username}');
    if (result.isEmpty)
      return RequestEntity.emptyRequestEntity;
    else
      return RequestEntity.fromMap(result[0]);
  }

  @override
  Future updateRequest() async {
    final result = await db.update('request', entity.content.toMap(),
        where: 'username = ?', whereArgs: [entity.content.username]);
    assert(result <= 1,
        'Well, there should not exsit more than one request with username: ${entity.content.username}');
    return result == 1;
  }
}
